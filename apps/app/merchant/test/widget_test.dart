import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_merchant_app/main.dart';

void main() {
  testWidgets('Merchant app home renders', (tester) async {
    await tester.pumpWidget(const MerchantApp());

    expect(find.text('RuoQi 商户 App'), findsOneWidget);
    expect(find.text('数据概览'), findsOneWidget);
    expect(find.text('仓储管理'), findsOneWidget);
    expect(find.text('merchant_app · v1.0.0'), findsOneWidget);
  });
}
