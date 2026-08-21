import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/main.dart';

void main() {
  testWidgets('Platform home shows IDM operator pages', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    expect(find.text('RuoQi-Platform'), findsOneWidget);
    expect(find.text('系统管理'), findsOneWidget);
    expect(find.text('platform_pc · v1.0.0'), findsOneWidget);
  });
}
