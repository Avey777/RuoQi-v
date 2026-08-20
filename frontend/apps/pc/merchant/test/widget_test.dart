import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_merchant_pc/main.dart';

void main() {
  testWidgets('Merchant home shows IDM tenant pages', (tester) async {
    await tester.pumpWidget(const MerchantApp());

    expect(find.text('RuoQi 商户(PC) — IDM 租户业务页面'), findsOneWidget);
    expect(find.text('自建应用'), findsOneWidget);
    expect(find.text('merchant_pc · v1.0.0'), findsOneWidget);
  });
}
