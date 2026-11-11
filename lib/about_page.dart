import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('About WanaLab'),
        backgroundColor: const Color(0xFF141C2F),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Icon(Icons.shield, size: 80, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'WiFi Security Auditor\nWanaLab',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          _tile(
            icon: Icons.person,
            iconColor: Colors.blueAccent,
            title: "Developer",
            subtitle: "Nasir Khan - WanaLab\nLead Developer - 100% Offline Security",
          ),
          _tile(
            icon: Icons.location_on,
            iconColor: Colors.green,
            title: "Origin",
            subtitle: "Wana, South Waziristan, KPK, Pakistan\nProudly Made in Pakistan for Global Market",
          ),
          _tile(
            icon: Icons.email,
            iconColor: Colors.orange,
            title: "Support Email",
            subtitle: "nasir@wanalab.org\nTap to share feedback - Contact WanaLab Support: nasir@wanalab.org",
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF1A2340),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: Colors.greenAccent),
                      SizedBox(width: 8),
                      Text("Ethical Commitment", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "100% Offline. No hacking, cracking or unauthorized access. We process WiFi scan results ephemerally to audit YOUR own network security. No data leaves device. Ethical auditing for everyone.\n\nNEARBY_WIFI_DEVICES neverForLocation - we never track location.",
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            color: Color(0xFF1A2340),
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('Version', style: TextStyle(color: Colors.white)),
              subtitle: Text('1.0.0+1 Global Monetized - WanaLab Pro \$4.99\nContact: nasir@wanalab.org', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _tile({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Card(
      color: const Color(0xFF1A2340),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}
