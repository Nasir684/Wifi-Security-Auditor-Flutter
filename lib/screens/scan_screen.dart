import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/wifi_service.dart';
import '../models/wifi_network.dart';
import '../services/pdf_service.dart';
import '../services/monetization_service.dart';
import '../services/ownership_service.dart';
import '../widgets/owner_consent_gate.dart';
import '../widgets/pro_paywall.dart';
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
  final MonetizationService _monetization = MonetizationService();
  List<WiFiNetwork> _networks = [];
  bool _isScanning = false;
  String _status = 'Tap Scan to start';
  bool _hasConsent = false;
  BannerAd? _bannerAd;
  bool _showPaywall = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (_monetization.isPro) return;
    _bannerAd = _monetization.createBanner();
    _bannerAd!.load();
    setState(() {});
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (!_hasConsent) {
      setState(() => _status = '⚠️ Please check consent box first - Required for Google Play');
      return;
    }

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
      
      // Save ownership for first network (ethical)
      if (results.isNotEmpty) {
        await _wifiService.confirmOwnership(results.first.bssid);
      }

      setState(() {
        _networks = results;
        _status = 'Found ${results.length} networks - ${results.where((n) => n.riskLevel == RiskLevel.secure).length} secure';
        _isScanning = false;
      });

      // --- Monetization: Show interstitial after scan (Free users only) ---
      if (!_monetization.isPro) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _monetization.showInterstitialAfterScan();
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isScanning = false;
      });
    }
  }

  Future<void> _generatePdfWithReward() async {
    if (_networks.isEmpty) return;

    // Pro users: Direct PDF
    if (_monetization.isPro) {
      var file = await _pdfService.generateReport(_networks);
      Share.shareXFiles([XFile(file.path)], text: 'WanaLab WiFi Audit Report - Professional');
      return;
    }

    // Free users: Show rewarded dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF141C2F),
        title: const Text('Unlock PDF Report', style: TextStyle(color: Colors.white)),
        content: const Text('Watch a short ad to generate professional PDF report for your client. Or upgrade to Pro for unlimited.', style: TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            onPressed: () async {
              Navigator.pop(context);
              bool rewarded = await _monetization.showRewardedForPdf(() async {
                var file = await _pdfService.generateReport(_networks);
                Share.shareXFiles([XFile(file.path)], text: 'WanaLab WiFi Audit Report');
              });
              if (!rewarded) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad not ready, try again in few seconds')));
              }
            },
            child: const Text('Watch Ad & Get PDF', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.secure: return Colors.green;
      case RiskLevel.medium: return Colors.orange;
      case RiskLevel.high: return Colors.deepOrange;
      case RiskLevel.critical: return Colors.red;
    }
  }

  Widget _buildBlockGuide(WiFiNetwork net) {
    // Monetization gold: How to block guide - Free shows ad, Pro direct
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blueGrey.withOpacity(0.3))),
      child: Row(
        children: [
          const Icon(Icons.block, size: 14, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Expanded(child: Text('How to Block: Go to 192.168.1.1 → DHCP → Block MAC ${net.bssid}', style: const TextStyle(color: Colors.white38, fontSize: 10))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Security Auditor - WanaLab'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A0E1A),
        actions: [
          IconButton(
            icon: Icon(_monetization.isPro ? Icons.workspace_premium : Icons.workspace_premium_outlined, color: _monetization.isPro ? Colors.amber : Colors.white54),
            onPressed: () => setState(() => _showPaywall = !_showPaywall),
          ),
          if (_networks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePdfWithReward,
            )
        ],
      ),
      body: Column(
        children: [
          // --- Consent Gate - Required for Google Play ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: OwnerConsentGate(
              onConsentChanged: (v) => setState(() => _hasConsent = v),
            ),
          ),

          if (_showPaywall)
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: ProPaywall()),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF141C2F),
            child: Column(
              children: [
                Text(_status, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  icon: _isScanning ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2, color: Colors.white)) : const Icon(Icons.wifi_find),
                  label: Text(_isScanning ? 'Scanning...' : 'Auto Scan Nearby WiFi'),
                  style: ElevatedButton.styleFrom(backgroundColor: _hasConsent ? const Color(0xFF3B82F6) : Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 8),
                const Text('No input required - Scans automatically\n100% Offline - No data sent to server - By WanaLab', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: _networks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_tethering, size: 64, color: Colors.white12),
                        const SizedBox(height: 12),
                        const Text('No networks yet. Check consent and tap Scan.', style: TextStyle(color: Colors.white54)),
                        const SizedBox(height: 8),
                        if (!_hasConsent) const Text('↑ Please check consent box above ↑', style: TextStyle(color: Colors.orange, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _networks.length,
                    itemBuilder: (context, i) {
                      var net = _networks[i];
                      return Card(
                        color: const Color(0xFF1A2340),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: ListTile(
                            leading: Icon(Icons.wifi, color: _getRiskColor(net.riskLevel)),
                            title: Text(net.ssid, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${net.encryptionType} | ${net.signalStrength} dBm | ${net.bssid}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(net.risks.join(', '), style: TextStyle(color: _getRiskColor(net.riskLevel), fontSize: 12)),
                                _buildBlockGuide(net),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: _getRiskColor(net.riskLevel).withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: _getRiskColor(net.riskLevel))),
                              child: Text(net.riskLabel, style: TextStyle(color: _getRiskColor(net.riskLevel), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ConsentScreen(network: net, allNetworks: _networks))),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // --- Banner Ad - Bottom ---
          if (_bannerAd != null && !_monetization.isPro)
            Container(
              color: const Color(0xFF0A0E1A),
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
