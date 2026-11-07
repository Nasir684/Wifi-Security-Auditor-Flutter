import 'package:flutter/material.dart';
import '../models/wifi_network.dart';

class ReportScreen extends StatelessWidget {
  final List<WiFiNetwork> networks;
  const ReportScreen({super.key, required this.networks});

  @override
  Widget build(BuildContext context) {
    int critical = networks.where((n) => n.riskLevel == RiskLevel.critical).length;
    int high = networks.where((n) => n.riskLevel == RiskLevel.high).length;
    int medium = networks.where((n) => n.riskLevel == RiskLevel.medium).length;
    int secure = networks.where((n) => n.riskLevel == RiskLevel.secure).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Summary')),
      backgroundColor: const Color(0xFF0A0E1A),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _statBox('Critical', critical.toString(), Colors.red),
                const SizedBox(width: 8),
                _statBox('High', high.toString(), Colors.deepOrange),
                const SizedBox(width: 8),
                _statBox('Medium', medium.toString(), Colors.orange),
                const SizedBox(width: 8),
                _statBox('Secure', secure.toString(), Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            const Text('This is an independent ethical tool. All data stays offline on your device. No data is sent to any server, including WanaLab or any organization.', style: TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.15), border: Border.all(color: color), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(count, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
