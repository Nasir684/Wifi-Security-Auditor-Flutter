import '../models/wifi_network.dart';
import 'password_service.dart';

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
    String ssidLower = ssid.toLowerCase().trim();

    // CRITICAL: OPEN - No WPA/WEP/WPA3 tag = Open
    if (!capsUpper.contains('WPA') && !capsUpper.contains('WEP')) {
      risks.add('OPEN Network - No Password Protection');
      risks.add('All traffic visible to nearby devices');
      level = RiskLevel.critical;
      recommendation = 'CRITICAL: Enable WPA2/WPA3 immediately. Open networks expose all traffic to interception.';
      return RiskAnalysisResult(riskLevel: level, risks: risks, recommendation: recommendation);
    }

    // CRITICAL: WEP
    if (capsUpper.contains('WEP')) {
      risks.add('WEP Encryption - Broken since 2005, crackable in < 60 seconds');
      level = RiskLevel.critical;
      recommendation = 'CRITICAL: WEP is broken. Upgrade router to WPA2/WPA3 immediately. From WanaLab, Wana.';
    }

    // HIGH: WPS - Play Store safe wording
    if (capsUpper.contains('WPS')) {
      risks.add('WPS Setting Detected - Vulnerable to brute-force PIN');
      if (level.index < RiskLevel.high.index) level = RiskLevel.high;
      recommendation = 'HIGH: Disable WPS in router admin (192.168.1.1). Use WPA2/WPA3 with strong password.';
    }

    // MEDIUM: Default SSID - Technician goldmine - Added PTCL variants for PK market + global
    const defaultSSIDs = [
      'tplink', 'dlink', 'ptcl', 'ptcl-bb', 'ptcl-bb-', 'flashfiber', 'default', 
      'netgear', 'linksys', 'admin', 'huawei', 'zte', 'fiber', 'wanalab', 
      'telenor', 'jazz', 'zong', 'ufone'
    ];
    for (var def in defaultSSIDs) {
      if (ssidLower == def || ssidLower.startsWith('${def}_') || ssidLower.startsWith('${def}-')) {
        risks.add('Default SSID Detected ($def) - Router not personalized, may have default admin creds');
        if (level.index < RiskLevel.medium.index) level = RiskLevel.medium;
        break;
      }
    }

    // MEDIUM: WPA only (not WPA2/WPA3)
    if (capsUpper.contains('WPA') && !capsUpper.contains('WPA2') && !capsUpper.contains('WPA3')) {
      risks.add('WPA (TKIP) - Deprecated since 2012, weak encryption');
      if (level.index < RiskLevel.medium.index) level = RiskLevel.medium;
      recommendation = 'Upgrade from WPA-TKIP to WPA2-AES or WPA3. Enable AES/CCMP only.';
    }

    // TKIP check even with WPA2
    if (capsUpper.contains('TKIP')) {
      risks.add('TKIP detected - Less secure than AES');
      if (level.index < RiskLevel.medium.index) level = RiskLevel.medium;
    }

    // If no risks - Secure
    if (risks.isEmpty) {
      if (capsUpper.contains('WPA3')) {
        risks.add('WPA3 - Latest secure standard');
        risks.add('No major issues detected');
        level = RiskLevel.secure;
        recommendation = 'WPA3 is secure. Ensure strong password (12+ chars), disable WPS, update firmware.';
      } else if (capsUpper.contains('WPA2')) {
        risks.add('WPA2-AES - Secure when configured properly');
        risks.add('No major issues detected');
        level = RiskLevel.secure;
        recommendation = 'WPA2-AES is secure if password is strong. Recommend WPA3 if router supports it. From Wana, South Waziristan.';
      }
    }

    return RiskAnalysisResult(
      riskLevel: level,
      risks: risks,
      recommendation: recommendation,
    );
  }

  // --- Uses 10k offline list via PasswordService ---
  Future<Map<String, dynamic>> checkWeakPassword(String password) async {
    final result = await PasswordService.checkOwnPasswordStrength(password);
    
    return {
      'isWeak': result.level == 'WEAK' || result.isInWeakList,
      'strength': result.score ~/ 20, // 0-5 scale for old UI compatibility
      'score': result.score, // 0-100 for new UI
      'level': result.level,
      'crackTime': result.crackTime,
      'isInWeakList': result.isInWeakList,
      'recommendations': result.recommendations,
      'message': result.isInWeakList
          ? '⚠️ Found in common weak list (10k offline). Change immediately. Est crack: ${result.crackTime}'
          : 'Strength: ${result.level} (${result.score}/100) - Est: ${result.crackTime}',
    };
  }

  // Legacy sync version
  Map<String, dynamic> checkWeakPasswordSync(String password) {
    const weakPasswords = [
      '12345678', 'password', '123456789', 'admin', 'admin123',
      '123456', 'qwerty', 'letmein', 'ptcl', '1234', '00000000',
      'password123', 'admin@123', 'wifi123', '123123123', 'wanalab'
    ];
    bool isWeak = weakPasswords.contains(password.toLowerCase()) || password.length < 8;
    int strength = 0;
    if (password.length >= 12) strength += 2; else if (password.length >= 8) strength += 1;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 1;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 1;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) strength += 1;
    return {
      'isWeak': isWeak || strength < 3,
      'strength': strength,
      'message': isWeak ? 'Weak password in common list. Change immediately.' : 'Password not in weak list. Strength: $strength/5',
    };
  }
}
