import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import '../shared/table_card.dart';
import '../用户/user_management_widgets.dart';

/// 菜单项：顶菜单 / 左菜单 / 按钮。
class MenuItem {
  const MenuItem({
    required this.name,
    required this.type,
    required this.parent,
    required this.sort,
    this.icon = '',
    this.componentPath = '',
    this.permissionKey = '',
    this.url = '',
  });

  final String name;
  final String type;
  final String parent;
  final String icon;
  final String componentPath;
  final String permissionKey;
  final String url;
  final int sort;
}

const menuItems = [
  MenuItem(name: '设置', type: '顶菜单', parent: '根目录', sort: 1, icon: 'setting', componentPath: '/settings'),
  MenuItem(name: '用户', type: '顶菜单', parent: '根目录', sort: 2, icon: 'user', componentPath: '/users'),
  MenuItem(name: '权限', type: '顶菜单', parent: '根目录', sort: 3, icon: 'shield', componentPath: '/permissions'),
  MenuItem(name: '菜单', type: '顶菜单', parent: '根目录', sort: 4, icon: 'menu', componentPath: '/menus'),
  MenuItem(name: '基础', type: '顶菜单', parent: '根目录', sort: 5, icon: 'base', componentPath: '/base'),
  MenuItem(name: '语言', type: '顶菜单', parent: '根目录', sort: 6, icon: 'language', componentPath: '/lang'),
  MenuItem(name: '日志', type: '顶菜单', parent: '根目录', sort: 7, icon: 'log', componentPath: '/logs'),
  MenuItem(name: '时区', type: '左菜单', parent: '基础', sort: 1, icon: 'timezone', componentPath: '/base/timezone', permissionKey: 'base:timezone'),
  MenuItem(name: '货币', type: '左菜单', parent: '基础', sort: 2, icon: 'currency', componentPath: '/base/currency', permissionKey: 'base:currency'),
  MenuItem(name: '历史汇率', type: '左菜单', parent: '基础', sort: 3, icon: 'rate', componentPath: '/base/rate', permissionKey: 'base:rate'),
  MenuItem(name: '多语言', type: '左菜单', parent: '语言', sort: 1, icon: 'language', componentPath: '/lang/multi', permissionKey: 'lang:multi'),
  MenuItem(name: '翻译', type: '左菜单', parent: '语言', sort: 2, icon: 'translate', componentPath: '/lang/translate', permissionKey: 'lang:translate'),
  MenuItem(name: '导入', type: '左菜单', parent: '语言', sort: 3, icon: 'import', componentPath: '/lang/import', permissionKey: 'lang:import'),
  MenuItem(name: '导出', type: '左菜单', parent: '语言', sort: 4, icon: 'export', componentPath: '/lang/export', permissionKey: 'lang:export'),
  MenuItem(name: '验证日志', type: '左菜单', parent: '日志', sort: 1, icon: 'log', componentPath: '/logs/verify', permissionKey: 'logs:verify'),
  MenuItem(name: '操作日志', type: '左菜单', parent: '日志', sort: 2, icon: 'log', componentPath: '/logs/operate', permissionKey: 'logs:operate'),
  MenuItem(name: '登录日志', type: '左菜单', parent: '日志', sort: 3, icon: 'log', componentPath: '/logs/login', permissionKey: 'logs:login'),
  MenuItem(name: '支付日志', type: '左菜单', parent: '日志', sort: 4, icon: 'log', componentPath: '/logs/pay', permissionKey: 'logs:pay'),
];

