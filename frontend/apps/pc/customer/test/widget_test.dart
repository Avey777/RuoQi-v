import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_customer_pc/main.dart';

void main() {
  testWidgets('Customer PC marketing page renders', (tester) async {
    await tester.pumpWidget(const CustomerApp());

    expect(find.text('一站式身份与订阅管理平台'), findsOneWidget);
    expect(find.text('免费试用 14 天'), findsOneWidget);
    expect(find.text('简单透明的定价'), findsOneWidget);
  });

  testWidgets('marketing page adapts to mobile width without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CustomerApp());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('marketing page renders at wide desktop width', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const CustomerApp());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('defaults to light mode even when system prefers dark',
      (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(const CustomerApp());

    final context = tester.element(find.byType(MaterialApp));
    expect(Theme.of(context).brightness, Brightness.light);
  });
}
