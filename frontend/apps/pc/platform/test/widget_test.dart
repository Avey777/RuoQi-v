import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/main.dart';

void main() {
  testWidgets('Platform home shows app name and badge', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    expect(find.text('RuoQi 平台'), findsOneWidget);
    expect(find.text('平台服务'), findsOneWidget);
    expect(find.text('platform_pc · v1.0.0'), findsOneWidget);
  });
}
