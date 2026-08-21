import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import 'user_management_models.dart';
import 'user_management_widgets.dart';

/// 用户板块弹层：邀请、编辑、重置密码、停用 / 恢复与邀请结果。

/// ID / 账号 / 用户名 字段说明（账号字段旁的 tips 弹窗内容）。
const accountFieldTips = (
  title: 'ID / 账号 / 用户名 说明',
  sections: <TipsSection>[
    (
      title: 'ID',
      items: [
        '组合方式：开发人员自定义',
        '变更方式：系统自动生成，此 ID 作为用户数据关联的唯一凭据，一旦生成不可变化（不作为登录凭据）',
        '可见性：系统不可见，仅存于数据库中',
      ],
    ),
    (
      title: '账号',
      items: [
        '组合方式：由数字、字母、符号组合而成，一般不支持中文（一般限制不得小于 6 位）',
        '变更方式：账号一旦生成，不可随意变更（可以变更，不支持频繁变更）（可登录）',
        '可见性：账号只供使用者个人自己使用，他人不可见',
      ],
    ),
    (
      title: '用户名',
      items: [
        '组合方式：可以由文字、数字、字母、符号组合而成，支持中文',
        '变更方式：用户名生成后，可以随意变更（可登录）',
        '可见性：用户名供使用者个人自己使用，他人可见其用户名名称',
      ],
    ),
  ],
);

/// 通用确认对话框（内容区上方小弹窗，保留遮罩）。
Future<bool> showUserConfirmDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        title: Text(
          title,
          style: zh(
            theme.textTheme.titleMedium!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        content: DefaultTextStyle.merge(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
          child: content,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: RuQiButtonStyles.tertiary(context),
            child: const Text('取消'),
          ),
          const SizedBox(width: RuQiSpacing.xs),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? RuQiButtonStyles.danger(context)
                : RuQiButtonStyles.primary(context),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}

/// 打开邀请用户面板。
Future<void> showInviteUserPanel(BuildContext context) async {
  final result = await showSystemSettingsPanel<({String name, String email})>(
    context,
    title: '新用户',
    child: const InviteUserForm(),
  );
  if (result != null && context.mounted) {
    await showInviteTokenResultPanel(
      context,
      name: result.name,
      email: result.email,
    );
  }
}

/// 邀请用户表单：名字 / 姓氏 / 电子邮件 / 角色。
class InviteUserForm extends StatefulWidget {
  const InviteUserForm({super.key});

  @override
  State<InviteUserForm> createState() => _InviteUserFormState();
}

class _InviteUserFormState extends State<InviteUserForm> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController(text: 'nicetoseeyou@email.com');
  String _role = '普通用户';

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstName.text.trim().isEmpty
        ? '名字'
        : _firstName.text.trim();
    final lastName = _lastName.text.trim().isEmpty
        ? '姓氏'
        : _lastName.text.trim();
    final email = _email.text.trim().isEmpty
        ? 'email@@email.com'
        : _email.text.trim();
    Navigator.of(context).pop((name: '$firstName $lastName', email: email));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleOptions = [
      for (final role in roleGroups) role.name,
      if (!roleGroups.any((r) => r.name == '自定义角色')) '自定义角色',
    ];
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstName,
                        decoration: const InputDecoration(
                          labelText: '名字',
                          hintText: '名*',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _lastName,
                        decoration: const InputDecoration(
                          labelText: '姓氏',
                          hintText: '姓*',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '电子邮件',
                    hintText: '电子邮件*',
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                Text(
                  '角色',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.xs),
                Wrap(
                  spacing: RuQiSpacing.xs,
                  runSpacing: RuQiSpacing.xs,
                  children: [
                    for (final option in roleOptions)
                      ChoiceChip(
                        label: Text(option),
                        selected: _role == option,
                        onSelected: (_) => setState(() => _role = option),
                      ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Text(
                  '邀请后系统会向该邮箱发送邀请邮件；如未配置邮件服务，'
                  '将改用邀请令牌方式告知登录信息。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(confirmLabel: '邀请', onConfirm: _submit),
      ],
    );
  }
}

/// 打开邀请结果面板（邀请令牌-邮件 方案）。
Future<void> showInviteTokenResultPanel(
  BuildContext context, {
  required String name,
  required String email,
}) {
  return showSystemSettingsPanel(
    context,
    title: '邀请用户',
    child: InviteTokenResultPanel(name: name, email: email),
  );
}

/// 邀请结果：已完成添加 + 邀请令牌（可复制）。
class InviteTokenResultPanel extends StatelessWidget {
  const InviteTokenResultPanel({
    super.key,
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  static const _tokenUrl =
      'https://xxx/dashboard/#/signup/1e0a91b9-7319-4241-9114-c5569413252f';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: ext?.success ?? theme.colorScheme.primary,
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '$name 已经被添加',
            style: zh(
              theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '已成功发送电子邮件邀请，您也可以复制我们生成的 邀请令牌 分享给 '
            '$email ，让其使用邀请令牌设置密码后登录。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          _CopyRow(label: '邀请令牌', value: _tokenUrl),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '如果你想能够发送电子邮件邀请，需要先设置 Email 服务（设置 → 电子邮件）。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 打开编辑用户面板。
Future<void> showEditUserPanel(BuildContext context, UserAccount user) {
  return showSystemSettingsPanel(
    context,
    title: '编辑用户',
    child: EditUserForm(user: user),
  );
}

/// 编辑用户表单：名 / 姓 / 账号 / 电子邮件 + 元信息。
class EditUserForm extends StatefulWidget {
  const EditUserForm({super.key, required this.user});

  final UserAccount user;

  @override
  State<EditUserForm> createState() => _EditUserFormState();
}

class _EditUserFormState extends State<EditUserForm> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _account;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.user.name);
    _lastName = TextEditingController(text: widget.user.surname);
    _account = TextEditingController(text: widget.user.account);
    _email = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _account.dispose();
    _email.dispose();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstName,
                        decoration: const InputDecoration(labelText: '名'),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _lastName,
                        decoration: const InputDecoration(labelText: '姓'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _account,
                        decoration: const InputDecoration(
                          labelText: '账号',
                          helperText: '登录账号，如 admin : main',
                        ),
                      ),
                    ),
                    const SizedBox(width: RuQiSpacing.xs),
                    UserTipsButton(
                      title: accountFieldTips.title,
                      sections: accountFieldTips.sections,
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '电子邮件'),
                ),
                const SizedBox(height: RuQiSpacing.lg),
                const Divider(height: 1),
                const SizedBox(height: RuQiSpacing.md),
                _MetaRow(label: '创建', value: 'system · 3/29/2022 10:04:32'),
                const SizedBox(height: RuQiSpacing.xs),
                _MetaRow(label: '最后编辑', value: 'account001'),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: '更新',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

/// 打开「重置密码（密码重置URL方案）」结果面板。
Future<void> showPasswordResetUrlPanel(BuildContext context, UserAccount user) {
  return showSystemSettingsPanel(
    context,
    title: '重置密码',
    child: PasswordResetUrlPanel(user: user),
  );
}

/// 密码重置 URL 结果：完成 + 可复制链接。
class PasswordResetUrlPanel extends StatelessWidget {
  const PasswordResetUrlPanel({super.key, required this.user});

  final UserAccount user;

  static const _resetUrl =
      'https://xxx/dashboard/#/signup/1e0a91b9-7319-4241-9114-c5569413252f';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: ext?.success ?? theme.colorScheme.primary,
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '${user.displayName} 的账户已生成密码重置URL',
            style: zh(
              theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '这是最新的密码重置URL，请复制发送。密码重置成功后此链接将失效。'
            '（旧的密码重置链接已失效）',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          _CopyRow(label: '密码重置URL', value: _resetUrl),
        ],
      ),
    );
  }
}

/// 打开「重置密码（临时密码方案）」确认与结果。
Future<void> showTemporaryPasswordResetFlow(
  BuildContext context,
  UserAccount user,
) async {
  final confirmed = await showUserConfirmDialog(
    context,
    title: '重置密码',
    content: Text('你确定要重置 ${user.account} 的密码吗？重置后旧密码立即失效。'),
    confirmLabel: '重置密码',
  );
  if (confirmed && context.mounted) {
    await showPasswordResetSuccessPanel(context, user);
  }
}

/// 打开密码重置成功面板（临时密码方案）。
Future<void> showPasswordResetSuccessPanel(
  BuildContext context,
  UserAccount user,
) {
  return showSystemSettingsPanel(
    context,
    title: '重置密码',
    child: PasswordResetSuccessPanel(user: user),
  );
}

/// 密码重置成功：临时密码（可显示 / 隐藏）。
class PasswordResetSuccessPanel extends StatelessWidget {
  const PasswordResetSuccessPanel({super.key, required this.user});

  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: ext?.success ?? theme.colorScheme.primary,
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '${user.displayName} 的密码已被重置',
            style: zh(
              theme.textTheme.headlineSmall!.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '这是系统提供的用于登录的临时密码，登录成功后请修改密码。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          const _TemporaryPasswordRow(),
        ],
      ),
    );
  }
}

