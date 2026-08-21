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

  testWidgets('sidebar items exist on section pages', (tester) async {
    final cases = <String, List<String>>{
      'XdvqIaB7_': ['菜单'],
      'X0RCGzKUh': ['世界地理规划', '地区&国家', '导入地区', 'UTC', '时区数据库', '货币', '历史汇率'],
      'u7tmb4OBc': ['多语言', '翻译', '导入', '导出'],
      'WkvHvCC8i': ['验证日志', '操作日志', '登录日志', '支付日志'],
      'to3AHbOfb': ['世界地理规划', '地区&国家', '导入地区', 'UTC', '时区数据库', '货币', '历史汇率'],
      'BYfUtX8cV': ['验证日志', '操作日志', '登录日志', '支付日志'],
      'Eg4MYxW25': ['多语言', '翻译', '导入', '导出'],
      'nR7nqD__k': ['菜单'],
    };
    for (final entry in cases.entries) {
      await pumpPage(tester, entry.key);
      final missing = <String>[];
      final found = <String, Rect>{};
      for (final label in entry.value) {
        final f = find.text(label);
        for (final e in f.evaluate()) {
          final box = e.renderObject! as RenderBox;
          final rect = box.localToGlobal(Offset.zero) & box.size;
          // 侧栏菜单项：位于左侧 x<100、顶部标题区(y>170) 以下
          if (rect.left < 100 && rect.top > 170) {
            found[label] = rect;
            break;
          }
        }
        if (!found.containsKey(label)) missing.add(label);
      }
      debugPrint('page ${entry.key}: missing=$missing');
      for (final e in found.entries) {
        debugPrint('   ${e.key}: ${e.value}');
      }
      expect(missing, isEmpty, reason: '${entry.key} missing sidebar items');
      expect(tester.takeException(), isNull);
    }
  });
}
