import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/scan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // FIX: Don't await AdMob in main - it crashes on some phones before UI shows
  // Initialize in background and ignore errors
  try {
    MobileAds.instance.initialize();
  } catch (_) {
    // Ignore - app should open even if AdMob fails
  }

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
