// 原型页面预览入口（临时工具）：
//   flutter run -t lib/main_preview.dart
// 用它可以快速查看 lib/管理后台 下全部原型页面的还原效果。
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
      title: '管理后台原型预览',
      debugShowCheckedModeBanner: false,
      home: const PreviewHome(),
    );
  }
}

class PreviewHome extends StatelessWidget {
  const PreviewHome({super.key});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<PrototypeEntry>>{};
    for (final e in prototypePages) {
      final key = e.path.split('/')[1];
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final keys = grouped.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('管理后台原型预览')),
      body: ListView(
        children: [
          for (final key in keys) ...[
            ExpansionTile(
              title: Text('$key（${grouped[key]!.length} 页）'),
              initiallyExpanded: true,
              children: [
                for (final e in grouped[key]!)
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
        ],
      ),
    );
  }
}
