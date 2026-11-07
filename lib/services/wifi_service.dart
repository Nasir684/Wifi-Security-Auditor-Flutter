import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../models/wifi_network.dart';
import 'risk_analyzer.dart';

class WiFiService {
  final RiskAnalyzer _analyzer = RiskAnalyzer();

  Future<bool> requestPermissions() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> canStartScan() async {
    final can = await WiFiScan.instance.canStartScan();
    return can == CanStartScan.yes;
  }

  Future<List<WiFiNetwork>> scanNetworks() async {
    // Check permissions
    bool hasPerm = await requestPermissions();
    if (!hasPerm) {
      throw Exception('Location permission required for WiFi scan');
    }

    // Start scan
    final canScan = await canStartScan();
    if (!canScan) {
      throw Exception('Cannot start scan. Enable Location & WiFi.');
    }

    final result = await WiFiScan.instance.startScan();
    if (result != true) {
      throw Exception('Scan failed. Try again.');
    }

    // Wait 3 seconds for results
    await Future.delayed(const Duration(seconds: 3));

    final accessPoints = await WiFiScan.instance.getScannedResults();
    
    List<WiFiNetwork> networks = [];
    for (var ap in accessPoints) {
      var analysis = _analyzer.analyze(
        ssid: ap.ssid,
        capabilities: ap.capabilities,
      );

      networks.add(WiFiNetwork(
        ssid: ap.ssid.isEmpty ? '<Hidden Network>' : ap.ssid,
        bssid: ap.bssid,
        signalStrength: ap.level,
        capabilities: ap.capabilities,
        frequency: ap.frequency,
        riskLevel: analysis.riskLevel,
        risks: analysis.risks,
        recommendation: analysis.recommendation,
      ));
    }

    // Sort by signal strength
    networks.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
    return networks;
  }
}
