import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(title: const Text('About'), backgroundColor: const Color(0xFF0A0E1A)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Column(
              children: [
                Text('WiFi Security Auditor', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('v1.0.0+1 Global Monetized', style: TextStyle(color: Colors.white54)),
                SizedBox(height: 4),
                Text('WanaLab', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _card(Icons.person, 'Developer', 'Nasir Khan - WanaLab\nLead Developer & Security Researcher'),
          _card(Icons.location_on, 'Origin', 'Wana, South Waziristan, KPK, Pakistan\nBuilt in Wana, Serving Technicians Worldwide'),
          _cardButton(Icons.email, 'Support Email', 'nasir@wanalab.org\nTap to share support info', () {
            Share.share('WanaLab Support: nasir@wanalab.org\nApp: WiFi Security Auditor v1.0.0');
          }),
          _card(Icons.verified_user, 'Ethical Commitment', '100% Offline. No hacking, No data collection\nNo data leaves device. For authorized auditing only.'),
          _card(Icons.workspace_premium, 'WanaLab Pro', 'One-time \$4.99 - No Ads, No Watermark, Unlimited Exports\nDeveloped in Wana, Global Monetization Ready'),
        ],
      ),
    );
  }

  Widget _card(IconData icon, String title, String sub) {
    return Card(color: const Color(0xFF1A2340), margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(leading: Icon(icon, color: Colors.blue), title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text(sub, style: const TextStyle(color: Colors.white70))));
  }

  Widget _cardButton(IconData icon, String title, String sub, VoidCallback onTap) {
    return Card(color: const Color(0xFF1A2340), margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(leading: Icon(icon, color: Colors.orange), title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text(sub, style: const TextStyle(color: Colors.white70)), onTap: onTap));
  }
}
