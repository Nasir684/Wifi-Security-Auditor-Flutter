enum RiskLevel { secure, medium, high, critical }

class WiFiNetwork {
  final String ssid;
  final String bssid;
  final int signalStrength;
  final String capabilities;
  final int frequency;

  WiFiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalStrength,
    required this.capabilities,
    required this.frequency,
  });

  String get encryptionType {
    final cap = capabilities.toUpperCase();
    if (cap.contains('WPA3')) return 'WPA3';
    if (cap.contains('WPA2')) return 'WPA2';
    if (cap.contains('WPA')) return 'WPA';
    if (cap.contains('WEP')) return 'WEP';
    if (cap.isEmpty || cap.contains('ESS')) return 'Open';
    return 'Unknown';
  }

  RiskLevel get riskLevel {
    if (encryptionType == 'Open' || encryptionType == 'WEP') return RiskLevel.critical;
    if (encryptionType == 'WPA') return RiskLevel.high;
    if (encryptionType == 'WPA2' && capabilities.contains('TKIP')) return RiskLevel.medium;
    return RiskLevel.secure;
  }

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.secure: return 'Secure';
      case RiskLevel.medium: return 'Medium';
      case RiskLevel.high: return 'High';
      case RiskLevel.critical: return 'Critical';
    }
  }

  // THIS WAS MISSING - FIXES YOUR ERROR
  List<String> get risks {
    List<String> list = [];
    if (encryptionType == 'Open') {
      list.add('Open network - No encryption');
      list.add('Traffic can be intercepted');
    }
    if (encryptionType == 'WEP') {
      list.add('WEP is broken - Crackable in minutes');
    }
    if (encryptionType == 'WPA') {
      list.add('WPA-TKIP is outdated');
    }
    if (capabilities.contains('WPS')) {
      list.add('WPS enabled - Vulnerable to brute force');
    }
    if (capabilities.contains('TKIP')) {
      list.add('Uses TKIP instead of AES');
    }
    if (list.isEmpty) {
      list.add('No major risks detected');
    }
    return list;
  }

  String get recommendation {
    switch (riskLevel) {
      case RiskLevel.critical:
        return 'CRITICAL: Change to WPA2/WPA3 immediately. Disable WPS.';
      case RiskLevel.high:
        return 'HIGH: Upgrade from WPA to WPA2/WPA3. Use AES.';
      case RiskLevel.medium:
        return 'MEDIUM: Switch TKIP to AES/CCMP.';
      case RiskLevel.secure:
        return 'Secure: Keep firmware updated, use strong password.';
    }
  }
}
