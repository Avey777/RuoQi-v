import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_iam_user/main.dart';

void main() {
  testWidgets('IAM login page renders', (tester) async {
    await tester.pumpWidget(const IamUserApp());

    expect(find.text('RuoQi IAM User'), findsOneWidget);
    expect(find.text('IAM 用户登录'), findsOneWidget);
    expect(find.text('登 录'), findsOneWidget);
  });

  testWidgets('Login validates empty fields', (tester) async {
    await tester.pumpWidget(const IamUserApp());

    await tester.tap(find.text('登 录'));
    await tester.pump();

    expect(find.text('请输入用户名'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);
  });
}
