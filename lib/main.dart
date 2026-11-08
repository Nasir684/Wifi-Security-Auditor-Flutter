import 'package:flutter/material.dart';
...
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WiFiAuditorApp());
}

class WiFiAuditorApp extends StatelessWidget {
  const WiFiAuditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Security Auditor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('WiFi Security Auditor')),
      ),
    );
  }
}
