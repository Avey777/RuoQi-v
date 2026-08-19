import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_partner/main.dart';

void main() {
  testWidgets('Partner home renders', (tester) async {
    await tester.pumpWidget(const PartnerApp());

    expect(find.text('RuoQi 伙伴'), findsOneWidget);
    expect(find.text('合作伙伴中心'), findsOneWidget);
    expect(find.text('partner · v1.0.0'), findsOneWidget);
  });
}
