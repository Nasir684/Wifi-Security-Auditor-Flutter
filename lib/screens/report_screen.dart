import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../services/monetization_service.dart';
import '../services/pdf_service.dart';
import '../widgets/pro_paywall.dart';
import 'package:share_plus/share_plus.dart';

class ReportScreen extends StatefulWidget {
  final List<WiFiNetwork> networks;
  const ReportScreen({super.key, required this.networks});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final MonetizationService _monetization = MonetizationService();
  final PdfService _pdfService = PdfService();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    int critical = widget.networks.where((n) => n.riskLevel == RiskLevel.critical).length;
    int high = widget.networks.where((n) => n.riskLevel == RiskLevel.high).length;
    int medium = widget.networks.where((n) => n.riskLevel == RiskLevel.medium).length;
    int secure = widget.networks.where((n) => n.riskLevel == RiskLevel.secure).length;
    int total = widget.networks.length;
    double securePercent = total > 0 ? (secure / total * 100) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Summary - WanaLab'),
        backgroundColor: const Color(0xFF0A0E1A),
        actions: [
          if (_monetization.isPro)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Chip(label: Text('PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), backgroundColor: Colors.amber, padding: EdgeInsets.zero),
            ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Security Score Card - Technician wow factor ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFF1A2340), const Color(0xFF141C2F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: securePercent > 70 ? Colors.green : securePercent > 40 ? Colors.orange : Colors.red, width: 1.5),
              ),
              child: Column(
                children: [
                  Text('${securePercent.toStringAsFixed(0)}% Secure', style: TextStyle(color: securePercent > 70 ? Colors.green : securePercent > 40 ? Colors.orange : Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: securePercent / 100, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(securePercent > 70 ? Colors.green : Colors.orange)),
                  const SizedBox(height: 12),
                  Text('Scanned $total networks offline', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const Text('By WanaLab - Dera Ismail Khan', style: TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _statBox('Critical', critical.toString(), Colors.red, 'Fix now'),
                const SizedBox(width: 8),
                _statBox('High', high.toString(), Colors.deepOrange, 'Urgent'),
                const SizedBox(width: 8),
                _statBox('Medium', medium.toString(), Colors.orange, 'Review'),
                const SizedBox(width: 8),
                _statBox('Secure', secure.toString(), Colors.green, 'Good'),
              ],
            ),
            const SizedBox(height: 20),

            // --- Detailed list ---
            ...widget.networks.map((net) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF1A2340), borderRadius: BorderRadius.circular(10), border: Border.all(color: _getColor(net.riskLevel).withOpacity(0.3))),
                  child: Row(
                    children: [
                      Icon(Icons.wifi, color: _getColor(net.riskLevel), size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(net.ssid, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), Text('${net.encryptionType} | ${net.risks.first}', style: TextStyle(color: _getColor(net.riskLevel), fontSize: 11))])),
                      Text(net.riskLabel, style: TextStyle(color: _getColor(net.riskLevel), fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),

            const SizedBox(height: 24),

            // --- PDF Export - Monetized ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : () async {
                  setState(() => _isGenerating = true);
                  if (_monetization.isPro) {
                    var file = await _pdfService.generateReport(widget.networks);
                    Share.shareXFiles([XFile(file.path)], text: 'WanaLab Pro Audit Report');
                  } else {
                    // Rewarded ad flow
                    bool shown = await _monetization.showRewardedForPdf(() async {
                      var file = await _pdfService.generateReport(widget.networks);
                      Share.shareXFiles([XFile(file.path)], text: 'WanaLab WiFi Audit Report');
                    });
                    if (!shown && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad not ready - try again')));
                    }
                  }
                  setState(() => _isGenerating = false);
                },
                icon: _isGenerating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.picture_as_pdf),
                label: Text(_monetization.isPro ? 'Export PRO PDF (No Watermark)' : 'Watch Ad to Export PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),

            const SizedBox(height: 16),

            // --- Pro Paywall if not Pro ---
            if (!_monetization.isPro) const ProPaywall(),

            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            const Text('100% Offline Ethical Tool by WanaLab', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Text('This is an independent ethical tool. All data stays offline on your device. No data is sent to any server, including WanaLab or any organization. For authorized auditing only. Testing without permission is illegal.', style: TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Text('Developer: Nasir Khan | WanaLab | Dera Ismail Khan, Pakistan', style: TextStyle(color: Colors.white24, fontSize: 9), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String count, Color color, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.12), border: Border.all(color: color.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(count, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Color _getColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.critical: return Colors.red;
      case RiskLevel.high: return Colors.deepOrange;
      case RiskLevel.medium: return Colors.orange;
      case RiskLevel.secure: return Colors.green;
    }
  }
}
