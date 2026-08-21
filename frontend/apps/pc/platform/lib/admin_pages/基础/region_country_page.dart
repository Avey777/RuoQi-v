import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import '../shared/status_badge.dart';
import '../shared/table_card.dart';
import '../用户/user_management_widgets.dart';

/// 地区 & 国家。
class RegionCountry {
  const RegionCountry({
    required this.zhName,
    required this.code2,
    required this.code3,
    required this.codeNum,
    required this.dialCode,
    required this.continent,
    this.localCode = '--',
    this.enabled = true,
  });

  final String zhName;
  final String code2;
  final String code3;
  final String codeNum;
  final String dialCode;
  final String continent;
  final String localCode;
  final bool enabled;
}

const regionCountries = [
  RegionCountry(zhName: '中国', code2: 'CN', code3: 'CHN', codeNum: '156', dialCode: '86', continent: 'AS1', localCode: 'zh-CN'),
  RegionCountry(zhName: '美国', code2: 'US', code3: 'USA', codeNum: '840', dialCode: '1', continent: 'AS4'),
  RegionCountry(zhName: '越南', code2: 'VN', code3: 'VNM', codeNum: '704', dialCode: '84', continent: 'AS1'),
  RegionCountry(zhName: '加纳', code2: 'GH', code3: 'GHA', codeNum: '288', dialCode: '233', continent: 'AS3'),
  RegionCountry(zhName: '法国', code2: 'FR', code3: 'FRA', codeNum: '250', dialCode: '33', continent: 'AS2'),
  RegionCountry(zhName: '俄罗斯', code2: 'RU', code3: 'RUS', codeNum: '643', dialCode: '7', continent: 'AS2', enabled: false),
];

/// 基础-地区&国家 业务正文（对应 地区&国家 原型）。
class RegionCountryBody extends StatelessWidget {
  const RegionCountryBody({super.key});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: RuQiMotion.normal),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    RegionCountry region,
    String action,
  ) async {
    switch (action) {
      case '编辑':
        await showRegionCountryEditPanel(context, region: region);
      case '启用':
        _showSnack(context, '已启用 ${region.zhName}');
      case '停用':
        _showSnack(context, '已停用 ${region.zhName}');
      case '删除':
        final confirmed = await showRegionDeleteConfirm(context, region);
        if (confirmed == true && context.mounted) {
          _showSnack(context, '已删除 ${region.zhName}');
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
          title: '地区&国家',
          description: '维护国家与地区的基础资料，供账户、支付等模块引用。',
          actionLabel: '添加',
          onAction: () => showRegionCountryEditPanel(context),
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '地区', flex: 12),
            (label: '两字母代码', flex: 8),
            (label: '三字母代码', flex: 8),
            (label: '数字代码', flex: 8),
            (label: '国际冠码', flex: 8),
            (label: '大洲代码', flex: 8),
            (label: '状态', flex: 8),
            (label: '操作', flex: 20),
          ],
          rowCount: regionCountries.length,
          rowBuilder: (context, index) {
            final region = regionCountries[index];
            return [
              CellText(region.zhName, strong: true),
              CellText(region.code2, muted: true),
              CellText(region.code3, muted: true),
              CellText(region.codeNum, muted: true),
              CellText(region.dialCode, muted: true),
              CellText(region.continent, muted: true),
              StatusBadge(
                label: region.enabled ? '启用中' : '已停用',
                tone: region.enabled ? StatusTone.success : StatusTone.neutral,
              ),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, region, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(
                      context,
                      region,
                      region.enabled ? '停用' : '启用',
                    ),
                    child: Text(region.enabled ? '停用' : '启用'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, region, '删除'),
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

/// 打开地区新增 / 编辑面板。
Future<void> showRegionCountryEditPanel(
  BuildContext context, {
  RegionCountry? region,
}) {
  return showSystemSettingsPanel(
    context,
    title: region == null ? '添加地区' : '编辑地区',
    child: RegionCountryEditForm(region: region),
  );
}

/// 地区新增 / 编辑表单。
class RegionCountryEditForm extends StatefulWidget {
  const RegionCountryEditForm({super.key, this.region});

  final RegionCountry? region;

  @override
  State<RegionCountryEditForm> createState() => _RegionCountryEditFormState();
}

class _RegionCountryEditFormState extends State<RegionCountryEditForm> {
  late final TextEditingController _zhName;
  late final TextEditingController _code2;
  late final TextEditingController _code3;
  late final TextEditingController _codeNum;
  late final TextEditingController _dialCode;
  late final TextEditingController _continent;
  late final TextEditingController _localCode;
  late final TextEditingController _postalCode;

  @override
  void initState() {
    super.initState();
    final region = widget.region;
    _zhName = TextEditingController(text: region?.zhName ?? '');
    _code2 = TextEditingController(text: region?.code2 ?? '');
    _code3 = TextEditingController(text: region?.code3 ?? '');
    _codeNum = TextEditingController(text: region?.codeNum ?? '');
    _dialCode = TextEditingController(text: region?.dialCode ?? '');
    _continent = TextEditingController(text: region?.continent ?? '');
    _localCode = TextEditingController(text: region?.localCode ?? '');
    _postalCode = TextEditingController();
  }

  @override
  void dispose() {
    _zhName.dispose();
    _code2.dispose();
    _code3.dispose();
    _codeNum.dispose();
    _dialCode.dispose();
    _continent.dispose();
    _localCode.dispose();
    _postalCode.dispose();
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
                  controller: _zhName,
                  decoration: const InputDecoration(
                    labelText: '*地区名称',
                    hintText: '如 中国',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _localCode,
                  decoration: const InputDecoration(
                    labelText: '地区&国家简称(i18n)',
                    hintText: '如 zh-CN',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _code2,
                        decoration: const InputDecoration(
                          labelText: '*两字母代码',
                          hintText: '如 CN',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _code3,
                        decoration: const InputDecoration(
                          labelText: '*三字母代码',
                          hintText: '如 CHN',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeNum,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '*数字代码',
                          hintText: '如 156',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _dialCode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '国际冠码',
                          hintText: '如 86',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _continent,
                        decoration: const InputDecoration(
                          labelText: '大洲代码',
                          hintText: '如 AS1',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _postalCode,
                        decoration: const InputDecoration(
                          labelText: '国际邮编',
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
          confirmLabel: widget.region == null ? '添加' : '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// 地区删除确认对话框。
Future<bool?> showRegionDeleteConfirm(
  BuildContext context,
  RegionCountry region,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('删除地区'),
        content: Text('确定删除地区「${region.zhName}」吗？删除后不可恢复。'),
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
