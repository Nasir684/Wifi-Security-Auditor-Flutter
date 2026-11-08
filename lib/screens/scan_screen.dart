import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/wifi_network.dart';
import '../services/admob_service.dart';
import '../services/wifi_service.dart';
import '../widgets/banner_ad_widget.dart';
import 'consent_screen.dart';
import 'report_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final WiFiService _wifiService = WiFiService();
  List<WiFiNetwork> _networks = const [];
  bool _isScanning = false;
  String? _errorMessage;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = AdMobService.createBanner(
      onLoaded: () => setState(() {}),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _scanNetworks() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });

    try {
      final networks = await _wifiService.scanNetworks();
      if (!mounted) return;
      setState(() {
        _networks = networks;
        _isScanning = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Security Auditor'),
        actions: [
          if (_networks.isNotEmpty)
            IconButton(
              tooltip: 'View audit report',
              icon: const Icon(Icons.assessment_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ReportScreen(networks: _networks),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isScanning ? null : _scanNetworks,
                  icon: _isScanning
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_find),
                  label: Text(_isScanning ? 'Scanning…' : 'Scan nearby WiFi networks'),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_networks.isEmpty && !_isScanning && _errorMessage == null)
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Scan nearby networks to review their security. Only audit networks you own or have permission to test.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _networks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final network = _networks[index];
                    final color = _riskColor(network.riskLevel);
                    return ListTile(
                      leading: Icon(Icons.wifi, color: color),
                      title: Text(
                        network.ssid.isEmpty ? '<Hidden Network>' : network.ssid,
                      ),
                      subtitle: Text(
                        '${network.encryptionType} · ${network.signalStrength} dBm',
                      ),
                      trailing: Text(
                        network.riskLabel,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ConsentScreen(
                            network: network,
                            allNetworks: _networks,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_bannerAd != null)
              SafeArea(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
