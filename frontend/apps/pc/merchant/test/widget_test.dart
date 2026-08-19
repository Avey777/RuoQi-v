import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_merchant_pc/main.dart';

void main() {
  testWidgets('Merchant home shows feature entries', (tester) async {
    await tester.pumpWidget(const MerchantApp());

    expect(find.text('RuoQi 商户'), findsOneWidget);
    expect(find.text('数据概览'), findsOneWidget);
    expect(find.text('仓储管理'), findsOneWidget);
    expect(find.text('店铺管理'), findsOneWidget);
    expect(find.text('商户设置'), findsOneWidget);
    expect(find.text('merchant_pc · v1.0.0'), findsOneWidget);
  });
}
