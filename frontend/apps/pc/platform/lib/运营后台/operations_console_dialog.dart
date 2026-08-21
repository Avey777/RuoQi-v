// 运营后台入口弹窗（手写，勿被 rp2flutter 生成逻辑覆盖）。
//
// 交互方式与 管理后台（系统管理）一致：点击左侧菜单项后，
// 在弹窗右侧内容区直接打开对应页面，不再 push 完整页面路由。
// 弹窗顶部为按规范 §6.7 实现的控制台导航栏（品牌 + 退出）；
// 菜单导航全部在左侧树形菜单中（板块 → 页面 → 子页面）；
// 已优化为业务静态页的菜单项展示其正文；未优化项回退到原型预览，
// 裁掉原型自带的顶部菜单、左侧栏与面包屑，避免重复。
import 'package:flutter/material.dart';

import '../console_widgets/console_top_bar.dart';
import '../prototype_registry.dart';
import 'operations_preview.dart';
import 'operations_sidebar.dart';
import 'pages/account_security_page.dart';
import 'pages/api_token_page.dart';
import 'pages/localization_page.dart';
import 'pages/member_manage_page.dart';
import 'pages/mfa_page.dart';
import 'pages/profile_page.dart';
import 'pages/project_list_page.dart';
import 'pages/project_settings_page.dart';
import 'pages/subscription_billing_page.dart';
import 'pages/subscription_cancel_audit_page.dart';
import 'pages/subscription_change_audit_page.dart';
import 'pages/subscription_open_audit_page.dart';
import 'pages/team_settings_page.dart';
import 'pages/team_space_page.dart';
import 'pages/tenant_audit_page.dart';
import 'pages/tenant_list_page.dart';
import 'pages/tenant_settings_page.dart';

/// 运营后台（一账通运营端 SSO）入口弹窗。
class OperationsConsoleDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => const _OperationsConsoleDialog(),
    );
  }
}

/// 已优化为业务静态页的菜单项（原型 pageId → 正文组件）。
/// 未收录的菜单项仍回退到原型预览。
final _businessBodies = <String, WidgetBuilder>{
  'jSTfPprJez': (_) => const TenantListBody(),
  'hEcuv5lQ8': (_) => const MemberManageBody(),
  '_n1LmDFij': (_) => const TenantAuditBody(),
  'MPkqxQ-kE': (_) => const TenantSettingsBody(),
  'HLLVxR2i7': (_) => const ProjectListBody(),
  'CniE3ZtPiE0': (_) => const ProjectSettingsBody(),
  'a2iuwP9vz': (_) => const SubscriptionBillingBody(),
  'hzWGnXvBu': (_) => const SubscriptionOpenAuditBody(),
  'LW_OP_AQE': (_) => const SubscriptionChangeAuditBody(),
  'p7lljuBnu': (_) => const SubscriptionCancelAuditBody(),
  'fj714uUhe': (_) => const TeamSpaceBody(),
  'xtOLR-LhK': (_) => const TeamSettingsBody(),
  'ncUGMKi7_': (_) => const ApiTokenBody(),
  'B44C4h3edeR2': (_) => const ProfileBody(),
  'ntgGZaqJgUZC': (_) => const AccountSecurityBody(),
  'DAZ8_zIokgWI': (_) => const MfaBody(),
  '1J5Ra7pGo': (_) => const LocalizationBody(),
};

class _OperationsConsoleDialog extends StatefulWidget {
  const _OperationsConsoleDialog();

  @override
  State<_OperationsConsoleDialog> createState() =>
      _OperationsConsoleDialogState();
}

class _OperationsConsoleDialogState extends State<_OperationsConsoleDialog> {
  PrototypeEntry? _selected;

  @override
  void initState() {
    super.initState();
    // 默认打开第一个板块的第一个菜单项，与 管理后台 一致。
    _selected = _firstEntryOf(operationsSections.first);
  }

  PrototypeEntry? _firstEntryOf(String section) {
    final items = operationsEntriesOf(section);
    return items.isEmpty ? null : items.first;
  }

  @override
  Widget build(BuildContext context) {
    final entry = _selected;
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 顶部导航栏：品牌 + 退出
          ConsoleTopBar(
            title: 'XX运营后台',
            onExit: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 左侧菜单
                OperationsSidebar(
                  selectedId: entry?.id,
                  onSelected: (e) => setState(() => _selected = e),
                ),
                // 右侧内容区：展示选中菜单项对应的页面
                Expanded(
                  child: entry == null
                      ? ColoredBox(color: Theme.of(context).colorScheme.surface)
                      : _PageContent(key: ValueKey(entry.id), entry: entry),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 右侧内容区：页面正文（业务静态页）或原型预览（未优化项）。
class _PageContent extends StatelessWidget {
  const _PageContent({super.key, required this.entry});

  final PrototypeEntry entry;

  @override
  Widget build(BuildContext context) {
    final bodyBuilder = _businessBodies[entry.id];
    return bodyBuilder != null
        ? ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: bodyBuilder(context),
          )
        : OperationsPrototypePreview(entry: entry);
  }
}
