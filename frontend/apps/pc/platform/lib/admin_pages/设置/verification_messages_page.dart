import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';

/// 验证消息设置项。
class VerificationMessageItem {
  const VerificationMessageItem({
    required this.name,
    required this.description,
    required this.subject,
    required this.sender,
    required this.emailBody,
    required this.sceneVariables,
    this.sms,
  });

  final String name;
  final String description;

  /// 主题（邀请用户为「我们邀请您加入 ${Site Name}」）。
  final String subject;

  /// 发件人。
  final String sender;

  /// 电子邮件正文模板。
  final String emailBody;

  /// 场景变量说明，如「用户账号：\${user_account}」。
  final List<String> sceneVariables;

  /// 短信渠道配置；`null` 表示该消息仅通过邮件发送。
  final VerificationSmsChannels? sms;
}

/// 短信渠道：腾讯云 / 阿里云 / Arkesel。
class VerificationSmsChannels {
  const VerificationSmsChannels({
    required this.tencentTemplateId,
    required this.aliyunTemplateId,
    required this.smsBody,
  });

  final String tencentTemplateId;
  final String aliyunTemplateId;

  /// Arkesel 直接编写的短信内容。
  final String smsBody;
}

const _emailBody =
    'Your \${Site Name} verification code is \${verification code} , '
    'Valid within 15 minutes. Please do disclose to anyobne.\n'
    'Identification code: \${Identification code}. \n';

const _smsBody =
    '\${Site Name} Verification code:  \${verification code} '
    'from \${Site Name},valid for 15 minutes.Please do not disclose it to '
    'anyone.\nIdentification code: \${Identification code}';

const _userAccountVar = '用户账号：\${user_account}';

/// 验证消息设置项列表（对应 设置-验证消息 原型）。
const verificationMessageItems = [
  VerificationMessageItem(
    name: '验证码登录',
    description: '用户使用验证码登录时，发送的通知消息',
    subject: '',
    sender: 'Avey<avey777@163.com>',
    emailBody: _emailBody,
    sceneVariables: [_userAccountVar],
    sms: VerificationSmsChannels(
      tencentTemplateId: '',
      aliyunTemplateId: '326565',
      smsBody: _smsBody,
    ),
  ),
  VerificationMessageItem(
    name: '注册验证',
    description: '用户注册验证时，发送的通知消息',
    subject: '',
    sender: 'Avey<avey777@163.com>',
    emailBody: _emailBody,
    sceneVariables: [_userAccountVar],
    sms: VerificationSmsChannels(
      tencentTemplateId: '2566',
      aliyunTemplateId: '326565',
      smsBody: _smsBody,
    ),
  ),
  VerificationMessageItem(
    name: '修改密码验证',
    description: '用户修改密码时，发送的通知消息',
    subject: '',
    sender: 'Avey<avey777@163.com>',
    emailBody: _emailBody,
    sceneVariables: [_userAccountVar],
    sms: VerificationSmsChannels(
      tencentTemplateId: '2566',
      aliyunTemplateId: '326565',
      smsBody: _smsBody,
    ),
  ),
  VerificationMessageItem(
    name: '密码重置验证',
    description: '用户重置密码时，发送的通知消息',
    subject: '',
    sender: 'Avey<avey777@163.com>',
    emailBody: _emailBody,
    sceneVariables: [_userAccountVar],
    sms: VerificationSmsChannels(
      tencentTemplateId: '2566',
      aliyunTemplateId: '326565',
      smsBody: _smsBody,
    ),
  ),
  VerificationMessageItem(
    name: '邀请用户',
    description: '邀请用户时，发送的通知消息',
    subject: '我们邀请您加入 \${Site Name}',
    sender: 'Avey<avey777@163.com>',
    emailBody:
        '\${user_nick} wants to join them on \${Site Name}\n'
        'Identification code: \${Identification code}. \n',
    sceneVariables: [
      _userAccountVar,
      '用户昵称：\${user_nick}',
      '网站名称：\${Site Name}',
      '邀请链接：\${Invite Link}',
    ],
  ),
];

