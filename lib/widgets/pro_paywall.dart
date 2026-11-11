import 'package:flutter/material.dart';
import '../services/monetization_service.dart';

class ProPaywall extends StatelessWidget {
  const ProPaywall({super.key});

  @override
  Widget build(BuildContext context) {
    final monetization = MonetizationService();
    
    return Card(
      elevation: 2,
      color: const Color(0xFF1E2A4A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.amber.withOpacity(0.4), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('WanaLab Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
                  child: Text(monetization.proPrice, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _FeatureRow(icon: Icons.block, text: 'No Ads - Clean audit experience'),
            const _FeatureRow(icon: Icons.picture_as_pdf_outlined, text: 'No Watermark - Pro PDF reports'),
            const _FeatureRow(icon: Icons.all_inclusive, text: 'Unlimited scans & exports'),
            const _FeatureRow(icon: Icons.support_agent, text: 'Priority support - WanaLab, Wana'),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  // TODO: Integrate in_app_purchase
                  // For now, enable test Pro
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pro purchase: Configure in_app_purchase - For testing, use enableProForTesting()')),
                  );
                  
                  // Uncomment to test Pro UI instantly:
                  // await monetization.enableProForTesting();
                  // if (context.mounted) {
                  //   Navigator.of(context).pop();
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text('Pro enabled for testing! Restart app.')),
                  //   );
                  // }
                },
                icon: const Icon(Icons.star, size: 18),
                label: Text('Upgrade to Pro - ${monetization.proPrice}'),
                style: FilledButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'One-time purchase. 100% offline app. No data collection. Developed in Wana, South Waziristan. Global support.',
              style: TextStyle(fontSize: 10, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.greenAccent.withOpacity(0.9)),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
}
