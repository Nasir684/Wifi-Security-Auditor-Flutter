import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../services/risk_analyzer.dart';
import '../services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';

class ConsentScreen extends StatefulWidget {
  final WiFiNetwork network;
  final List<WiFiNetwork> allNetworks;
  const ConsentScreen({super.key, required this.network, required this.allNetworks});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final TextEditingController _passController = TextEditingController();
  final RiskAnalyzer _analyzer = RiskAnalyzer();
  final PdfService _pdfService = PdfService();
  Map<String, dynamic>? _result;
  bool _consented = false;

  void _checkPassword() {
    if (!_consented) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must confirm you own this network')));
      return;
    }
    var res = _analyzer.checkWeakPassword(_passController.text);
    setState(() => _result = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.network.ssid)),
      backgroundColor: const Color(0xFF0A0E1A),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(8)),
                child: const Text('AUTHORIZED TEST ONLY: Only test networks you own. Testing others without permission is illegal. This check is offline and verifies against local weak list only.', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
              const SizedBox(height: 16),
              Text('Network: ${widget.network.ssid}', style: const TextStyle(color: Colors.white, fontSize: 16)),
              Text('BSSID: ${widget.network.bssid}\nEncryption: ${widget.network.encryptionType}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Risks: ${widget.network.risks.join(', ')}', style: const TextStyle(color: Colors.orange)),
              Text('Fix: ${widget.network.recommendation}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(value: _consented, onChanged: (v) => setState(() => _consented = v!), activeColor: Colors.blue),
                  const Expanded(child: Text('I confirm I own this network / have written permission to test it', style: TextStyle(color: Colors.white70, fontSize: 12))),
                ],
              ),
              TextField(
                controller: _passController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Enter your own WiFi password to check if weak', labelStyle: TextStyle(color: Colors.white54), border: OutlineInputBorder(), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkPassword,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  child: const Text('Check Password Strength (Offline)'),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _result!['isWeak'] ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: _result!['isWeak'] ? Colors.red : Colors.green)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_result!['isWeak'] ? 'WEAK PASSWORD DETECTED' : 'PASSWORD NOT IN WEAK LIST', style: TextStyle(color: _result!['isWeak'] ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_result!['message'], style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      var file = await _pdfService.generateReport(widget.allNetworks, testedSsid: widget.network.ssid, testResult: _result);
                      Share.shareXFiles([XFile(file.path)], text: 'My WiFi Audit Report');
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate PDF Report'),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
