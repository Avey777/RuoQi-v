import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

void main() {
  test('ruoQiTheme builds a Material 3 theme', () {
    final theme = ruoQiTheme();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, isNotNull);
  });

  testWidgets('AppBadge renders app name and version', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppBadge(appName: 'platform', version: '1.0.0')),
      ),
    );
    expect(find.text('platform · v1.0.0'), findsOneWidget);
  });
}
