import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('Settings - WanaLab'),
        backgroundColor: const Color(0xFF141C2F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            color: Color(0xFF1A2340),
            child: ListTile(
              leading: Icon(Icons.security, color: Colors.blue),
              title: Text('WanaLab WiFi Auditor', style: TextStyle(color: Colors.white)),
              subtitle: Text('Wana, South Waziristan\nnasir@wanalab.org\n100% Offline - Global Monetization Ready\nVersion 1.0.0+1', style: TextStyle(color: Colors.white70)),
            ),
          ),
          SizedBox(height: 10),
          Card(
            color: Color(0xFF1A2340),
            child: ListTile(
              leading: Icon(Icons.email, color: Colors.orange),
              title: Text('Support', style: TextStyle(color: Colors.white)),
              subtitle: Text('nasir@wanalab.org', style: TextStyle(color: Colors.white70)),
            ),
          ),
          Card(
            color: Color(0xFF1A2340),
            child: ListTile(
              leading: Icon(Icons.workspace_premium, color: Colors.amber),
              title: Text('WanaLab Pro - \$4.99', style: TextStyle(color: Colors.white)),
              subtitle: Text('Remove watermark + No Ads + Unlimited exports', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}
