import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import '../shared/status_badge.dart';
import '../shared/table_card.dart';
import '../用户/user_management_widgets.dart';

/// 翻译条目。
class TranslationKey {
  const TranslationKey({
    required this.key,
    required this.zh,
    required this.en,
    required this.translated,
  });

  final String key;
  final String zh;
  final String en;
  final bool translated;
}

const translationKeys = [
  TranslationKey(key: 'EvaluationTime', zh: '评价时间', en: 'EvaluationTime', translated: true),
  TranslationKey(key: 'Tools.MarkedRead', zh: '标为已读', en: 'Mark as read', translated: true),
  TranslationKey(key: 'Settings.Profile', zh: '个人资料', en: 'Profile', translated: true),
  TranslationKey(key: 'Payment.Success', zh: '支付成功', en: 'Payment succeeded', translated: true),
  TranslationKey(key: 'Invite.EmailSubject', zh: '我们邀请您加入 \${Site Name}', en: '', translated: false),
  TranslationKey(key: 'Verify.SmsBody', zh: '', en: '', translated: false),
];

/// 语言-翻译 业务正文（对应 翻译 原型）。
class TranslationsBody extends StatefulWidget {
  const TranslationsBody({super.key});

  @override
  State<TranslationsBody> createState() => _TranslationsBodyState();
}

class _TranslationsBodyState extends State<TranslationsBody> {
  String _query = '';

  List<TranslationKey> get _filtered {
    final q = _query.trim();
    return [
      for (final item in translationKeys)
        if (q.isEmpty || item.key.toLowerCase().contains(q.toLowerCase()))
          item,
    ];
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: RuQiMotion.normal),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '翻译',
          description: '维护各语言下的文案翻译。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Filter...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: RuQiSpacing.md),
            TextButton(
              style: RuQiButtonStyles.tertiary(context),
              onPressed: () {},
              child: const Text('未翻译'),
            ),
            TextButton(
              style: RuQiButtonStyles.tertiary(context),
              onPressed: () {},
              child: Text(
                '已翻译',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: 'Keys', flex: 20),
            (label: '简体中文', flex: 18),
            (label: 'English', flex: 18),
            (label: '状态', flex: 8),
            (label: '操作', flex: 18),
          ],
          rowCount: _filtered.length,
          emptyText: '无匹配翻译',
          rowBuilder: (context, index) {
            final item = _filtered[index];
            return [
              CellText(item.key, strong: true),
              CellText(item.zh.isEmpty ? '--' : item.zh),
              CellText(item.en.isEmpty ? '--' : item.en, muted: true),
              StatusBadge(
                label: item.translated ? '已翻译' : '未翻译',
                tone: item.translated ? StatusTone.success : StatusTone.warning,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => showTranslationEditPanel(context, item),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => showTranslationHistoryPanel(context, item),
                    child: const Text('历史'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _showSnack(context, '已标记为已读'),
                    child: const Text('标记已读'),
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

/// 打开翻译编辑面板。
Future<void> showTranslationEditPanel(
  BuildContext context,
  TranslationKey item,
) {
  return showSystemSettingsPanel(
    context,
    title: item.key,
    child: TranslationEditForm(item: item),
  );
}

/// 翻译编辑表单：各语言文案。
class TranslationEditForm extends StatefulWidget {
  const TranslationEditForm({super.key, required this.item});

  final TranslationKey item;

  @override
  State<TranslationEditForm> createState() => _TranslationEditFormState();
}

class _TranslationEditFormState extends State<TranslationEditForm> {
  late final TextEditingController _zh;
  late final TextEditingController _en;

  @override
  void initState() {
    super.initState();
    _zh = TextEditingController(text: widget.item.zh);
    _en = TextEditingController(text: widget.item.en);
  }

  @override
  void dispose() {
    _zh.dispose();
    _en.dispose();
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
                  'Key：${widget.item.key}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _zh,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '简体中文',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _en,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'English',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: '保存',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// 打开翻译历史面板。
Future<void> showTranslationHistoryPanel(
  BuildContext context,
  TranslationKey item,
) {
  return showSystemSettingsPanel(
    context,
    title: '${item.key} 历史',
    child: const TranslationHistoryForm(),
  );
}

/// 翻译历史：版本列表。
class TranslationHistoryForm extends StatelessWidget {
  const TranslationHistoryForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        for (final revision in const [
          ('12/12/2022 08:05', '已翻译 · account1', '简体中文：评价时间'),
          ('12/11/2022 18:20', '已翻译 · account2', '简体中文：评价 时间'),
          ('12/10/2022 09:40', '已创建 · account1', '简体中文：--'),
        ]) ...[
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(RuQiSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          revision.$1,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.xxs),
                        Text(
                          revision.$2,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: RuQiSpacing.xxs),
                        Text(
                          revision.$3,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
        ],
      ],
    );
  }
}
