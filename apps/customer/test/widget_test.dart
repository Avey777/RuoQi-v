import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_customer/main.dart';

void main() {
  testWidgets('Customer login page renders', (tester) async {
    await tester.pumpWidget(const CustomerApp());

    expect(find.text('RuoQi 客户'), findsOneWidget);
    expect(find.text('客户登录'), findsOneWidget);
    expect(find.text('登 录'), findsOneWidget);
  });

  testWidgets('Login validates empty fields', (tester) async {
    await tester.pumpWidget(const CustomerApp());

    await tester.tap(find.text('登 录'));
    await tester.pump();

    expect(find.text('请输入用户名'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);
  });
}
