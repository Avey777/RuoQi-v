// 原型页面预览入口（临时工具）：
//   flutter run -t lib/main_preview.dart
// 用它可以快速查看 lib 下全部原型页面（管理后台 / 运营后台）的还原效果。
import 'package:flutter/material.dart';

import 'prototype_registry.dart';
import 'prototype_viewer.dart';

void main() {
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '原型预览',
      debugShowCheckedModeBanner: false,
      home: const PreviewHome(),
    );
  }
}

class PreviewHome extends StatelessWidget {
  const PreviewHome({super.key});

  @override
  Widget build(BuildContext context) {
    // 按模块（管理后台 / 运营后台）→ 板块 分组展示
    final grouped = <String, Map<String, List<PrototypeEntry>>>{};
    for (final e in prototypePages) {
      final parts = e.path.split('/');
      final module = parts.length > 1 ? parts[0] : '其他';
      final section = parts.length > 2 ? parts[1] : '其他';
      grouped.putIfAbsent(module, () => {});
      grouped[module]!.putIfAbsent(section, () => []).add(e);
    }
    final modules = grouped.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('原型预览')),
      body: ListView(
        children: [
          for (final module in modules) ...[
            ExpansionTile(
              title: Text(module),
              initiallyExpanded: true,
              children: [
                for (final section in grouped[module]!.keys.toList()..sort())
                  ExpansionTile(
                    title: Text('$section（${grouped[module]![section]!.length} 页）'),
                    initiallyExpanded: true,
                    children: [
                      for (final e in grouped[module]![section]!)
                        ListTile(
                          dense: true,
                          title: Text(e.title),
                          subtitle: Text(e.path, maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PrototypeViewer(entry: e)),
                            );
                          },
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
