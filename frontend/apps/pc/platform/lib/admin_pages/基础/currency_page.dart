import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import '../shared/status_badge.dart';
import '../shared/table_card.dart';
import '../用户/user_management_widgets.dart';

/// 货币。
class Currency {
  const Currency({
    required this.code,
    required this.symbol,
    required this.zhName,
    required this.enName,
    required this.decimals,
    required this.rateFloat,
    required this.siteRate,
    required this.liveRate,
    this.isBase = false,
    this.enabled = true,
  });

  final String code;
  final String symbol;
  final String zhName;
  final String enName;
  final int decimals;
  final String rateFloat;
  final String siteRate;
  final String liveRate;
  final bool isBase;
  final bool enabled;
}

const currencies = [
  Currency(code: 'USD', symbol: r'$', zhName: '美元', enName: 'dollar', decimals: 2, rateFloat: '+0.00020', siteRate: '0.900220', liveRate: '0.900222(xe)'),
  Currency(code: 'CNY', symbol: '¥', zhName: '人民币', enName: 'Chinese Yuan', decimals: 2, rateFloat: '+0.000360', siteRate: '0.820000', liveRate: '0.820000(xe)', isBase: true),
  Currency(code: 'ETB', symbol: 'Br', zhName: '比尔', enName: 'Birr', decimals: 2, rateFloat: '-0.000120', siteRate: '0.063565', liveRate: '0.063565(xe)'),
  Currency(code: 'GHS', symbol: '₵', zhName: '塞地', enName: 'Cedi', decimals: 2, rateFloat: '+0.231560', siteRate: '0.362565', liveRate: '0.362565(xe)'),
  Currency(code: 'VND', symbol: '₫', zhName: '越南盾', enName: 'Vietnamese Dong', decimals: 0, rateFloat: '-0.321563', siteRate: '1.000000', liveRate: '1.000000(xe)', enabled: false),
];

/// 基础-货币 业务正文（对应 货币 原型）。
class CurrencyBody extends StatelessWidget {
  const CurrencyBody({super.key});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: RuQiMotion.normal),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Currency currency,
    String action,
  ) async {
    switch (action) {
      case '编辑':
        await showCurrencyEditPanel(context, currency: currency);
      case '启用':
        _showSnack(context, '已启用 ${currency.zhName}');
      case '停用':
        _showSnack(context, '已停用 ${currency.zhName}');
      case '删除':
        final confirmed = await showCurrencyDeleteConfirm(context, currency);
        if (confirmed == true && context.mounted) {
          _showSnack(context, '已删除 ${currency.zhName}');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        UserPageHeader(
          title: '货币',
          description: '维护平台计价货币与汇率浮动配置。',
          actionLabel: '添加',
          onAction: () => showCurrencyEditPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '货币代码', flex: 8),
            (label: '符号', flex: 6),
            (label: '货币名称', flex: 10),
            (label: '小数位', flex: 6),
            (label: '汇率浮动', flex: 8),
            (label: '网站汇率', flex: 8),
            (label: '实时汇率', flex: 10),
            (label: '基础货币', flex: 8),
            (label: '状态', flex: 7),
            (label: '操作', flex: 18),
          ],
          rowCount: currencies.length,
          rowBuilder: (context, index) {
            final currency = currencies[index];
            return [
              CellText(currency.code, strong: true),
              CellText(currency.symbol, muted: true),
              CellText('${currency.zhName} / ${currency.enName}'),
              CellText('${currency.decimals}', muted: true),
              CellText(currency.rateFloat, muted: true),
              CellText(currency.siteRate, muted: true),
              CellText(currency.liveRate, muted: true),
              Text(
                currency.isBase ? '是' : '无',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: currency.isBase
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: currency.isBase ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              StatusBadge(
                label: currency.enabled ? '启用中' : '已停用',
                tone: currency.enabled ? StatusTone.success : StatusTone.neutral,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, currency, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(
                      context,
                      currency,
                      currency.enabled ? '停用' : '启用',
                    ),
                    child: Text(currency.enabled ? '停用' : '启用'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, currency, '删除'),
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
      ],
    );
  }
}

/// 打开货币新增 / 编辑面板。
Future<void> showCurrencyEditPanel(
  BuildContext context, {
  Currency? currency,
}) {
  return showSystemSettingsPanel(
    context,
    title: currency == null ? '添加货币' : '编辑货币',
    child: CurrencyEditForm(currency: currency),
  );
}

/// 货币新增 / 编辑表单。
class CurrencyEditForm extends StatefulWidget {
  const CurrencyEditForm({super.key, this.currency});

  final Currency? currency;

  @override
  State<CurrencyEditForm> createState() => _CurrencyEditFormState();
}

class _CurrencyEditFormState extends State<CurrencyEditForm> {
  late final TextEditingController _code;
  late final TextEditingController _symbol;
  late final TextEditingController _zhName;
  late final TextEditingController _enName;
  late final TextEditingController _decimals;
  late final TextEditingController _rateFloat;
  bool _isBase = false;

  @override
  void initState() {
    super.initState();
    final currency = widget.currency;
    _code = TextEditingController(text: currency?.code ?? '');
    _symbol = TextEditingController(text: currency?.symbol ?? '');
    _zhName = TextEditingController(text: currency?.zhName ?? '');
    _enName = TextEditingController(text: currency?.enName ?? '');
    _decimals = TextEditingController(text: '${currency?.decimals ?? 2}');
    _rateFloat = TextEditingController(text: currency?.rateFloat ?? '');
    _isBase = currency?.isBase ?? false;
  }

  @override
  void dispose() {
    _code.dispose();
    _symbol.dispose();
    _zhName.dispose();
    _enName.dispose();
    _decimals.dispose();
    _rateFloat.dispose();
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code,
                        decoration: const InputDecoration(
                          labelText: '*货币代码',
                          hintText: '如 USD',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _symbol,
                        decoration: const InputDecoration(
                          labelText: '*符号',
                          hintText: '如 \$',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _zhName,
                  decoration: const InputDecoration(
                    labelText: '货币名称：简体中文',
                    hintText: '如 美元',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _enName,
                  decoration: const InputDecoration(
                    labelText: '英文',
                    hintText: '如 dollar',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _decimals,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '小数位'),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _rateFloat,
                        decoration: const InputDecoration(
                          labelText: '汇率浮动',
                          hintText: '如 +0.00020',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                SwitchListTile(
                  value: _isBase,
                  onChanged: (v) => setState(() => _isBase = v),
                  title: const Text('设为基础货币'),
                  subtitle: const Text('基础货币作为全站汇率的换算锚点。'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.currency == null ? '添加' : '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// 货币删除确认对话框。
Future<bool?> showCurrencyDeleteConfirm(
  BuildContext context,
  Currency currency,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('删除货币'),
        content: Text('确定删除货币「${currency.zhName}（${currency.code}）」吗？'),
        actions: [
          TextButton(
            style: RuQiButtonStyles.tertiary(context),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: RuQiButtonStyles.danger(context),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      );
    },
  );
}
