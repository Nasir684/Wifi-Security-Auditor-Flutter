import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/wifi_network.dart';
import '../services/monetization_service.dart';
import '../services/ownership_service.dart';
import '../services/pdf_service.dart';
import '../services/risk_analyzer.dart';
import '../widgets/pro_paywall.dart';

class ConsentScreen extends StatefulWidget {
  final WiFiNetwork network;
  final List<WiFiNetwork> allNetworks;

  const ConsentScreen({
    super.key,
    required this.network,
    required this.allNetworks,
  });

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

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  Future<void> _checkPassword() async {
    if (!_consented) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirm you own this network or have permission to test it.'),
        ),
      );
      return;
    }
    if (_passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your own network password to check.')),
      );
      return;
    }

    setState(() => _isChecking = true);
    try {
      final result = await _analyzer.checkWeakPassword(_passController.text);
      await OwnershipService.saveOwnership(widget.network.bssid);
      if (!mounted) return;
      setState(() {
        _result = result;
        _isChecking = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isChecking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not check the password: $error')),
      );
    }
  }

  Future<void> _shareReport() async {
    final result = _result;
    if (result == null) return;

    Future<void> generateAndShare() async {
      final file = await _pdfService.generateReport(
        widget.allNetworks,
        testedSsid: widget.network.ssid,
        testResult: result,
      );
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'WanaLab WiFi Audit Report - ${widget.network.ssid}',
      );
    }

    try {
      if (_monetization.isPro) {
        await generateAndShare();
      } else {
        final shown = await _monetization.showRewardedForPdf(generateAndShare);
        if (!shown && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ad not ready; please try again.')),
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate the report: $error')),
      );
    }
  }

  Color _strengthColor(Map<String, dynamic> result) {
    if (result['isWeak'] == true) return Colors.red;
    final score = (result['score'] as int?) ??
        ((result['strength'] as int? ?? 0) * 20);
    if (score < 40) return Colors.red;
    if (score < 70) return Colors.orange;
    return Colors.green;
  }

  Color _riskColor() {
    switch (widget.network.riskLevel) {
      case RiskLevel.secure:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.deepOrange;
      case RiskLevel.critical:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final riskColor = _riskColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.network.ssid, style: const TextStyle(fontSize: 16)),
        actions: [
          if (_monetization.isPro)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.verified, color: Colors.amber),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'AUTHORIZED TEST ONLY: Test networks you own or have explicit permission to assess. Password checking is performed offline on this device.',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.network.ssid,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        widget.network.riskLabel,
                        style: TextStyle(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('BSSID: ${widget.network.bssid}'),
                  Text('Encryption: ${widget.network.encryptionType}'),
                  Text('Signal: ${widget.network.signalStrength} dBm'),
                  const SizedBox(height: 8),
                  Text('Risks: ${widget.network.risks.join(', ')}'),
                  Text('Recommendation: ${widget.network.recommendation}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _consented,
            onChanged: (value) => setState(() => _consented = value ?? false),
            title: const Text('I own this network or have written permission to test it.'),
            subtitle: const Text('Required before checking a password.'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          TextField(
            controller: _passController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Your own WiFi password',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isChecking ? null : _checkPassword,
            icon: _isChecking
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.security),
            label: Text(_isChecking ? 'Checking offline…' : 'Check password strength'),
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            Card(
              color: _strengthColor(result).withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result['level'] ?? 'RESULT'} — ${result['score'] ?? 0}/100',
                      style: TextStyle(
                        color: _strengthColor(result),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${result['message'] ?? ''}'),
                    if (result['crackTime'] != null)
                      Text('Estimated crack time: ${result['crackTime']}'),
                    if (result['recommendations'] is List)
                      for (final recommendation
                          in result['recommendations'] as List)
                        Text('• $recommendation'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _shareReport,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                _monetization.isPro
                    ? 'Generate report'
                    : 'Watch ad to generate report',
              ),
            ),
            if (!_monetization.isPro) ...[
              const SizedBox(height: 12),
              const ProPaywall(),
            ],
          ],
          const SizedBox(height: 16),
          const Text(
            'Your password is not sent to a server or saved by this screen.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