/// 设置-验证消息 业务正文（替换静态原型复刻页）。
///
/// 每个验证消息项提供可用的「设置」按钮，打开对应设置弹窗。
class VerificationMessagesBody extends StatelessWidget {
  const VerificationMessagesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          '验证消息',
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          '配置各类验证消息的通知模板与发送渠道。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 2 : 1;
            final cardWidth =
                (constraints.maxWidth - (columns - 1) * RuQiSpacing.md) /
                columns;
            return Wrap(
              spacing: RuQiSpacing.md,
              runSpacing: RuQiSpacing.md,
              children: [
                for (final item in verificationMessageItems)
                  SizedBox(
                    width: cardWidth,
                    child: _MessageCard(item: item),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.item});

  final VerificationMessageItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(RuQiSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: RuQiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RuQiSpacing.sm),
            OutlinedButton(
              onPressed: () =>
                  showVerificationMessageSettingsDialog(context, item),
              style: RuQiButtonStyles.secondary(context),
              child: const Text('设置'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 打开验证消息设置面板（与内容区同尺寸）。
Future<void> showVerificationMessageSettingsDialog(
  BuildContext context,
  VerificationMessageItem item,
) {
  return showSystemSettingsPanel(
    context,
    title: '${item.name} 设置',
    child: VerificationMessageSettingsForm(item: item),
  );
}

/// 验证消息设置表单：主题、场景变量、电子邮件、发件人与短信渠道。
class VerificationMessageSettingsForm extends StatefulWidget {
  const VerificationMessageSettingsForm({super.key, required this.item});

  final VerificationMessageItem item;

  @override
  State<VerificationMessageSettingsForm> createState() =>
      _VerificationMessageSettingsFormState();
}

class _VerificationMessageSettingsFormState
    extends State<VerificationMessageSettingsForm> {
  late final TextEditingController _subject;
  late final TextEditingController _sender;
  late final TextEditingController _emailBody;
  late final TextEditingController _tencentTemplateId;
  late final TextEditingController _aliyunTemplateId;
  late final TextEditingController _smsBody;

  @override
  void initState() {
    super.initState();
    _subject = TextEditingController(text: widget.item.subject);
    _sender = TextEditingController(text: widget.item.sender);
    _emailBody = TextEditingController(text: widget.item.emailBody);
    _tencentTemplateId = TextEditingController(
      text: widget.item.sms?.tencentTemplateId ?? '',
    );
    _aliyunTemplateId = TextEditingController(
      text: widget.item.sms?.aliyunTemplateId ?? '',
    );
    _smsBody = TextEditingController(text: widget.item.sms?.smsBody ?? '');
  }

  @override
  void dispose() {
    _subject.dispose();
    _sender.dispose();
    _emailBody.dispose();
    _tencentTemplateId.dispose();
    _aliyunTemplateId.dispose();
    _smsBody.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _subject,
            decoration: InputDecoration(labelText: '主题', hintText: '邮件主题'),
          ),
          const SizedBox(height: RuQiSpacing.sm),
          Text(
            '场景变量：${widget.item.sceneVariables.join('、')}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: ext?.inkMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          const _SectionLabel('电子邮件'),
          const SizedBox(height: RuQiSpacing.xs),
          TextField(
            controller: _emailBody,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '邮件正文模板',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          TextField(
            controller: _sender,
            decoration: const InputDecoration(labelText: '发件人'),
          ),
          if (widget.item.sms != null) ...[
            const SizedBox(height: RuQiSpacing.md),
            const _SectionLabel('短信'),
            const SizedBox(height: RuQiSpacing.xs),
            _ChannelField(
              label: '腾讯云短信',
              controller: _tencentTemplateId,
              fieldLabel: '模板 ID',
              helper:
                  '使用腾讯云短信，需要填写模板 ID；'
                  '若模板 ID 填写错误，无法保存提交短消息模板。'
                  '注意必须是腾讯审核通过的模板 ID，'
                  '短信内容以对应模板 ID 的短信内容为准。',
            ),
            const SizedBox(height: RuQiSpacing.md),
            _ChannelField(
              label: '阿里云短信',
              controller: _aliyunTemplateId,
              fieldLabel: '模板 ID',
              helper:
                  '使用阿里云短信，需要填写模板 ID；'
                  '若模板 ID 填写错误，无法保存提交短消息模板。'
                  '注意必须是阿里云审核通过的模板 ID，'
                  '短信内容以对应模板 ID 的短信内容为准。',
            ),
            const SizedBox(height: RuQiSpacing.md),
            _ChannelField(
              label: 'Arkesel',
              controller: _smsBody,
              fieldLabel: '短信内容',
              helper: 'Arkesel 短信，直接编写短信内容，不需要内容备案。',
              multiline: true,
            ),
          ],
          const SizedBox(height: RuQiSpacing.lg),
          Row(
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
                child: const Text('保存修改'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ChannelField extends StatelessWidget {
  const _ChannelField({
    required this.label,
    required this.controller,
    required this.fieldLabel,
    required this.helper,
    this.multiline = false,
  });

  final String label;
  final TextEditingController controller;
  final String fieldLabel;
  final String helper;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: RuQiSpacing.xs),
        TextField(
          controller: controller,
          maxLines: multiline ? 4 : 1,
          decoration: InputDecoration(
            labelText: fieldLabel,
            helperText: helper,
            alignLabelWithHint: multiline,
          ),
        ),
      ],
    );
  }
}
