import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue.shade900.withOpacity(0.2),
              child: Icon(Icons.security, size: 45, color: Colors.blue.shade400),
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: Text("WiFi Security Auditor", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const Center(child: Text("v1.0.0+1 Global Monetized", style: TextStyle(color: Colors.grey, fontSize: 12))),
          const SizedBox(height: 6),
          const Center(child: Text("WanaLab", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, letterSpacing: 1.2))),
          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blueAccent),
              title: const Text("Developer"),
              subtitle: const Text("Nasir Khan - WanaLab\nLead Developer & Security Researcher"),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: const Text("Origin"),
              subtitle: const Text("Wana, South Waziristan, KPK, Pakistan\nBuilt in Wana, Serving Technicians Worldwide"),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.orange),
              title: const Text("Support Email"),
              subtitle: const Text("wanadev.lab@gmail.com\nTap to share support info"),
              onTap: () {
                Share.share('Contact WanaLab Support: wanadev.lab@gmail.com\nWiFi Security Auditor - From Wana, South Waziristan');
              },
            ),
          ),
          Card(
            color: const Color(0xFF1A2340),
            child: ListTile(
              leading: const Icon(Icons.shield, color: Colors.greenAccent),
              title: const Text("Ethical Commitment"),
              subtitle: const Text(
                "100% Offline. No hacking, cracking or unauthorized access.\nFor networks you own or have written permission to audit only.\n\nComplies with:\n• PECA 2016 (Pakistan)\n• CFAA (USA)\n• Computer Misuse Act (UK)\n• GDPR (EU)",
                style: TextStyle(height: 1.4),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.purpleAccent),
              title: const Text("Privacy Policy"),
              subtitle: const Text("https://wanadev.github.io/privacy-policy.html\nNo data collected. 100% offline."),
              onTap: () {
                Share.share('Privacy Policy - WanaLab WiFi Auditor: https://wanadev.github.io/privacy-policy.html\n100% Offline, No data collected.');
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text("Share App"),
              subtitle: const Text("Share with fellow technicians"),
              onTap: () {
                Share.share(
                    'Check out WiFi Security Auditor by WanaLab, Wana - South Waziristan!\nEthical toolkit for technicians.\nhttps://play.google.com/store/apps/details?id=com.wanalab.wifi_security_auditor');
              },
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Built for Global WiFi Technicians, IT Admins & Security-conscious Home Users.\n\nDesigned and developed in Wana, South Waziristan, KPK, Pakistan with pride.\n\n© 2026 WanaLab. All rights reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
