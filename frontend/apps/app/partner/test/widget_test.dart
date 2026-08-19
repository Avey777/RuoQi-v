import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_partner_app/main.dart';

void main() {
  testWidgets('Partner app home renders', (tester) async {
    await tester.pumpWidget(const PartnerApp());

    expect(find.text('RuoQi 伙伴 App'), findsOneWidget);
    expect(find.text('伙伴移动端'), findsOneWidget);
    expect(find.text('partner_app · v1.0.0'), findsOneWidget);
  });
}
