import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import '../services/wifi_service.dart';
import 'consent_screen.dart';
import 'report_screen.dart';
import '../settings_page.dart';
import '../about_page.dart';

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
                    builder: (_) => ReportScreen(networks: _networks)),
              ),
            ),
        ],
      ),
      // ADDED DRAWER - Global Monetized + About Wana
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF141C2F), Color(0xFF1A2340)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.security, size: 40, color: Colors.blueAccent),
                  const SizedBox(height: 10),
                  const Text("WiFi Security Auditor",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("WanaLab - Wana, South Waziristan",
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const Text("v1.0.0 Global Monetized",
                      style: TextStyle(fontSize: 10, color: Colors.white54)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wifi_find),
              title: const Text("Scan Networks"),
              subtitle: const Text("Ethical audit mode"),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Developer"),
              subtitle: const Text("Nasir Khan - Wana, S.Waziristan"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text("Ethical Use Only"),
              subtitle: const Text("PECA 2016 Compliant - Own networks only"),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text("Privacy Policy"),
              subtitle: const Text("100% Offline - No data collected"),
            ),
          ],
        ),
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
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.wifi_find),
                  label: Text(
                      _isScanning ? 'Scanning…' : 'Scan nearby WiFi networks'),
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
                      'Scan nearby networks to review their security. Only audit networks you own or have permission to test.\n\nFrom Wana, South Waziristan - Built for technicians worldwide.',
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
                      title: Text(network.ssid.isEmpty
                          ? '<Hidden Network>'
                          : network.ssid),
                      subtitle: Text(
                          '${network.encryptionType} · ${network.signalStrength} dBm'),
                      trailing: Text(network.riskLabel,
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => ConsentScreen(
                                network: network, allNetworks: _networks)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
