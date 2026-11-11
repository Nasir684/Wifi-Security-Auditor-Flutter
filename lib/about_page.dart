import 'package:flutter/material.dart';

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
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.security, size: 40, color: Colors.blue.shade900),
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: Text("WiFi Security Auditor", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const Center(child: Text("v1.0.0+1 Global Monetized", style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Developer"),
              subtitle: const Text("Nasir Khan - WanaLab"),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Origin"),
              subtitle: const Text("Wana, South Waziristan, KPK, Pakistan\nBuilt for Technicians Worldwide"),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Support"),
              subtitle: const Text("wanadev.lab@gmail.com\nnasir@wanalab.org"),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.shield),
              title: const Text("Ethical Commitment"),
              subtitle: const Text("100% Offline. No hacking, cracking or unauthorized access. For networks you own or have written permission to audit only.\nComplies with PECA 2016 (PK), CFAA (US), Computer Misuse Act (UK)."),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text("Privacy Policy"),
              subtitle: const Text("https://wanadev.github.io/privacy-policy.html"),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Built for Global WiFi Technicians, IT Admins & Security-conscious Home Users.\n© 2026 WanaLab, Wana - South Waziristan. All rights reserved.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
