import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'admin_pages/system_settings_dialog.dart';
import 'ops_pages/operations_console_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RuoQi-Platform'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: AppBadge(appName: 'platform_pc', version: '1.0.0'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 一账通（系统管理）独立弹窗入口
          _entryCard(
            context,
            icon: Icons.admin_panel_settings,
            title: '系统管理',
            subtitle: '一账通 ID 独立体系：设置 / 用户 / 权限 / 菜单 / 基础 / 语言 / 日志',
            onTap: () => SystemSettingsDialog.show(context),
          ),
          const SizedBox(height: 12),
          // 运营后台入口：与系统管理一致的弹窗交互
          _entryCard(
            context,
            icon: Icons.dashboard_customize,
            title: '运营后台',
            subtitle: '一账通运营端(SSO)：租户 / 团队空间 / 项目 / API授权 / 个人中心',
            onTap: () => OperationsConsoleDialog.show(context),
          ),
        ],
      ),
    );
  }

  Widget _entryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.primaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(icon, size: 40, color: colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
