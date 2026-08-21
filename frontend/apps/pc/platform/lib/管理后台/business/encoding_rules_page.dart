import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'settings_content_dialog.dart';

/// 单号生成规则。
class EncodingRule {
  const EncodingRule({
    required this.name,
    required this.prefix,
    required this.rule,
    required this.note,
  });

  final String name;
  final String prefix;
  final String rule;
  final String note;
}

/// 单号规则列表（对应 设置-编码规则 原型）。
const encodingRules = [
  EncodingRule(
    name: '销售单号',
    prefix: 'SH',
    rule:
        '1.不重复\n2.纯数字\n3.安全性（不能透露正式的运营信息）\n'
        '4.不能大规模使用随机码\n5.防止并发\n6.控制位数(12～28位)',
    note: '--',
  ),
  EncodingRule(
    name: '售后单号',
    prefix: '--',
    rule:
        '1.不重复\n2.纯数字\n3.安全性（不能透露正式的运营信息）\n'
        '4.不能大规模使用随机码\n5.防止并发\n6.控制位数(12～16位)',
    note: 'eg：日期 + 自增长数字的售后单号',
  ),
  EncodingRule(
    name: '商品编号(ASIN)',
    prefix: '186',
    rule:
        '1.不重复\n2.数字、大写英文字母\n3.安全性（不能透露正式的运营信息）\n'
        '4.不能大规模使用随机码\n5.防止并发\n6.控制位数(10～13位)',
    note:
        '1 代表 C 端商城，86 代表中国站点。'
        '设备号15(取最后10位)+10位时间戳+序号(同一时间戳时自动排序，'
        '限制两位；超出两位数需要用户安全验证后重新生成)。',
  ),
  EncodingRule(
    name: 'FNSKU\n(Fulfillment Network Stock Keeping Unit)',
    prefix: '--',
    rule:
        '1.不重复\n2.数字、大写英文字母\n3.安全性（不能透露正式的运营信息）\n'
        '4.不能大规模使用随机码\n5.防止并发\n6.控制位数(8～13位)',
    note: '· 产品标签编码',
  ),
  EncodingRule(
    name: '货品箱码（箱唛号）',
    prefix: '--',
    rule:
        '1.不重复\n2.(大写英文字母 CTN) + 纯数字\n'
        '3.安全性（不能透露正式的运营信息）\n4.不能大规模使用随机码\n'
        '5.防止并发\n6.控制位数(10～18位)',
    note: 'eg：CTN20220202010305',
  ),
  EncodingRule(
    name: '批次号',
    prefix: 'BN',
    rule:
        '1.不重复\n2.(大写英文字母 BN) + 纯数字\n'
        '3.安全性（不能透露正式的运营信息）\n4.不能大规模使用随机码\n'
        '5.防止并发\n6.控制位数(10～18位)',
    note: '批次号：batch number\neg：BN20220202010305',
  ),
];

/// 设置-编码规则 业务正文（替换静态原型复刻页）。
class EncodingRulesBody extends StatelessWidget {
  const EncodingRulesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          '编码规则',
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          '系统所有单号生成规则，以及单号前缀。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 表头：占满内容区宽度
              Container(
                color: theme.colorScheme.surfaceContainerHigh,
                padding: const EdgeInsets.symmetric(
                  horizontal: RuQiSpacing.lg,
                  vertical: RuQiSpacing.sm,
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 15, child: _ColumnHeader('名称')),
                    Expanded(flex: 9, child: _ColumnHeader('单号前缀')),
                    Expanded(flex: 30, child: _ColumnHeader('生成单号规则')),
                    Expanded(flex: 30, child: _ColumnHeader('说明')),
                    Expanded(flex: 13, child: _ColumnHeader('操作')),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              for (final (i, rule) in encodingRules.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RuQiSpacing.lg,
                    vertical: RuQiSpacing.md,
                  ),
                  decoration: i == encodingRules.length - 1
                      ? null
                      : BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                        ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 15,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            rule.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            rule.prefix,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            rule.rule,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(right: RuQiSpacing.sm),
                          child: Text(
                            rule.note,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 13,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton(
                            onPressed: () =>
                                showEncodingRuleEditDialog(context, rule),
                            style: RuQiButtonStyles.secondary(context),
                            child: const Text('编辑'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: RuQiSpacing.sm),
        Text(
          '共 ${encodingRules.length} 条 · 10条/页',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 打开单号规则编辑面板（与内容区同尺寸，无阴影遮罩、右侧滑入）。
Future<void> showEncodingRuleEditDialog(
  BuildContext context,
  EncodingRule rule,
) {
  return showSystemSettingsPanel(
    context,
    title: '${rule.name.replaceAll('\n', ' ')} 编辑',
    child: EncodingRuleEditForm(rule: rule),
  );
}

/// 单号规则编辑表单（标题条与关闭按钮由设置面板提供）。
class EncodingRuleEditForm extends StatefulWidget {
  const EncodingRuleEditForm({super.key, required this.rule});

  final EncodingRule rule;

  @override
  State<EncodingRuleEditForm> createState() => _EncodingRuleEditFormState();
}

class _EncodingRuleEditFormState extends State<EncodingRuleEditForm> {
  late final TextEditingController _name;
  late final TextEditingController _prefix;
  late final TextEditingController _rule;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.rule.name.replaceAll('\n', ' '));
    _prefix = TextEditingController(text: widget.rule.prefix);
    _rule = TextEditingController(text: widget.rule.rule);
    _note = TextEditingController(text: widget.rule.note);
  }

  @override
  void dispose() {
    _name.dispose();
    _prefix.dispose();
    _rule.dispose();
    _note.dispose();
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
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    helperText: '规则名称，如 销售单号、批次号。',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _prefix,
                  decoration: InputDecoration(
                    labelText: '单号前缀',
                    helperText: '用于单号开头的大写字母 / 数字前缀。',
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _prefix,
                      builder: (context, value, _) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: RuQiSpacing.sm,
                        ),
                        child: Center(
                          child: Text(
                            value.text.isEmpty ? '--' : value.text,
                            style: RuQiTextStyles.mono.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _rule,
                  maxLines: 7,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  decoration: const InputDecoration(
                    labelText: '生成单号规则',
                    alignLabelWithHint: true,
                    helperText: '逐条列出生成约束，每行一条。',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '说明',
                    alignLabelWithHint: true,
                    helperText: '补充说明或示例，如 eg：BN20220202010305。',
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            RuQiSpacing.lg,
            RuQiSpacing.sm,
            RuQiSpacing.lg,
            RuQiSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: RuQiButtonStyles.tertiary(context),
                child: const Text('取消'),
              ),
              const SizedBox(width: RuQiSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: RuQiButtonStyles.primary(context),
                child: const Text('保存生效'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
