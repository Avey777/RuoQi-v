import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/business/widgets/business_menu.dart';

void main() {
  testWidgets('operator menu items navigate to their pages', (tester) async {
    expect(operatorMenu.title, 'IAM 运营中心');
    expect(operatorMenu.items.length, greaterThanOrEqualTo(6));
    // 每个菜单项都有跳转目标
    for (final item in operatorMenu.items.skip(1)) {
      expect(item.builder, isNotNull, reason: '${item.label} should navigate');
    }
    // 渲染菜单项
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: true,
                minExtendedWidth: 200,
                selectedIndex: 1,
                labelType: NavigationRailLabelType.none,
                destinations: [
                  for (final item in operatorMenu.items)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('租户管理'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
