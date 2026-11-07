enum RiskLevel { secure, medium, high, critical }

class WiFiNetwork {
  final String ssid;
  final String bssid;
  final int signalStrength; // -100 to 0
  final String capabilities; // e.g., [WPA2-PSK-CCMP][ESS]
  final int frequency;
  final RiskLevel riskLevel;
  final List<String> risks;
  final String recommendation;

  WiFiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalStrength,
    required this.capabilities,
    required this.frequency,
    required this.riskLevel,
    required this.risks,
    required this.recommendation,
  });

  bool get isSecure => riskLevel == RiskLevel.secure;

  String get encryptionType {
    if (capabilities.contains('WPA3')) return 'WPA3';
    if (capabilities.contains('WPA2')) return 'WPA2';
    if (capabilities.contains('WPA')) return 'WPA';
    if (capabilities.contains('WEP')) return 'WEP';
    if (capabilities.contains('ESS') && !capabilities.contains('WPA') && !capabilities.contains('WEP')) {
      return 'OPEN';
    }
    return 'Unknown';
  }

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.secure: return 'SECURE';
      case RiskLevel.medium: return 'MEDIUM';
      case RiskLevel.high: return 'HIGH';
      case RiskLevel.critical: return 'CRITICAL';
    }
  }
}
