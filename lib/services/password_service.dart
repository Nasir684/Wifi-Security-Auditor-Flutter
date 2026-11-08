/// Result of an offline password-strength check for a password the user owns.
class PasswordStrengthResult {
  final String level;
  final int score;
  final bool isInWeakList;
  final String crackTime;
  final List<String> recommendations;

  const PasswordStrengthResult({
    required this.level,
    required this.score,
    required this.isInWeakList,
    required this.crackTime,
    required this.recommendations,
  });
}

/// Performs a local heuristic check; no password is stored or transmitted.
class PasswordService {
  static const Set<String> _commonPasswords = {
    '12345678', 'password', '123456789', 'qwerty123', 'admin123',
    'iloveyou', '11111111', '1234567890', 'welcome123', 'password1',
    'qwerty', 'letmein', 'admin', 'abc12345', '00000000', '123123123',
  };

  static Future<PasswordStrengthResult> checkOwnPasswordStrength(
    String password,
  ) async {
    final normalized = password.trim().toLowerCase();
    final isInWeakList = _commonPasswords.contains(normalized);
    var score = 0;
    if (password.length >= 8) score += 20;
    if (password.length >= 12) score += 20;
    if (password.length >= 16) score += 10;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 15;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 15;
    score = score.clamp(0, 100);
    if (isInWeakList) score = score.clamp(0, 20);

    final level = isInWeakList || score < 40
        ? 'WEAK'
        : score < 70
            ? 'MODERATE'
            : 'STRONG';
    final recommendations = <String>[];
    if (password.length < 12) recommendations.add('Use at least 12 characters.');
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      recommendations.add('Add uppercase letters.');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      recommendations.add('Include numbers.');
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      recommendations.add('Include symbols.');
    }
    if (isInWeakList) {
      recommendations.add('Avoid common passwords and predictable sequences.');
    }

    return PasswordStrengthResult(
      level: level,
      score: score,
      isInWeakList: isInWeakList,
      crackTime: level == 'WEAK'
          ? 'Very quickly; change it immediately'
          : level == 'MODERATE'
              ? 'Potentially crackable; use a longer passphrase'
              : 'No estimate; use a unique passphrase and MFA where available',
      recommendations: recommendations,
    );
  }
}
