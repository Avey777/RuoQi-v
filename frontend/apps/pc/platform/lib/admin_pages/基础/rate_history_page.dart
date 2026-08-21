import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import '../shared/status_badge.dart';
import '../shared/table_card.dart';
import '../用户/user_management_widgets.dart';

/// 历史汇率。
class RateHistory {
  const RateHistory({
    required this.type,
    required this.from,
    required this.to,
    required this.originalRate,
    required this.rateFloat,
    required this.siteRate,
    required this.effectiveAt,
    required this.expireAt,
    required this.account,
    required this.createdAt,
    this.enabled = true,
  });

  final String type;
  final String from;
  final String to;
  final String originalRate;
  final String rateFloat;
  final String siteRate;
  final String effectiveAt;
  final String expireAt;
  final String account;
  final String createdAt;
  final bool enabled;
}

const rateHistories = [
  RateHistory(type: '固定汇率', from: 'USD', to: 'CNY', originalRate: '0.900220', rateFloat: '+0.00020', siteRate: '0.900222', effectiveAt: '2022/02/02 02:02:03', expireAt: '2022/03/02 02:02:03', account: 'account1', createdAt: '2022/02/02 02:02:03'),
  RateHistory(type: '实时汇率(Xe)', from: 'USD', to: 'GHS', originalRate: '8.200000', rateFloat: '+0.23156', siteRate: '8.362565', effectiveAt: '2022/02/02 02:02:03', expireAt: '--', account: 'account2', createdAt: '2022/02/02 02:02:03'),
  RateHistory(type: '固定汇率', from: 'USD', to: 'VND', originalRate: '23650.00', rateFloat: '-0.321563', siteRate: '23620.00', effectiveAt: '2021/12/01 00:00:00', expireAt: '2022/01/01 00:00:00', account: 'account2', createdAt: '2021/11/30 10:00:00', enabled: false),
];

/// 基础-历史汇率 业务正文（对应 历史汇率 原型）。
class RateHistoryBody extends StatelessWidget {
  const RateHistoryBody({super.key});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: RuQiMotion.normal),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    RateHistory rate,
    String action,
  ) async {
    switch (action) {
      case '编辑':
        await showRateHistoryEditPanel(context, rate: rate);
      case '启用':
        _showSnack(context, '已启用该汇率记录');
      case '停用':
        _showSnack(context, '已停用该汇率记录');
      case '删除':
        _showSnack(context, '已删除该汇率记录');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        UserPageHeader(
          title: '历史汇率',
          description: '查看与维护各货币对的历史汇率记录。',
          actionLabel: '添加',
          onAction: () => showRateHistoryEditPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '汇率类型', flex: 10),
            (label: '原货币', flex: 7),
            (label: '目标货币', flex: 7),
            (label: '原汇率', flex: 8),
            (label: '汇率浮动', flex: 8),
            (label: '网站汇率', flex: 8),
            (label: '生效时间', flex: 13),
            (label: '结束时间', flex: 13),
            (label: '操作账号', flex: 9),
            (label: '状态', flex: 7),
            (label: '操作', flex: 16),
          ],
          rowCount: rateHistories.length,
          rowBuilder: (context, index) {
            final rate = rateHistories[index];
            return [
              CellText(rate.type, strong: true),
              CellText(rate.from, muted: true),
              CellText(rate.to, muted: true),
              CellText(rate.originalRate, muted: true),
              CellText(rate.rateFloat, muted: true),
              CellText(rate.siteRate, muted: true),
              CellText(rate.effectiveAt, muted: true),
              CellText(rate.expireAt, muted: true),
              CellText(rate.account, muted: true),
              StatusBadge(
                label: rate.enabled ? '启用中' : '已停用',
                tone: rate.enabled ? StatusTone.success : StatusTone.neutral,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, rate, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(
                      context,
                      rate,
                      rate.enabled ? '停用' : '启用',
                    ),
                    child: Text(rate.enabled ? '停用' : '启用'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, rate, '删除'),
                    child: Text(
                      '删除',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
        const SizedBox(height: RuQiSpacing.md),
        UserPagination(total: 125),
      ],
    );
  }
}

/// 打开汇率新增 / 编辑面板。
Future<void> showRateHistoryEditPanel(
  BuildContext context, {
  RateHistory? rate,
}) {
  return showSystemSettingsPanel(
    context,
    title: rate == null ? '添加汇率' : '编辑汇率',
    child: RateHistoryEditForm(rate: rate),
  );
}

/// 汇率新增 / 编辑表单。
class RateHistoryEditForm extends StatefulWidget {
  const RateHistoryEditForm({super.key, this.rate});

  final RateHistory? rate;

  @override
  State<RateHistoryEditForm> createState() => _RateHistoryEditFormState();
}

class _RateHistoryEditFormState extends State<RateHistoryEditForm> {
  late final TextEditingController _from;
  late final TextEditingController _to;
  late final TextEditingController _originalRate;
  late final TextEditingController _rateFloat;
  late final TextEditingController _effectiveAt;
  late final TextEditingController _expireAt;
  late String _type;

  static const _types = ['固定汇率', '实时汇率(Xe)'];
  static const _currencies = ['USD', 'CNY', 'GHS', 'VND', 'ETB'];

  @override
  void initState() {
    super.initState();
    final rate = widget.rate;
    _type = rate?.type ?? '固定汇率';
    _from = TextEditingController(text: rate?.from ?? 'USD');
    _to = TextEditingController(text: rate?.to ?? '');
    _originalRate = TextEditingController(text: rate?.originalRate ?? '');
    _rateFloat = TextEditingController(text: rate?.rateFloat ?? '');
    _effectiveAt = TextEditingController(text: rate?.effectiveAt ?? '');
    _expireAt = TextEditingController(text: rate?.expireAt == '--' ? '' : (rate?.expireAt ?? ''));
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _originalRate.dispose();
    _rateFloat.dispose();
    _effectiveAt.dispose();
    _expireAt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: '汇率类型'),
                  items: [
                    for (final type in _types)
                      DropdownMenuItem(value: type, child: Text(type)),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _from.text,
                        decoration: const InputDecoration(labelText: '原货币'),
                        items: [
                          for (final code in _currencies)
                            DropdownMenuItem(value: code, child: Text(code)),
                        ],
                        onChanged: (v) =>
                            setState(() => _from.text = v ?? _from.text),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _to.text.isEmpty ? null : _to.text,
                        decoration: const InputDecoration(labelText: '目标货币'),
                        items: [
                          for (final code in _currencies)
                            DropdownMenuItem(value: code, child: Text(code)),
                        ],
                        onChanged: (v) =>
                            setState(() => _to.text = v ?? _to.text),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _originalRate,
                        decoration: const InputDecoration(labelText: '原汇率'),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _rateFloat,
                        decoration: const InputDecoration(labelText: '汇率浮动'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _effectiveAt,
                        decoration: const InputDecoration(
                          labelText: '生效时间',
                          hintText: '如 2022/02/02 02:02:03',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _expireAt,
                        decoration: const InputDecoration(
                          labelText: '结束时间',
                          hintText: '留空表示不结束',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.rate == null ? '添加' : '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
