import 'package:flutter/material.dart';

import '../../prototype_registry.dart';
import '../operations_action_dialog.dart';
import 'mfa_page.dart';

/// 账号安全（运营后台·个人中心）——业务静态页。
class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账号安全')),
      body: const AccountSecurityBody(),
    );
  }
}

/// 账号安全正文（供运营后台对话框右侧内容区内嵌展示）。
class AccountSecurityBody extends StatelessWidget {
  const AccountSecurityBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _item(
          context,
          Icons.lock_outline,
          '登录密码',
          '已设置',
          '修改密码',
          onAction: () => showOperationsActionDialog(
            context,
            title: '修改密码',
            entry: prototypePageById['zBO3EW3ax'],
          ),
          extraAction: '设置密码',
          onExtraAction: () => showOperationsActionDialog(
            context,
            title: '设置密码',
            entry: prototypePageById['i8ZEUJ9_N'],
          ),
        ),
        _item(
          context,
          Icons.smartphone,
          '手机号',
          '138****1234',
          '更换',
          onAction: () => showOperationsActionDialog(
            context,
            title: '绑定(手机号、邮箱)',
            entry: prototypePageById['hG6mHCdXn'],
          ),
        ),
        _item(
          context,
          Icons.mail_outline,
          '邮箱',
          'nick@example.com',
          '更换',
          onAction: () => showOperationsActionDialog(
            context,
            title: '绑定(手机号、邮箱)',
            entry: prototypePageById['hG6mHCdXn'],
          ),
        ),
        _item(
          context,
          Icons.verified_user_outlined,
          '多因素认证',
          '未开启',
          '开启',
          onAction: () => showOperationsActionDialog(
            context,
            title: '多因素认证',
            child: const MfaBody(),
          ),
        ),
        _item(
          context,
          Icons.receipt_long_outlined,
          '账号日志',
          '最近登录：2024-08-18 10:12',
          '查看',
        ),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String action, {
    VoidCallback? onAction,
    String? extraAction,
    VoidCallback? onExtraAction,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (extraAction != null)
              TextButton(
                onPressed: onExtraAction ?? () {},
                child: Text(extraAction),
              ),
            TextButton(onPressed: onAction ?? () {}, child: Text(action)),
          ],
        ),
      ),
    );
  }
}
