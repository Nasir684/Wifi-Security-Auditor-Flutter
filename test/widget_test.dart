import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_security_auditor/main.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    await tester.pumpWidget(const WiFiAuditorApp());
    expect(find.byType(WiFiAuditorApp), findsOneWidget);
  });
}
