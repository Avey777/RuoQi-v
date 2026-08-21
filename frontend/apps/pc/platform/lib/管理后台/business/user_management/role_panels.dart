import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import 'user_management_models.dart';
import 'user_management_widgets.dart';
import 'user_panels.dart';

/// 角色板块弹层：创建 / 编辑 / 删除 / 设置权限。

/// 打开创建角色组面板。
Future<void> showCreateRolePanel(BuildContext context) {
  return showSystemSettingsPanel(
    context,
    title: '创建角色',
    child: const CreateRoleForm(),
  );
}

/// 创建角色组表单：角色名称 / 名称 / 备注信息。
class CreateRoleForm extends StatefulWidget {
  const CreateRoleForm({super.key});

  @override
  State<CreateRoleForm> createState() => _CreateRoleFormState();
}

class _CreateRoleFormState extends State<CreateRoleForm> {
  final _name = TextEditingController();
  final _initial = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _initial.dispose();
    _note.dispose();
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
                    labelText: '角色名称',
                    helperText: '如 实施经理、运营专员。',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _initial,
                  maxLength: 2,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    helperText: '列表中展示的简称，如 实 / 运。',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.sm),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '备注信息',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(confirmLabel: '创建', onConfirm: () => Navigator.of(context).pop()),
      ],
    );
  }
}

/// 打开编辑角色组面板。
Future<void> showEditRolePanel(BuildContext context, RoleGroup role) {
  return showSystemSettingsPanel(
    context,
    title: '编辑角色',
    child: EditRoleForm(role: role),
  );
}

/// 编辑角色组表单：名称 / 备注信息 + 元信息。
class EditRoleForm extends StatefulWidget {
  const EditRoleForm({super.key, required this.role});

  final RoleGroup role;

  @override
  State<EditRoleForm> createState() => _EditRoleFormState();
}

class _EditRoleFormState extends State<EditRoleForm> {
  late final TextEditingController _name;
  late final TextEditingController _initial;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.role.name);
    _initial = TextEditingController(text: widget.role.initial);
    _note = TextEditingController(text: widget.role.note == '--' ? '' : widget.role.note);
  }

  @override
  void dispose() {
    _name.dispose();
    _initial.dispose();
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
                  decoration: const InputDecoration(labelText: '角色名称'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _initial,
                  maxLength: 2,
                  decoration: const InputDecoration(labelText: '名称'),
                ),
                const SizedBox(height: RuQiSpacing.sm),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '备注信息',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.lg),
                const Divider(height: 1),
                const SizedBox(height: RuQiSpacing.md),
                _MetaRow(
                  label: '创建',
                  value: 'system · 3/29/2022 10:04:32',
                  theme: theme,
                ),
                const SizedBox(height: RuQiSpacing.xs),
                _MetaRow(label: '最后编辑', value: 'account001', theme: theme),
              ],
            ),
          ),
        ),
        UserFormActions(confirmLabel: '更新', onConfirm: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// 删除角色组确认（对应 删除角色组 原型）。
Future<bool> showDeleteRoleConfirmDialog(
  BuildContext context,
  RoleGroup role,
) {
  return showUserConfirmDialog(
    context,
    title: '删除这个角色组？',
    content: Text(
      '确定删除吗？ 该组所有成员都将丢失该组下的权限设置。'
      '此操作不可逆。（${role.name}）',
    ),
    confirmLabel: '是',
    destructive: true,
  );
}

/// 打开设置权限面板。
Future<void> showRolePermissionsPanel(BuildContext context, RoleGroup role) {
  return showSystemSettingsPanel(
    context,
    title: '${role.name} · 权限',
    child: RolePermissionsPanel(role: role),
  );
}

/// 设置权限面板：模块 + 查看 / 编辑 开关（对应 权限 原型的一二级菜单）。
class RolePermissionsPanel extends StatefulWidget {
  const RolePermissionsPanel({super.key, required this.role});

  final RoleGroup role;

  @override
  State<RolePermissionsPanel> createState() => _RolePermissionsPanelState();
}

class _RolePermissionsPanelState extends State<RolePermissionsPanel> {
  late final Map<String, bool> _view;
  late final Map<String, bool> _edit;

  @override
  void initState() {
    super.initState();
    _view = {for (final (name, _) in permissionModules) name: true};
    _edit = {
      for (final (name, _) in permissionModules) name: widget.role.isDefault,
    };
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
                  '为「${widget.role.name}」配置菜单与功能权限，'
                  '该组用户登录后将看到对应菜单。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        color: theme.colorScheme.surfaceContainerHigh,
                        padding: const EdgeInsets.symmetric(
                          horizontal: RuQiSpacing.md,
                          vertical: RuQiSpacing.sm,
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: UserColumnHeader('一级菜单')),
                            Expanded(flex: 3, child: UserColumnHeader('二级菜单')),
                            SizedBox(width: 64, child: UserColumnHeader('查看')),
                            SizedBox(width: 64, child: UserColumnHeader('编辑')),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      for (final (index, (name, subMenus)) in permissionModules.indexed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: RuQiSpacing.md,
                            vertical: RuQiSpacing.sm,
                          ),
                          decoration: index == permissionModules.length - 1
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
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  subMenus.join(' / '),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Switch(
                                  value: _view[name] ?? false,
                                  onChanged: (value) =>
                                      setState(() => _view[name] = value),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Switch(
                                  value: _edit[name] ?? false,
                                  onChanged: (value) =>
                                      setState(() => _edit[name] = value),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(confirmLabel: '保存修改', onConfirm: () => Navigator.of(context).pop()),
      ],
    );
  }
}
