import 'package:flutter/material.dart';

import '../prototype_registry.dart';
import '../prototype_viewer.dart';

/// 系统管理（一账通 ID 独立体系）入口弹窗。
///
/// 目前接入原型页面注册表，用于浏览 lib/管理后台 下还原的全部页面；
/// 后续接入真实业务页面时替换这里的列表即可。
class SystemSettingsDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const _SystemSettingsDialog(),
    );
  }
}

class _SystemSettingsDialog extends StatelessWidget {
  const _SystemSettingsDialog();

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<PrototypeEntry>>{};
    for (final e in prototypePages) {
      final parts = e.path.split('/');
      final key = parts.length > 2 ? parts[1] : '其他';
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final keys = grouped.keys.toList()..sort();
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                '系统管理 — 管理后台原型页面',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final key in keys)
                    ExpansionTile(
                      title: Text('$key（${grouped[key]!.length} 页）'),
                      initiallyExpanded: key == '设置',
                      children: [
                        for (final e in grouped[key]!)
                          ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.description_outlined,
                              size: 18,
                            ),
                            title: Text(e.title),
                            subtitle: Text(
                              e.path,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PrototypeViewer(entry: e),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
