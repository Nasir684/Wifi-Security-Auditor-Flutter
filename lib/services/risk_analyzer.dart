import '../models/wifi_network.dart';

class RiskAnalysisResult {
  final RiskLevel riskLevel;
  final List<String> risks;
  final String recommendation;

  RiskAnalysisResult({
    required this.riskLevel,
    required this.risks,
    required this.recommendation,
  });
}

class RiskAnalyzer {
  RiskAnalysisResult analyze({required String ssid, required String capabilities}) {
    List<String> risks = [];
    RiskLevel level = RiskLevel.secure;
    String recommendation = 'Configuration looks secure. Continue using WPA2/WPA3 with strong password.';

    String capsUpper = capabilities.toUpperCase();
    String ssidLower = ssid.toLowerCase();

    // CRITICAL: OPEN
    if (!capsUpper.contains('WPA') && !capsUpper.contains('WEP') && !capsUpper.contains('WPA3')) {
      risks.add('OPEN Network - No Password');
      level = RiskLevel.critical;
      recommendation = 'CRITICAL: Enable WPA2/WPA3 immediately. Open networks expose all traffic.';
      return RiskAnalysisResult(riskLevel: level, risks: risks, recommendation: recommendation);
    }

    // CRITICAL: WEP
    if (capsUpper.contains('WEP')) {
      risks.add('WEP Encryption - Broken in 2005, crackable in < 60 seconds');
      level = RiskLevel.critical;
      recommendation = 'CRITICAL: WEP is broken. Upgrade to WPA2/WPA3 immediately.';
    }

    // HIGH: WPS - Play Store safe wording
    if (capsUpper.contains('WPS')) {
      risks.add('WPS Setting Detected - Vulnerable to brute force');
      if (level.index < RiskLevel.high.index) level = RiskLevel.high;
      recommendation = 'HIGH: Disable WPS in router settings. Use WPA2/WPA3 with strong password.';
    }

    // MEDIUM: Default SSID
    const defaultSSIDs = ['tplink', 'dlink', 'ptcl', 'ptcl-bb', 'default', 'netgear', 'linksys', 'admin', 'huawei', 'zte'];
    for (var def in defaultSSIDs) {
      if (ssidLower.contains(def)) {
        risks.add('Default SSID Detected - Indicates router not configured');
        if (level.index < RiskLevel.medium.index) level = RiskLevel.medium;
        break;
      }
    }

    // MEDIUM: WPA only (not WPA2)
    if (capsUpper.contains('WPA-') && !capsUpper.contains('WPA2') && !capsUpper.contains('WPA3')) {
      risks.add('WPA (TKIP) - Deprecated, weak');
      if (level.index < RiskLevel.medium.index) level = RiskLevel.medium;
      recommendation = 'Upgrade from WPA-TKIP to WPA2-AES or WPA3.';
    }

    // If no risks
    if (risks.isEmpty) {
      if (capsUpper.contains('WPA3')) {
        risks.add('WPA3 Secure');
        level = RiskLevel.secure;
        recommendation = 'WPA3 is secure. Ensure strong password (12+ chars) and disable WPS.';
      } else if (capsUpper.contains('WPA2')) {
        risks.add('WPA2 Secure');
        level = RiskLevel.secure;
        recommendation = 'WPA2-AES is secure if password is strong. Recommend WPA3 if router supports it.';
      }
    }

    return RiskAnalysisResult(
      riskLevel: level,
      risks: risks,
      recommendation: recommendation,
    );
  }

  // Phase 2: Local weak password check (ethical - only for own network)
  Map<String, dynamic> checkWeakPassword(String password) {
    const weakPasswords = [
      '12345678', 'password', '123456789', 'admin', 'admin123',
      '123456', 'qwerty', 'letmein', 'ptcl', '1234', '00000000',
      'password123', 'admin@123', 'wifi123', '123123123'
    ];

    bool isWeak = weakPasswords.contains(password.toLowerCase()) || password.length < 8;
    int strength = 0;
    
    if (password.length >= 12) strength += 2;
    else if (password.length >= 8) strength += 1;
    
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 1;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) strength += 1;

    return {
      'isWeak': isWeak || strength < 3,
      'strength': strength,
      'message': isWeak 
          ? 'Weak password found in common weak list. Change immediately.' 
          : 'Password not in weak list. Strength score: $strength/5',
    };
  }
}
