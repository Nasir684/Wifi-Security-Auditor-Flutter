import 'package:flutter/material.dart';
import '../services/wifi_service.dart';
import '../models/wifi_network.dart';
import '../services/pdf_service.dart';
import 'consent_screen.dart';
import 'package:share_plus/share_plus.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final WiFiService _wifiService = WiFiService();
  final PdfService _pdfService = PdfService();
  List<WiFiNetwork> _networks = [];
  bool _isScanning = false;
  String _status = 'Tap Scan to start';

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _status = 'Requesting permission...';
    });

    try {
      bool perm = await _wifiService.requestPermissions();
      if (!perm) {
        setState(() { _status = 'Location permission required (Android needs it for WiFi scan)'; _isScanning = false; });
        return;
      }

      setState(() => _status = 'Scanning nearby WiFi...');
      var results = await _wifiService.scanNetworks();
      
      setState(() {
        _networks = results;
        _status = 'Found ${results.length} networks';
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isScanning = false;
      });
    }
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.secure: return Colors.green;
      case RiskLevel.medium: return Colors.orange;
      case RiskLevel.high: return Colors.deepOrange;
      case RiskLevel.critical: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Security Auditor'),
        centerTitle: true,
        actions: [
          if (_networks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                var file = await _pdfService.generateReport(_networks);
                Share.shareXFiles([XFile(file.path)], text: 'WiFi Audit Report');
              },
            )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF141C2F),
            child: Column(
              children: [
                Text(_status, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  icon: _isScanning ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.wifi_find),
                  label: Text(_isScanning ? 'Scanning...' : 'Auto Scan Nearby WiFi'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                ),
                const SizedBox(height: 8),
                const Text('No input required - Scans automatically\n100% Offline - No data sent to server', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: _networks.isEmpty
                ? const Center(child: Text('No networks yet. Tap Scan.', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    itemCount: _networks.length,
                    itemBuilder: (context, i) {
                      var net = _networks[i];
                      return Card(
                        color: const Color(0xFF1A2340),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.wifi, color: _getRiskColor(net.riskLevel)),
                          title: Text(net.ssid, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${net.encryptionType} | ${net.signalStrength} dBm | ${net.bssid}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text(net.risks.join(', '), style: TextStyle(color: _getRiskColor(net.riskLevel), fontSize: 12)),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: _getRiskColor(net.riskLevel).withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: _getRiskColor(net.riskLevel))),
                            child: Text(net.riskLabel, style: TextStyle(color: _getRiskColor(net.riskLevel), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConsentScreen(network: net, allNetworks: _networks))),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
