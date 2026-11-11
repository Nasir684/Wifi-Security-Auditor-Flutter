import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/scan_screen.dart';
import 'screens/settings_page.dart';
import 'screens/about_page.dart';
import 'services/pro_service.dart';
import 'services/ad_service.dart';
import 'services/purchase_service.dart';
import 'services/monetization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WanaLab: Initialize - Works 100% offline in Wana
  try {
    await MobileAds.instance.initialize();
    await ProService.init();
    await AdService.init();
    await MonetizationService().initialize();
  } catch (_) {
    // Offline mode - app launches in Wana without internet
    await ProService.init();
  }

  // FOR TESTING PRO ONLY - Uncomment to test $4.99 without paying
  // await ProService.enableProForTesting();

  runApp(const WiFiAuditorApp());
}

class WiFiAuditorApp extends StatefulWidget {
  const WiFiAuditorApp({super.key});
  @override
  State<WiFiAuditorApp> createState() => _WiFiAuditorAppState();
}

class _WiFiAuditorAppState extends State<WiFiAuditorApp> {
  final PurchaseService _purchaseService = PurchaseService();
  
  @override
  void initState() {
    super.initState();
    _purchaseService.init();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Security Auditor - WanaLab | Wana, South Waziristan',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        primaryColor: const Color(0xFF3B82F6),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF60A5FA),
          surface: Color(0xFF1A2340),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF141C2F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A2340),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        useMaterial3: true,
      ),
      // Global Routes - Required for About + Settings - Contact: nasir@wanalab.org
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
      },
      home: const ScanScreen(),
    );
  }
}
