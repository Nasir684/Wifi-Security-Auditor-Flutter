import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/scan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // For google_mobile_ads 9.2.0
  await MobileAds.instance.initialize();

  // For wifi_scan on Android 13+
  await Permission.location.request();
  await Permission.nearbyWifiDevices.request();

  runApp(const WiFiAuditorApp());
}

class WiFiAuditorApp extends StatelessWidget {
  const WiFiAuditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WanaLab WiFi Scanner',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        primaryColor: Colors.blueAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF141C2F),
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: const ScanScreen(),
    );
  }
}
