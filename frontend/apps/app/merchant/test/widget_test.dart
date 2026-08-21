import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_merchant_app/main.dart';

void main() {
  testWidgets('Merchant app home shows IDM tenant pages', (tester) async {
    await tester.pumpWidget(const MerchantApp());

    expect(find.text('RuoQi 商户(App) — IDM 租户业务页面'), findsOneWidget);
    expect(find.text('登录方式选择'), findsOneWidget);
    expect(find.text('merchant_app · v1.0.0'), findsOneWidget);
  });
}
