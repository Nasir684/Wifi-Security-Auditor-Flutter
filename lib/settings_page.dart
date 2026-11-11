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
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFF1A2340),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.security, color: Colors.blue),
              title: Text('WanaLab WiFi Auditor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Wana, South Waziristan\nnasir@wanalab.org\n100% Offline - Global Monetization Ready\nEthical - neverForLocation',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: const Color(0xFF1A2340),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.greenAccent),
              title: Text('Privacy', style: TextStyle(color: Colors.white)),
              subtitle: Text('No data leaves device - Offline only - No tracking', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const Divider(color: Colors.white24),
          Card(
            color: const Color(0xFF1A2340),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.workspace_premium, color: Colors.orange),
              title: Text('Upgrade to Pro - \$4.99', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('Product ID: wanalab_pro_499\nRemove watermark + Unlimited PDF exports + No Ads', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFF1A2340),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.email, color: Colors.orange),
              title: Text('Contact', style: TextStyle(color: Colors.white)),
              subtitle: Text('nasir@wanalab.org\nWanaLab Support', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const Card(
            color: Color(0xFF1A2340),
            child: ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blueAccent),
              title: Text('Version', style: TextStyle(color: Colors.white)),
              subtitle: Text('1.0.0+1 Global Monetized - Play Store Ready', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }
}
