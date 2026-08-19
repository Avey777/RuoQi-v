import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_app/main.dart';

void main() {
  testWidgets('Platform app home renders', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    expect(find.text('RuoQi 平台 App'), findsOneWidget);
    expect(find.text('平台移动端'), findsOneWidget);
    expect(find.text('platform_app · v1.0.0'), findsOneWidget);
  });
}
