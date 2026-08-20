import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/business/system_settings_dialog.dart';

void main() {
  Future<void> openDialog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    SystemSettingsDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
  }

  // 找到位于顶部导航栏（y < 65）内的指定文本。
  bool inTopBar(WidgetTester tester, String label) {
    for (final e in find.text(label).evaluate()) {
      final box = e.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.top < 65) {
        return true;
      }
    }
    return false;
  }

  // 找到位于左侧导航栏（x < 100 且 y > 170）内的指定文本。
  bool inSidebar(WidgetTester tester, String label) {
    for (final e in find.text(label).evaluate()) {
      final box = e.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.left < 300 && rect.top > 170) {
        return true;
      }
    }
    return false;
  }

  // 找到位于内容区（左侧菜单 300px 之外）内的指定文本。
  bool inContent(WidgetTester tester, String label) {
    for (final e in find.text(label).evaluate()) {
      final box = e.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.left >= 300 && rect.top > 145) {
        return true;
      }
    }
    return false;
  }

  testWidgets('系统管理弹窗还原管理后台顶部导航与左侧导航', (tester) async {
    await openDialog(tester);

    // 顶部导航（样式还原自 管理后台 原型）
    expect(inTopBar(tester, 'XX管理后台'), isTrue);
    for (final tab in ['设置', '用户', '权限', '菜单', '基础', '语言', '日志']) {
      expect(inTopBar(tester, tab), isTrue, reason: '顶部 Tab 应有 $tab');
    }
    expect(inTopBar(tester, '退出管理'), isTrue);
    // 左侧菜单带搜索框（参照 权限 页）
    expect(find.text('搜索菜单'), findsOneWidget);

    // 默认选中 设置：左侧导航为设置板块的子菜单
    for (final item in ['通用', '本地化', '电子邮件', '编码规则', '短信', 'auth登录', '验证消息']) {
      expect(inSidebar(tester, item), isTrue, reason: '设置侧栏应有 $item');
    }
    expect(tester.takeException(), isNull);

    // 切换到 用户：侧栏变为 用户 / 角色
    await tester.tap(find.text('用户').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inSidebar(tester, '用户'), isTrue);
    expect(inSidebar(tester, '角色'), isTrue);
    expect(inSidebar(tester, 'auth登录'), isFalse);

    // 切换到 日志：侧栏变为 4 个日志项
    await tester.tap(find.text('日志').hitTestable().first);
    await tester.pumpAndSettle();
    for (final item in ['验证日志', '操作日志', '登录日志', '支付日志']) {
      expect(inSidebar(tester, item), isTrue, reason: '日志侧栏应有 $item');
    }
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('权限 板块使用其自身的左侧面板裁切', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('权限').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inSidebar(tester, '权限'), isTrue);
    expect(inSidebar(tester, '保存权限'), isTrue);

    await tester.tap(find.text('保存权限').hitTestable().first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('内容区按页面实际边界裁切，关键元素不被裁掉', (tester) async {
    await openDialog(tester);

    // 短信 页的卡片从画布 x=250 开始，旧固定裁切会切掉左边 10px
    await tester.tap(find.text('短信').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inContent(tester, '阿里云短信'), isTrue);
    expect(tester.takeException(), isNull);

    // 时区 页右上角 编辑 按钮位于 y=138，旧裁切会切掉顶部
    await tester.tap(find.text('基础').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('UTC').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inContent(tester, '编辑'), isTrue);
    expect(tester.takeException(), isNull);

    // 编码规则 页标题从 x=244 开始，旧裁切会切掉左侧
    await tester.tap(find.text('设置').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('编码规则').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inContent(tester, '编码规则'), isTrue);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('点击左侧导航项切换内容区且不抛异常', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('基础').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inSidebar(tester, '货币'), isTrue);
    await tester.tap(find.text('货币').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inSidebar(tester, '历史汇率'), isTrue);
    await tester.tap(find.text('历史汇率').hitTestable().first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('长页面按宽度适配显示，不再被整体缩小', (tester) async {
    await openDialog(tester);

    // 本地化 页内容很高（2776px），旧实现会缩到 30% 左右看不清
    await tester.tap(find.text('本地化').hitTestable().first);
    await tester.pumpAndSettle();

    final textFinder = find.text('默认语言');
    expect(textFinder, findsWidgets);
    final box =
        textFinder.evaluate().first.renderObject! as RenderBox;
    final size = box.size;
    // 内容按宽度适配后字号应接近原始设计尺寸（14px * 缩放），不会被缩成几像素
    expect(size.height, greaterThan(14), reason: '本地化内容不应被缩小');
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });
}
