import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_customer_pc/main.dart';

void main() {
  testWidgets('Customer PC home renders', (tester) async {
    await tester.pumpWidget(const CustomerApp());

    expect(find.text('RuoQi 客户'), findsOneWidget);
    expect(find.text('客户门户（PC）'), findsOneWidget);
    expect(find.text('customer_pc · v1.0.0'), findsOneWidget);
  });
}
