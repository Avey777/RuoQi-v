import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform/main.dart';

void main() {
  testWidgets('Platform home shows app name and badge', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    expect(find.text('RuoQi Platform'), findsOneWidget);
    expect(find.text('平台服务'), findsOneWidget);
    expect(find.text('platform · v1.0.0'), findsOneWidget);
  });
}
