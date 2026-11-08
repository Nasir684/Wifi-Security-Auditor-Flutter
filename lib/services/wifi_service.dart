import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../models/wifi_network.dart';
import 'risk_analyzer.dart';
import 'ownership_service.dart';

class WiFiService {
  final RiskAnalyzer _analyzer = RiskAnalyzer();

  Future<bool> requestPermissions() async {
    // FIX: Android 13+ needs BOTH permissions
    final location = await Permission.location.request();
    final nearby = await Permission.nearbyWifiDevices.request();
    
    // On Android <13, nearbyWifiDevices returns restricted but it's ok
    if (location.isGranted) {
      return true;
    }
    if (nearby.isGranted) {
      return true;
    }
    return location.isGranted || nearby.isGranted;
  }

  Future<bool> canStartScan() async {
    // FIX: Use askPermissions true for Android 14
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    return can == CanStartScan.yes;
  }

  Future<List<WiFiNetwork>> scanNetworks() async {
    // Check permissions
    bool hasPerm = await requestPermissions();
    if (!hasPerm) {
      throw Exception('Location & Nearby WiFi permission required. Enable in Settings > Apps > WanaLab > Permissions');
    }

    // Check if we can scan with permissions
    final canScanResult = await WiFiScan.instance.canStartScan(askPermissions: true);
    if (canScanResult != CanStartScan.yes) {
      // Try to get detailed reason
      final canGetResults = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
      if (canGetResults != CanGetScannedResults.yes) {
        throw Exception('Enable Location & WiFi. Then restart app. Status: $canGetResults');
      }
    }

    // Start scan
    final result = await WiFiScan.instance.startScan();
    if (result != true) {
      throw Exception('Scan failed. Make sure WiFi and Location are ON. Try again.');
    }

    // Wait 3 seconds for results
    await Future.delayed(const Duration(seconds: 3));

    final canGet = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    if (canGet != CanGetScannedResults.yes) {
      throw Exception('Cannot get scan results: $canGet. Enable Location.');
    }

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

    // Sort by signal strength - Strongest first
    networks.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
    return networks;
  }

  Future<void> confirmOwnership(String bssid) async {
    await OwnershipService.saveOwnership(bssid);
  }
}
