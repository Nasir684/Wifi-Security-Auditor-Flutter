import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings - WanaLab'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.security, color: Colors.blue),
              title: Text('WanaLab WiFi Auditor'),
              subtitle: Text('Wana, South Waziristan\nwanadev.lab@gmail.com\n100% Offline - Global Monetization Ready'),
            ),
          ),
          SizedBox(height: 10),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy'),
            subtitle: Text('No data leaves device - Offline only'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.workspace_premium, color: Colors.orange),
            title: Text('Upgrade to Pro - \$4.99'),
            subtitle: Text('Remove watermark + Unlimited PDF exports'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0 - Build for Play Store'),
          ),
        ],
      ),
    );
  }
}