/// 临时密码展示行：显示 / 隐藏 + 复制。
class _TemporaryPasswordRow extends StatefulWidget {
  const _TemporaryPasswordRow();

  @override
  State<_TemporaryPasswordRow> createState() => _TemporaryPasswordRowState();
}

class _TemporaryPasswordRowState extends State<_TemporaryPasswordRow> {
  static const _password = 'Cw3#xK9pLm';
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          '临时密码',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: RuQiSpacing.md),
        Expanded(
          child: Text(
            _visible ? _password : '••••••••••',
            style: RuQiTextStyles.mono.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _visible = !_visible),
          style: RuQiButtonStyles.tertiary(context),
          child: Text(_visible ? '隐藏' : '显示'),
        ),
      ],
    );
  }
}

/// 停用账户确认（对应 停用账户 原型）。
Future<bool> showDeactivateConfirmDialog(
  BuildContext context,
  UserAccount user,
) {
  return showUserConfirmDialog(
    context,
    title: '停用 ${user.displayName} 的账户？',
    content: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('· 停用的账号将无法登录应用以及重置密码'),
        SizedBox(height: RuQiSpacing.xxs),
        Text('· 停用账号期间，仍可编辑用户信息'),
        SizedBox(height: RuQiSpacing.xxs),
        Text('· 停用账号可以恢复'),
      ],
    ),
    confirmLabel: '停用',
    destructive: true,
  );
}

/// 重新激活确认（对应 重新激活 原型）。
Future<bool> showReactivateConfirmDialog(
  BuildContext context,
  UserAccount user,
) {
  return showUserConfirmDialog(
    context,
    title: '重新激活 ${user.displayName}？',
    content: const Text('账户将被允许再次登录，并被放回账户被停用前所在的组。'),
    confirmLabel: '重新激活',
  );
}

/// 可复制的值行。
class _CopyRow extends StatelessWidget {
  const _CopyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.md,
        vertical: RuQiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: RuQiSpacing.md),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: RuQiTextStyles.mono.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label已复制'), duration: RuQiMotion.fast),
              );
            },
            style: RuQiButtonStyles.secondary(context),
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }
}
