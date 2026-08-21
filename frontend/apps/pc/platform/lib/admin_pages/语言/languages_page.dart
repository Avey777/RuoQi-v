import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import '../shared/status_badge.dart';
import '../shared/table_card.dart';
import '../用户/user_management_widgets.dart';

/// 多语言。
class Language {
  const Language({
    required this.code,
    required this.code2,
    required this.code3,
    required this.nativeName,
    required this.sort,
    this.isBase = false,
    this.enabled = true,
  });

  final String code;
  final String code2;
  final String code3;
  final String nativeName;
  final int sort;
  final bool isBase;
  final bool enabled;
}

const languages = [
  Language(code: 'zh_CN', code2: 'zh', code3: 'zho', nativeName: '简体中文-中国大陆', sort: 1, isBase: true),
  Language(code: 'en_US', code2: 'en', code3: 'eng', nativeName: 'English(US)', sort: 2),
  Language(code: 'fr_FR', code2: 'fr', code3: 'fra', nativeName: 'Français', sort: 3),
  Language(code: 'pt-PT', code2: 'pt', code3: 'por', nativeName: 'português', sort: 4),
  Language(code: 'ru-RU', code2: 'ru', code3: 'rus', nativeName: 'русский (Россия)', sort: 5),
  Language(code: 'VN-VI', code2: 'vi', code3: 'vie', nativeName: 'Tiếng Việt', sort: 6, enabled: false),
];

/// 语言-多语言 业务正文（对应 多语言 原型）。
class LanguagesBody extends StatelessWidget {
  const LanguagesBody({super.key});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: RuQiMotion.normal),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Language language,
    String action,
  ) async {
    switch (action) {
      case '编辑':
        await showLanguageEditPanel(context, language: language);
      case '启用':
        _showSnack(context, '已启用 ${language.nativeName}');
      case '停用':
        _showSnack(context, '已停用 ${language.nativeName}');
      case '删除':
        final confirmed = await showLanguageDeleteConfirm(context, language);
        if (confirmed == true && context.mounted) {
          _showSnack(context, '已删除 ${language.nativeName}');
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
          title: '多语言',
          description: '维护平台支持的界面语言与录入状态。',
          actionLabel: '添加',
          onAction: () => showLanguageEditPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '语言代码', flex: 10),
            (label: '两字母代码', flex: 8),
            (label: '三字母代码', flex: 8),
            (label: '语言自称', flex: 16),
            (label: '排序', flex: 6),
            (label: '基本语言', flex: 8),
            (label: '状态', flex: 7),
            (label: '操作', flex: 20),
          ],
          rowCount: languages.length,
          rowBuilder: (context, index) {
            final language = languages[index];
            return [
              CellText(language.code, strong: true),
              CellText(language.code2, muted: true),
              CellText(language.code3, muted: true),
              CellText(language.nativeName),
              CellText('${language.sort}', muted: true),
              Text(
                language.isBase ? '是' : '否',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: language.isBase
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: language.isBase ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              StatusBadge(
                label: language.enabled ? '启用中' : '已停用',
                tone: language.enabled ? StatusTone.success : StatusTone.neutral,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, language, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(
                      context,
                      language,
                      language.enabled ? '停用' : '启用',
                    ),
                    child: Text(language.enabled ? '停用' : '启用'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, language, '删除'),
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

/// 打开语言新增 / 编辑面板。
Future<void> showLanguageEditPanel(
  BuildContext context, {
  Language? language,
}) {
  return showSystemSettingsPanel(
    context,
    title: language == null ? '添加语言' : '编辑语言',
    child: LanguageEditForm(language: language),
  );
}

/// 语言新增 / 编辑表单。
class LanguageEditForm extends StatefulWidget {
  const LanguageEditForm({super.key, this.language});

  final Language? language;

  @override
  State<LanguageEditForm> createState() => _LanguageEditFormState();
}

class _LanguageEditFormState extends State<LanguageEditForm> {
  late final TextEditingController _code;
  late final TextEditingController _code2;
  late final TextEditingController _code3;
  late final TextEditingController _nativeName;
  late final TextEditingController _sort;
  bool _isBase = false;

  @override
  void initState() {
    super.initState();
    final language = widget.language;
    _code = TextEditingController(text: language?.code ?? '');
    _code2 = TextEditingController(text: language?.code2 ?? '');
    _code3 = TextEditingController(text: language?.code3 ?? '');
    _nativeName = TextEditingController(text: language?.nativeName ?? '');
    _sort = TextEditingController(text: '${language?.sort ?? 1}');
    _isBase = language?.isBase ?? false;
  }

  @override
  void dispose() {
    _code.dispose();
    _code2.dispose();
    _code3.dispose();
    _nativeName.dispose();
    _sort.dispose();
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
                TextField(
                  controller: _code,
                  decoration: const InputDecoration(
                    labelText: '*语言代码',
                    hintText: '如 zh_CN',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code2,
                        decoration: const InputDecoration(
                          labelText: '两字母代码',
                          hintText: '如 zh',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _code3,
                        decoration: const InputDecoration(
                          labelText: '三字母代码',
                          hintText: '如 zho',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _nativeName,
                  decoration: const InputDecoration(
                    labelText: '语言自称',
                    hintText: '如 简体中文-中国大陆',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sort,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '排序'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                SwitchListTile(
                  value: _isBase,
                  onChanged: (v) => setState(() => _isBase = v),
                  title: const Text('设为基本语言'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.language == null ? '添加' : '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// 语言删除确认对话框。
Future<bool?> showLanguageDeleteConfirm(
  BuildContext context,
  Language language,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('删除语言'),
        content: Text('确定删除语言「${language.nativeName}」吗？翻译内容将一并删除。'),
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
