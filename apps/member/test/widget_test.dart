import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_member/main.dart';

void main() {
  testWidgets('Member login page renders', (tester) async {
    await tester.pumpWidget(const MemberApp());

    expect(find.text('RuoQi 会员'), findsOneWidget);
    expect(find.text('会员登录'), findsOneWidget);
    expect(find.text('登 录'), findsOneWidget);
  });

  testWidgets('Login validates empty fields', (tester) async {
    await tester.pumpWidget(const MemberApp());

    await tester.tap(find.text('登 录'));
    await tester.pump();

    expect(find.text('请输入用户名'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);
  });
}
