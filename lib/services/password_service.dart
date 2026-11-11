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

/// 100% offline - No assets - WanaLab, Wana, South Waziristan
class PasswordService {
  static const Set<String> _commonPasswords = {
    // Top Global
    '12345678', 'password', '123456789', 'qwerty123', 'admin123',
    'iloveyou', '11111111', '1234567890', 'welcome123', 'password1',
    'qwerty', 'letmein', 'admin', 'abc12345', '00000000', '123123123',
    'password123', '123456', '1234567', '12345', '1234', '0000',
    'admin@123', 'admin1234', 'root', 'toor', 'passw0rd',
    // WiFi Specific
    'wifi123', 'wifi1234', 'internet', 'internet123', 'broadband',
    'tplink', 'dlink', 'netgear', 'linksys', 'huawei', 'zte',
    'ptcl', 'ptcl-bb', 'ptcl123', 'ptcl1234', 'flashfiber', 'nayatel',
    // Pakistan Common
    'pakistan', 'pakistan123', 'lahore123', 'karachi123', 'islamabad',
    '12345678@', 'admin@ptcl', 'ptcl@123', 'wifipassword',
    // WanaLab
    'wanalab', 'wana123', 'wana1234', 'nasir123', 'nasir1234',
    // Simple patterns
    'qwerty1234', 'abcd1234', 'abcd123', '1q2w3e4r', '1qaz2wsx',
    '000000', '111111', '123123', '654321', '666666', '7777777',
    '121212', '112233', '123321', 'password@123', 'admin@1234',
    'welcome1', 'welcome1234', 'iloveyou123', 'love123', 'king123',
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
    if (password.length < 12) recommendations.add('Use at least 12 characters (16+ recommended).');
    if (!RegExp(r'[A-Z]').hasMatch(password)) recommendations.add('Add uppercase letters.');
    if (!RegExp(r'[0-9]').hasMatch(password)) recommendations.add('Include numbers.');
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) recommendations.add('Include symbols.');
    if (isInWeakList) {
      recommendations.add('Found in common weak list (offline). Change immediately.');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Strong password. Keep unique.');
    }

    String crackTime;
    if (level == 'WEAK') {
      crackTime = isInWeakList ? 'Instantly (common list)' : 'Minutes-hours';
    } else if (level == 'MODERATE') {
      crackTime = 'Days-months';
    } else {
      crackTime = 'Years-centuries';
    }

    return PasswordStrengthResult(
      level: level,
      score: score,
      isInWeakList: isInWeakList,
      crackTime: crackTime,
      recommendations: recommendations,
    );
  }
}
