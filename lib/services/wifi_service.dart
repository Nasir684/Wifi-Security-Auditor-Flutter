Future<List<WiFiNetwork>> scanNetworks() async {
  // 1. Only request once
  final location = await Permission.location.request();
  final nearby = await Permission.nearbyWifiDevices.request();

  bool hasPerm = location.isGranted || nearby.isGranted;
  if (!hasPerm) {
    throw Exception('Please allow Location and Nearby Devices in Settings');
  }

  // 2. Check canScan WITHOUT asking again
  final canScan = await WiFiScan.instance.canStartScan(askPermissions: false);
  if (canScan != CanStartScan.yes) {
    throw Exception('Turn ON WiFi and Location, then try again. Status: $canScan');
  }

  // 3. Start scan
  final started = await WiFiScan.instance.startScan();
  if (started != true) {
    throw Exception('Scan failed to start. Make sure WiFi is ON.');
  }

  await Future.delayed(const Duration(seconds: 3));

  final results = await WiFiScan.instance.getScannedResults();
  // ... rest same as yours
}
