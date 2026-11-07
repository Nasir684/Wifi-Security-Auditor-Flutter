import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/wifi_network.dart';

class PdfService {
  Future<File> generateReport(List<WiFiNetwork> networks, {String? testedSsid, Map<String, dynamic>? testResult}) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('WiFi Security Auditor Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text('Date: ${now.toString().split('.')[0]}', style: const pw.TextStyle(fontSize: 12)),
          pw.Text('Generated Offline - No Data Sent to Server', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          pw.SizedBox(height: 20),

          pw.Text('Summary:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.Text('Total Networks Scanned: ${networks.length}'),
          pw.Text('Critical: ${networks.where((n) => n.riskLevel == RiskLevel.critical).length}'),
          pw.Text('High: ${networks.where((n) => n.riskLevel == RiskLevel.high).length}'),
          pw.Text('Secure: ${networks.where((n) => n.riskLevel == RiskLevel.secure).length}'),
          pw.SizedBox(height: 20),

          if (testedSsid != null && testResult != null) ...[
            pw.Text('Authorized Own Network Test:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('SSID: $testedSsid'),
            pw.Text('Result: ${testResult['message']}'),
            pw.SizedBox(height: 20),
          ],

          pw.Text('Detailed Findings:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 10),

          ...networks.map((net) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SSID: ${net.ssid} | ${net.riskLabel} | ${net.encryptionType}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('BSSID: ${net.bssid} | Signal: ${net.signalStrength} dBm'),
                    pw.Text('Risks: ${net.risks.join(', ')}'),
                    pw.Text('Recommendation: ${net.recommendation}', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              )),
          pw.SizedBox(height: 30),
          pw.Text('Disclaimer: This report is for educational and authorized auditing only. Testing networks without owner permission is illegal.', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          pw.Text('This is an independent project. No data collected.', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wifi_audit_${now.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
