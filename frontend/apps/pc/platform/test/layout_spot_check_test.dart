import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/prototype_registry.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, String id) async {
    final entry = prototypePageById[id]!;
    tester.view.physicalSize = Size(entry.width, entry.height);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Builder(builder: entry.builder),
      ),
    );
    await tester.pump();
  }

  testWidgets('权限页顶部导航与选中条位置', (tester) async {
    await pumpPage(tester, 'c50tDa7pFz');
    // 紫色顶栏
    final bar = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == const Color(0xFF7172AD),
    );
    expect(bar, findsWidgets);
    final rect = tester.getRect(bar.first);
    expect(rect.topLeft, const Offset(0, 0));
    expect(rect.width, 1920);
    // 品牌名
    final brand = tester.getCenter(find.text('XX管理后台'));
    expect(brand.dx, closeTo(100, 2));
    expect(brand.dy, closeTo(32, 2));
  });

  testWidgets('用户列表页侧栏与页面标题', (tester) async {
    await pumpPage(tester, 'StMQ4cWti');
    final sidebar = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == const Color(0xFFEFF1F3),
    );
    expect(sidebar, findsWidgets);
    final rect = tester.getRect(sidebar.first);
    expect(rect.left, closeTo(8, 1));
    expect(rect.width, closeTo(220, 2));
    expect(tester.takeException(), isNull);
  });
}
