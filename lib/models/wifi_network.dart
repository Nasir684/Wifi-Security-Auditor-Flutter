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
    if (cap.isEmpty || cap == '[ESS]' || cap.contains('ESS') && !cap.contains('WPA') && !cap.contains('WEP')) return 'Open';
    return 'Unknown';
  }

  RiskLevel get riskLevel {
    if (encryptionType == 'Open' || encryptionType == 'WEP') return RiskLevel.critical;
    if (encryptionType == 'WPA') return RiskLevel.high;
    if (encryptionType == 'WPA2' && capabilities.toUpperCase().contains('TKIP')) return RiskLevel.medium;
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

  // Fixes your previous error + Global standard
  List<String> get risks {
    List<String> list = [];
    final capUpper = capabilities.toUpperCase();

    if (encryptionType == 'Open') {
      list.add('Open network - No encryption, traffic visible');
      list.add('Anyone can intercept data (Man-in-the-Middle risk)');
    }
    if (encryptionType == 'WEP') {
      list.add('WEP is broken - Crackable in <5 minutes with tools');
      list.add('PECA/CFAA violation risk if left open');
    }
    if (encryptionType == 'WPA') {
      list.add('WPA-TKIP is outdated and deprecated');
    }
    if (capUpper.contains('WPS')) {
      list.add('WPS enabled - Vulnerable to brute-force PIN attack');
    }
    if (capUpper.contains('TKIP')) {
      list.add('Uses TKIP instead of secure AES/CCMP');
    }
    if (frequency < 3000 && encryptionType == 'Open') {
      list.add('2.4GHz open - High interference + risk in crowded areas');
    }
    if (list.isEmpty) {
      list.add('No major risks detected - Configuration looks good');
    }
    return list;
  }

  String get recommendation {
    switch (riskLevel) {
      case RiskLevel.critical:
        return 'CRITICAL: Immediately change to WPA2-Personal (AES) or WPA3. Disable WPS. Set strong 12+ char password. For home: Use router admin panel. For business: Follow NIST guidelines.';
      case RiskLevel.high:
        return 'HIGH: Upgrade from WPA to WPA2/WPA3 with AES. Disable TKIP. Update router firmware from manufacturer site.';
      case RiskLevel.medium:
        return 'MEDIUM: Switch encryption from TKIP to AES/CCMP in router settings. This is a 2-minute fix that improves security significantly.';
      case RiskLevel.secure:
        return 'SECURE: Excellent! Keep firmware auto-updated, use 12+ character WPA2/WPA3 password, disable remote management & WPS.';
    }
  }

  // For report screen
  String get band {
    if (frequency >= 5000) return '5GHz';
    if (frequency >= 2400) return '2.4GHz';
    return 'Unknown';
  }

  int get signalQuality {
    if (signalStrength >= -50) return 100;
    if (signalStrength >= -60) return 80;
    if (signalStrength >= -70) return 60;
    if (signalStrength >= -80) return 40;
    return 20;
  }
}
