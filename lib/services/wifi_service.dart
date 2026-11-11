import '../models/wifi_network.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

class WiFiService {
  Future<List<WiFiNetwork>> scanNetworks() async {
    // 1. Request permissions - single flow (we handle UI elsewhere)
    final locationStatus = await Permission.location.request();
    PermissionStatus nearbyStatus = PermissionStatus.granted;

    // nearbyWifiDevices only exists on Android 13+, check before request
    try {
      nearbyStatus = await Permission.nearbyWifiDevices.request();
    } catch (_) {
      // On older Android, this permission doesn't exist - ignore
    }

    bool hasPerm = locationStatus.isGranted || nearbyStatus.isGranted;
    if (!hasPerm) {
      throw Exception('Please allow Location + Nearby Devices.\nGo to Settings > Apps > WanaLab WiFi Scanner > Permissions > Allow.');
    }

    // 2. Check if we can scan
    final canScan = await WiFiScan.instance.canStartScan(askPermissions: false);
    if (canScan != CanStartScan.yes) {
      if (canScan == CanStartScan.notSupported) {
        throw Exception('WiFi scanning not supported on this device/emulator. Use real device.');
      }
      throw Exception('Turn ON WiFi and Location, then try again.\nStatus: $canScan');
    }

    // 3. Start scan
    final started = await WiFiScan.instance.startScan();
    if (started != true) {
      throw Exception('Scan failed to start. Make sure WiFi is ON and Location is ON.');
    }

    // 4. Wait for results (Android needs 3-4 sec)
    await Future.delayed(const Duration(seconds: 4));

    // 5. Get results
    final results = await WiFiScan.instance.getScannedResults();
    
    if (results.isEmpty) {
      throw Exception('No networks found. Make sure WiFi is ON, Location is ON, and you are not in airplane mode.');
    }

    // 6. Map + Deduplicate by BSSID + Sort by signal strength
    final Map<String, WiFiNetwork> unique = {};
    for (var r in results) {
      final network = WiFiNetwork(
        ssid: r.ssid,
        bssid: r.bssid,
        signalStrength: r.level,
        capabilities: r.capabilities,
        frequency: r.frequency,
      );
      // Keep strongest signal if duplicate BSSID
      if (!unique.containsKey(r.bssid) || unique[r.bssid]!.signalStrength < r.level) {
        unique[r.bssid] = network;
      }
    }

    final list = unique.values.toList();
    // Sort strongest first
    list.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
    
    return list;
  }
}
