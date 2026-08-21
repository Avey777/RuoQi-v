import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import '../shared/table_card.dart';
import '../用户/user_management_widgets.dart';

/// UTC 时区行。
typedef UtcZoneRow = ({String id, String label, String center, String range});

String _meridian(int offset) {
  if (offset == 0) return '0°';
  if (offset.abs() == 12) return '180°';
  return offset > 0 ? '${offset * 15}°E' : '${-offset * 15}°W';
}

String _range(int offset) {
  if (offset.abs() == 12) return '172.5°E~172.5°W';
  String fmt(double v) {
    final label = v < 0 ? 'W' : 'E';
    final s = v.abs().toStringAsFixed(1).replaceAll('.0', '');
    return '$s°$label';
  }
  final low = offset * 15 - 7.5;
  final high = offset * 15 + 7.5;
  return '${fmt(low)}~${fmt(high)}';
}

final utcZoneRows = <UtcZoneRow>[
  for (var i = 0; i < 24; i++)
    if (i == 0)
      (id: '0', label: 'UTC Z', center: '0°', range: '7.5°W~7.5°E')
    else if (i <= 11)
      (
        id: '$i',
        label: 'UTC +$i',
        center: _meridian(i),
        range: _range(i),
      )
    else if (i == 12)
      (id: '12', label: 'UTC ±12', center: '180°', range: '172.5°E~172.5°W')
    else
      (
        id: '$i',
        label: 'UTC ${i - 24}',
        center: _meridian(i - 24),
        range: _range(i - 24),
      ),
];

/// 基础-UTC 业务正文（对应 时区 原型）。
class UtcBody extends StatelessWidget {
  const UtcBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '协调世界时',
          description: 'UTC 时区划分与中央经线对照。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        Container(
          padding: const EdgeInsets.all(RuQiSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: ext?.info ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: RuQiSpacing.sm),
              Expanded(
                child: Text(
                  '1. 协调世界时（UTC：Coordinated Universal Time），又称世界统一时间、'
                  '世界标准时间；\n2. 计算的区时 = 已知区时 -（已知区时的时区 - 要计算'
                  '区时的时区）（东时区为正，西时区为负）；\n3. 区时定义：本时区的中央'
                  '经线的地方时（区时是整数的）。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: 'ID', flex: 6),
            (label: '时区', flex: 10),
            (label: '时区中心线', flex: 12),
            (label: '经度范围', flex: 16),
            (label: '操作', flex: 8),
          ],
          rowCount: utcZoneRows.length,
          rowBuilder: (context, index) {
            final row = utcZoneRows[index];
            return [
              CellText(row.id, strong: true),
              CellText(row.label),
              CellText(row.center, muted: true),
              CellText(row.range, muted: true),
              TextButton(
                style: RuQiButtonStyles.tertiary(context),
                onPressed: () => showUtcZoneEditPanel(context, row),
                child: const Text('编辑'),
              ),
            ];
          },
        ),
      ],
    );
  }
}

/// 打开时区编辑面板。
Future<void> showUtcZoneEditPanel(BuildContext context, UtcZoneRow row) {
  return showSystemSettingsPanel(
    context,
    title: '编辑 ${row.label}',
    child: UtcZoneEditForm(row: row),
  );
}

/// 时区编辑表单。
class UtcZoneEditForm extends StatefulWidget {
  const UtcZoneEditForm({super.key, required this.row});

  final UtcZoneRow row;

  @override
  State<UtcZoneEditForm> createState() => _UtcZoneEditFormState();
}

class _UtcZoneEditFormState extends State<UtcZoneEditForm> {
  late final TextEditingController _center;
  late final TextEditingController _range;

  @override
  void initState() {
    super.initState();
    _center = TextEditingController(text: widget.row.center);
    _range = TextEditingController(text: widget.row.range);
  }

  @override
  void dispose() {
    _center.dispose();
    _range.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '时区 ID：${widget.row.id}（${widget.row.label}）',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _center,
                  decoration: const InputDecoration(labelText: '时区中心线'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _range,
                  decoration: const InputDecoration(labelText: '经度范围'),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
