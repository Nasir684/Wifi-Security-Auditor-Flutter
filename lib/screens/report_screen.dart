import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/wifi_network.dart';
import '../services/monetization_service.dart';
import '../services/pdf_service.dart';
import '../widgets/pro_paywall.dart';

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

  Future<void> _exportReport() async {
    setState(() => _isGenerating = true);
    try {
      Future<void> generateAndShare() async {
        final file = await _pdfService.generateReport(widget.networks);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: _monetization.isPro
              ? 'WanaLab Pro Audit Report - Wana, South Waziristan'
              : 'WanaLab WiFi Audit Report - WanaLab',
        );
      }

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
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Color _riskColor(RiskLevel risk) {
    switch (risk) {
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
    final total = widget.networks.length;
    final secure = widget.networks.where((n) => n.riskLevel == RiskLevel.secure).length;
    final critical = widget.networks.where((n) => n.riskLevel == RiskLevel.critical).length;
    final high = widget.networks.where((n) => n.riskLevel == RiskLevel.high).length;
    final medium = widget.networks.where((n) => n.riskLevel == RiskLevel.medium).length;
    final securePercent = total == 0 ? 0.0 : secure / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Summary - WanaLab'),
        actions: [
          if (_monetization.isPro)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('PRO'),
                backgroundColor: Colors.amber,
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${(securePercent * 100).round()}% Secure',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: securePercent, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  Text('Scanned $total networks | WanaLab, Wana, South Waziristan', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _summaryChip('Critical', critical, Colors.red),
              _summaryChip('High', high, Colors.deepOrange),
              _summaryChip('Medium', medium, Colors.orange),
              _summaryChip('Secure', secure, Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          for (final network in widget.networks)
            Card(
              child: ListTile(
                leading: Icon(Icons.wifi, color: _riskColor(network.riskLevel)),
                title: Text(network.ssid.isEmpty ? '<Hidden SSID>' : network.ssid, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${network.encryptionType} · ${network.signalStrength} dBm · ${network.band}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _riskColor(network.riskLevel).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    network.riskLabel,
                    style: TextStyle(color: _riskColor(network.riskLevel), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isGenerating ? null : _exportReport,
            icon: _isGenerating
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf),
            label: Text(_isGenerating ? 'Generating…' : _monetization.isPro ? 'Export Pro Report (No Watermark)' : 'Watch ad to export report'),
          ),
          if (!_monetization.isPro) ...[
            const SizedBox(height: 12),
            const ProPaywall(),
          ],
          const SizedBox(height: 16),
          const Text(
            'For authorized auditing only. Network data is displayed locally on this device. No data sent to server. Developed in Wana, South Waziristan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Chip(
      label: Text('$label: $count', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      side: BorderSide(color: color.withOpacity(0.5)),
      backgroundColor: color.withOpacity(0.12),
    );
  }
}