/// 菜单板块业务正文（对应 菜单 原型）。
class MenusBody extends StatelessWidget {
  const MenusBody({super.key});

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: RuQiMotion.normal),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    MenuItem item,
    String action,
  ) async {
    switch (action) {
      case '新增下级':
        await showMenuEditPanel(context, parent: item.name);
      case '编辑':
        await showMenuEditPanel(context, item: item);
      case '删除':
        final confirmed = await showMenuDeleteConfirm(context, item);
        if (confirmed == true && context.mounted) {
          _showSnack(context, '已删除菜单 ${item.name}');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        UserPageHeader(
          title: '菜单',
          description: '通过菜单控制管理后台左侧导航的展示位置与权限。',
          actionLabel: '添加',
          onAction: () => showMenuEditPanel(context),
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
                  '你可以使用菜单来自由控制其展示的位置。一般这个由专业人员设置，'
                  '不建议将此权限开放给普通人员。',
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
            (label: '名称', flex: 12),
            (label: '类型', flex: 8),
            (label: '图标', flex: 8),
            (label: '组件路径', flex: 18),
            (label: '权限标识', flex: 16),
            (label: '网页URL', flex: 14),
            (label: '排序', flex: 6),
            (label: '操作', flex: 18),
          ],
          rowCount: menuItems.length,
          rowBuilder: (context, index) {
            final item = menuItems[index];
            return [
              CellText(item.name, strong: true),
              CellText(item.type, muted: item.parent != '根目录'),
              CellText(item.icon.isEmpty ? '--' : item.icon, muted: true),
              CellText(
                item.componentPath.isEmpty ? '--' : item.componentPath,
                muted: true,
              ),
              CellText(
                item.permissionKey.isEmpty ? '--' : item.permissionKey,
                muted: true,
              ),
              CellText(item.url.isEmpty ? '--' : item.url, muted: true),
              CellText('${item.sort}', muted: true),
              Wrap(
                spacing: RuQiSpacing.xs,
                children: [
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, item, '新增下级'),
                    child: const Text('新增下级'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, item, '编辑'),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    style: RuQiButtonStyles.tertiary(context),
                    onPressed: () => _handleAction(context, item, '删除'),
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

/// 打开菜单新增 / 编辑面板。
Future<void> showMenuEditPanel(
  BuildContext context, {
  MenuItem? item,
  String? parent,
}) {
  return showSystemSettingsPanel(
    context,
    title: item == null ? '添加菜单' : '编辑菜单',
    child: MenuEditForm(item: item, parent: parent),
  );
}

/// 菜单新增 / 编辑表单。
class MenuEditForm extends StatefulWidget {
  const MenuEditForm({super.key, this.item, this.parent});

  final MenuItem? item;
  final String? parent;

  @override
  State<MenuEditForm> createState() => _MenuEditFormState();
}

class _MenuEditFormState extends State<MenuEditForm> {
  late final TextEditingController _name;
  late final TextEditingController _permissionKey;
  late final TextEditingController _sort;
  late final TextEditingController _icon;
  late final TextEditingController _url;
  late final TextEditingController _componentPath;
  late String _parent;
  late String _type;
  late String _openMode;
  bool _hidden = false;
  bool _single = false;

  static const _parents = ['根目录', '设置', '用户', '权限', '菜单', '基础', '语言', '日志'];
  static const _types = ['顶菜单', '左菜单', '按钮'];
  static const _openModes = ['内部URL', '外部URL', '内联框架', '新开页签'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _permissionKey = TextEditingController(text: item?.permissionKey ?? '');
    _sort = TextEditingController(text: '${item?.sort ?? 1}');
    _icon = TextEditingController(text: item?.icon ?? '');
    _url = TextEditingController(text: item?.url ?? '');
    _componentPath = TextEditingController(text: item?.componentPath ?? '');
    _parent = widget.parent ?? item?.parent ?? '根目录';
    _type = item?.type ?? '左菜单';
    _openMode = '内部URL';
  }

  @override
  void dispose() {
    _name.dispose();
    _permissionKey.dispose();
    _sort.dispose();
    _icon.dispose();
    _url.dispose();
    _componentPath.dispose();
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
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: '*菜单名称',
                    hintText: '菜单名称',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _DropdownField(
                        label: '*上级区域',
                        value: _parent,
                        options: _parents,
                        onChanged: (v) => setState(() => _parent = v!),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: _DropdownField(
                        label: '*类型',
                        value: _type,
                        options: _types,
                        onChanged: (v) => setState(() => _type = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _permissionKey,
                  decoration: const InputDecoration(
                    labelText: '*权限标识',
                    hintText: '如 base:timezone',
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
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _icon,
                        decoration: const InputDecoration(
                          labelText: '图标',
                          hintText: '点击选择 / 上传',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        value: _hidden,
                        onChanged: (v) => setState(() => _hidden = v),
                        title: const Text('是否隐藏'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        value: _single,
                        onChanged: (v) => setState(() => _single = v),
                        title: const Text('是否单个'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.sm),
                TextField(
                  controller: _url,
                  decoration: const InputDecoration(
                    labelText: '*网页URL',
                    hintText: 'URL',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                _DropdownField(
                  label: '打开方式',
                  value: _openMode,
                  options: _openModes,
                  onChanged: (v) => setState(() => _openMode = v!),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _componentPath,
                  decoration: const InputDecoration(
                    labelText: '*组件路径',
                    hintText: '如 /base/timezone',
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: widget.item == null ? '添加' : '保存',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// 下拉字段。
class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(option)),
      ],
      onChanged: onChanged,
    );
  }
}

/// 菜单删除确认对话框。
Future<bool?> showMenuDeleteConfirm(BuildContext context, MenuItem item) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('删除菜单'),
        content: Text('确定删除菜单「${item.name}」吗？删除后其下级菜单将一并隐藏。'),
        actions: [
          TextButton(
            style: RuQiButtonStyles.tertiary(context),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: RuQiButtonStyles.danger(context),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('删除'),
          ),
        ],
      );
    },
  );
}
