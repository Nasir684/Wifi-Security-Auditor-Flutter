enum RiskLevel { secure, medium, high, critical }

class WiFiNetwork {
  final String ssid;
  final String bssid;
  final int signalStrength; // -100 to 0, higher = stronger
  final String capabilities; // e.g., [WPA2-PSK-CCMP][ESS][WPS]
  final int frequency; // 2412 = 2.4GHz, 5GHz etc
  final RiskLevel riskLevel;
  final List<String> risks;
  final String recommendation;

  // --- WanaLab Pro fields - Optional for future ---
  final bool isOwnNetwork;
  final String? vendor;

  WiFiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalStrength,
    required this.capabilities,
    required this.frequency,
    required this.riskLevel,
    required this.risks,
    required this.recommendation,
    this.isOwnNetwork = false,
    this.vendor,
  });

  bool get isSecure => riskLevel == RiskLevel.secure;

  String get encryptionType {
    if (capabilities.contains('WPA3')) return 'WPA3';
    if (capabilities.contains('WPA2')) return 'WPA2';
    if (capabilities.contains('WPA')) return 'WPA';
    if (capabilities.contains('WEP')) return 'WEP';
    if (capabilities.contains('ESS') &&
        !capabilities.contains('WPA') &&
        !capabilities.contains('WEP')) {
      return 'OPEN';
    }
    return 'Unknown';
  }

  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.secure:
        return 'SECURE';
      case RiskLevel.medium:
        return 'MEDIUM';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.critical:
        return 'CRITICAL';
    }
  }

  // --- New helpers for UI + Monetization ---

  String get signalLabel {
    if (signalStrength >= -50) return 'Excellent';
    if (signalStrength >= -60) return 'Good';
    if (signalStrength >= -70) return 'Fair';
    return 'Weak';
  }

  int get signalPercent {
    // Convert -100..0 to 0..100
    if (signalStrength <= -100) return 0;
    if (signalStrength >= -50) return 100;
    return (2 * (signalStrength + 100)).clamp(0, 100);
  }

  bool get isDefaultSsid {
    const defaults = [
      'tplink',
      'dlink',
      'ptcl',
      'default',
      'netgear',
      'linksys',
      'huawei',
      'zte',
      'fiber',
    ];
    return defaults.any((d) => ssid.toLowerCase().contains(d));
  }

  bool get hasWps => capabilities.toUpperCase().contains('WPS');

  // For PDF export branding
  String get toReportLine {
    return 'SSID: $ssid | BSSID: $bssid | $encryptionType | $riskLabel | $signalStrength dBm | Risks: ${risks.join(', ')}';
  }

  // For copy to technician
  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'signal': signalStrength,
      'enc': encryptionType,
      'risk': riskLabel,
      'risks': risks,
      'rec': recommendation,
      'vendor': vendor ?? 'Unknown',
    };
  }

  // Factory for discovery_service compatibility
  factory WiFiNetwork.fromDiscovered({
    required String ip,
    required String mac,
    String? vendor,
    bool isOwn = false,
  }) {
    return WiFiNetwork(
      ssid: 'Device $ip',
      bssid: mac,
      signalStrength: -50,
      capabilities: '[WPA2]',
      frequency: 2412,
      riskLevel: RiskLevel.medium,
      risks: ['Device discovered on network'],
      recommendation: 'If unknown device, block via router MAC filtering',
      isOwnNetwork: isOwn,
      vendor: vendor,
    );
  }
}
