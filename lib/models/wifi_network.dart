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
}
