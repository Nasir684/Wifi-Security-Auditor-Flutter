import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../services/risk_analyzer.dart';
import '../services/pdf_service.dart';
import '../services/monetization_service.dart';
import '../services/ownership_service.dart';
import '../widgets/pro_paywall.dart';
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
  final MonetizationService _monetization = MonetizationService();
  Map<String, dynamic>? _result;
  bool _consented = false;
  bool _isChecking = false;

  Future<void> _checkPassword() async {
    if (!_consented) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must confirm you own this network - Required by Google Play')));
      return;
    }

    if (_passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your own password to check')));
      return;
    }

    setState(() => _isChecking = true);
    
    // --- New: Uses 10k offline list + gives score + crack time ---
    var res = await _analyzer.checkWeakPassword(_passController.text);
    
    // Save ownership timestamp for audit
    await OwnershipService.saveOwnership(widget.network.bssid);
    
    setState(() {
      _result = res;
      _isChecking = false;
    });
  }

  Future<void> _generatePdfWithMonetization() async {
    if (_result == null) return;

    if (_monetization.isPro) {
      var file = await _pdfService.generateReport(widget.allNetworks, testedSsid: widget.network.ssid, testResult: _result);
      Share.shareXFiles([XFile(file.path)], text: 'WanaLab Pro Audit Report - ${widget.network.ssid}');
      return;
    }

    // Free: Rewarded ad
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF141C2F),
        title: const Text('Unlock PDF with Password Result', style: TextStyle(color: Colors.white)),
        content: const Text('Watch ad to generate professional PDF with your password strength result for client. Pro users get unlimited.', style: TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            onPressed: () async {
              Navigator.pop(context);
              await _monetization.showRewardedForPdf(() async {
                var file = await _pdfService.generateReport(widget.allNetworks, testedSsid: widget.network.ssid, testResult: _result);
                Share.shareXFiles([XFile(file.path)], text: 'WanaLab Audit Report - ${widget.network.ssid}');
              });
            },
            child: const Text('Watch Ad', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor() {
    if (_result == null) return Colors.grey;
    if (_result!['isWeak'] == true) return Colors.red;
    int score = _result!['score'] ?? _result!['strength'] * 20;
    if (score < 40) return Colors.red;
    if (score < 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.network.ssid, style: const TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF0A0E1A),
        actions: [
          if (_monetization.isPro)
            const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.verified, color: Colors.amber)),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Legal Banner - Google wants this ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), border: Border.all(color: Colors.red.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('AUTHORIZED TEST ONLY: Only test networks you own. Testing others without permission is illegal under PECA. This check is 100% offline vs 10k weak list.', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Network Info ---
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF1A2340), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Network: ${widget.network.ssid}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _getRiskColor().withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(widget.network.riskLabel, style: TextStyle(color: _getRiskColor(), fontSize: 10, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('BSSID: ${widget.network.bssid} | Signal: ${widget.network.signalStrength} dBm', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  Text('Encryption: ${widget.network.encryptionType}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text('Risks: ${widget.network.risks.join(', ')}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Fix: ${widget.network.recommendation}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  const Divider(color: Colors.white10, height: 20),
                  // --- Block Guide - Technician value ---
                  const Text('How to Block Unknown Devices (For Technician):', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('1. Open 192.168.1.1 in browser\n2. Login admin/admin\n3. Go to Wireless → MAC Filtering\n4. Add suspicious MAC to block list', style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Consent Checkbox ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _consented ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: _consented ? Colors.green : Colors.orange, width: 1)),
              child: CheckboxListTile(
                value: _consented,
                onChanged: (v) => setState(() => _consented = v!),
                activeColor: Colors.green,
                title: const Text('I confirm I own this network / have written permission to test it', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                subtitle: const Text('Required for Google Play - Ethical use only', style: TextStyle(color: Colors.white54, fontSize: 10)),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(height: 16),

            // --- Password Input ---
            TextField(
              controller: _passController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter YOUR OWN WiFi password to check if weak (Offline)',
                labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                suffixIcon: IconButton(icon: const Icon(Icons.visibility_off, color: Colors.white24), onPressed: () {}),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkPassword,
                icon: _isChecking ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.security),
                label: Text(_isChecking ? 'Checking 10k List Offline...' : 'Check Password Strength (Offline 10k)'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _getStrengthColor().withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: _getStrengthColor(), width: 1.2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_result!['isWeak'] ? '⚠️ WEAK PASSWORD' : '✅ ${(_result!['level'] ?? 'STRONG')}', style: TextStyle(color: _getStrengthColor(), fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_result!['score'] ?? _result!['strength'] * 20}/100', style: TextStyle(color: _getStrengthColor(), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Crack Time: ${_result!['crackTime'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(_result!['message'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    if (_result!['recommendations'] != null) ...[
                      const SizedBox(height: 10),
                      const Text('Recommendations:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...(_result!['recommendations'] as List).map((r) => Padding(padding: const EdgeInsets.only(bottom: 3), child: Row(children: [const Text('• ', style: TextStyle(color: Colors.white54)), Expanded(child: Text(r, style: const TextStyle(color: Colors.white60, fontSize: 11)))]))),
                    ],
                    if (_result!['isInWeakList'] == true)
                      Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: const Text('Found in 10k most common passwords list - Change immediately! Never share this password.', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generatePdfWithMonetization,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(_monetization.isPro ? 'Generate PRO PDF' : 'Watch Ad to Generate PDF'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              if (!_monetization.isPro) ...[
                const SizedBox(height: 12),
                const ProPaywall(),
              ],
            ],
            const SizedBox(height: 20),
            const Text('100% Offline - Password never leaves device, never stored - By WanaLab', textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor() {
    switch (widget.network.riskLevel) {
      case RiskLevel.critical: return Colors.red;
      case RiskLevel.high: return Colors.deepOrange;
      case RiskLevel.medium: return Colors.orange;
      case RiskLevel.secure: return Colors.green;
    }
  }
}
