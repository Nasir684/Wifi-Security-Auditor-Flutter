import 'package:flutter/material.dart';
import '../services/pro_service.dart';
import '../services/purchase_service.dart';

class AuditSummaryScreen extends StatefulWidget {
  final String ssid;
  final String security;
  final int signal;
  final String frequency;

  const AuditSummaryScreen({
    super.key,
    required this.ssid,
    required this.security,
    required this.signal,
    required this.frequency,
  });

  @override
  State<AuditSummaryScreen> createState() => _AuditSummaryScreenState();
}

class _AuditSummaryScreenState extends State<AuditSummaryScreen> {
  final PurchaseService _purchaseService = PurchaseService();

  @override
  void initState() {
    super.initState();
    _purchaseService.init();
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ProService.isPro;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: Text('Audit Summary - WanaLab - ${widget.ssid}',
            style: const TextStyle(fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Network Info Card
          Card(
            color: const Color(0xFF1A2340),
            child: ListTile(
              leading: const Icon(Icons.wifi, color: Colors.green),
              title: Text(widget.ssid,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                '${widget.security} · ${widget.signal} dBm · ${widget.frequency}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Secure',
                    style: TextStyle(color: Colors.green)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Export Button - Changes based on Pro status
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isPro ? Colors.green : Colors.blue,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (isPro) {
                // Pro: Direct export without ad, no watermark
                _exportPdf(watermark: false);
              } else {
                // Free: Watch ad
                _watchAdAndExport();
              }
            },
            icon: Icon(isPro ? Icons.picture_as_pdf : Icons.picture_as_pdf),
            label: Text(
              isPro ? 'Export Pro Report (No Watermark)' : 'Watch ad to export report',
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // WanaLab Pro Card - HIDE if already Pro
          if (!isPro)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A2340),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.workspace_premium,
                            color: Colors.amber),
                      ),
                      const SizedBox(width: 12),
                      const Text('WanaLab Pro',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('\$4.99',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _feature(Icons.block, 'No Ads - Clean audit experience'),
                  _feature(Icons.picture_as_pdf,
                      'No Watermark - Pro PDF reports'),
                  _feature(Icons.all_inclusive, 'Unlimited scans & exports'),
                  _feature(Icons.support_agent,
                      'Priority support - WanaLab, Wana'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await _purchaseService.buyPro();
                        setState(() {});
                      },
                      icon: const Icon(Icons.star, color: Colors.black),
                      label: const Text('Upgrade to Pro - \$4.99',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'One-time purchase. 100% offline app. No data collection. Developed in Wana, South Waziristan. Global support.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () async {
                      await _purchaseService.restorePurchases();
                      setState(() {});
                    },
                    child: const Center(
                        child: Text('Restore Purchases',
                            style: TextStyle(color: Colors.white54))),
                  ),
                ],
              ),
            ),

          if (isPro)
            const Card(
              color: Colors.green,
              child: ListTile(
                leading: Icon(Icons.verified, color: Colors.white),
                title: Text('WanaLab Pro Active',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Thank you for supporting WanaLab, Wana!',
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _watchAdAndExport() {
    // TODO: Integrate google_mobile_ads
    // For now just export with watermark for testing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ad would show here - Exporting with watermark for now')),
    );
    _exportPdf(watermark: true);
  }

  void _exportPdf({required bool watermark}) {
    // Your existing PDF export logic
    // If watermark == false, don't add WanaLab watermark
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(watermark
              ? 'Exported with watermark (Free)'
              : 'Exported Pro Report - No Watermark')),
    );
  }
}
