import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'settings_content_dialog.dart';

/// 设置-auth登录 业务正文（替换静态原型复刻页）。
///
/// 「Google账号登录」卡片提供可用的「设置」按钮，打开 Google 登录配置弹窗。
class AuthLoginBody extends StatelessWidget {
  const AuthLoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Text(
          'auth登录',
          style: zh(
            theme.textTheme.headlineSmall!.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xxs),
        Text(
          '配置第三方账号登录方式。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RuQiSpacing.lg),
        Card(
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
                    Icons.g_mobiledata,
                    size: 26,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: RuQiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google账号登录',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '允许拥有现有运营后台账户的用户在当前的用户名和密码的基础上，'
                        '用与他们的电子邮件地址相匹配的谷歌账户登录。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: RuQiSpacing.sm),
                OutlinedButton(
                  onPressed: () => showGoogleLoginSettingsDialog(context),
                  style: RuQiButtonStyles.secondary(context),
                  child: const Text('设置'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 打开 Google 账号登录配置面板（与内容区同尺寸）。
Future<void> showGoogleLoginSettingsDialog(BuildContext context) {
  return showSystemSettingsPanel(
    context,
    title: 'Google账号登录 设置',
    child: const GoogleLoginSettingsForm(),
  );
}

/// Google 账号登录配置表单（参照 设置/auth登录/Google登录 原型）。
class GoogleLoginSettingsForm extends StatefulWidget {
  const GoogleLoginSettingsForm({super.key});

  @override
  State<GoogleLoginSettingsForm> createState() =>
      _GoogleLoginSettingsFormState();
}

class _GoogleLoginSettingsFormState extends State<GoogleLoginSettingsForm> {
  late final TextEditingController _clientId;
  late final TextEditingController _allowedDomain;

  @override
  void initState() {
    super.initState();
    _clientId = TextEditingController(
      text: '{your-client-id}.apps.googleusercontent.com',
    );
    _allowedDomain = TextEditingController(text: 'mycompany.com');
  }

  @override
  void dispose() {
    _clientId.dispose();
    _allowedDomain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _clientId,
            decoration: const InputDecoration(
              labelText: '客户ID',
              helperText: 'Google Cloud Console 中创建的 OAuth 客户端 ID。',
            ),
          ),
          const SizedBox(height: RuQiSpacing.md),
          Text(
            '允许用户登录，如果用户的 Google 帐户电子邮件地址来自：',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RuQiSpacing.xs),
          TextField(
            controller: _allowedDomain,
            decoration: const InputDecoration(
              labelText: '域名',
              helperText: '多个域名用英文逗号分隔。',
            ),
          ),
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
                child: const Text('保存并启用'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
