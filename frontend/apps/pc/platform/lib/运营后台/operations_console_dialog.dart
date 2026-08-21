// 运营后台入口弹窗（手写，勿被 rp2flutter 生成逻辑覆盖）。
//
// 交互方式与 管理后台（系统管理）一致：点击左侧菜单项后，
// 在弹窗右侧内容区直接打开对应页面，不再 push 完整页面路由。
// 弹窗顶部为与 管理后台 一致的紫色导航栏（品牌 + 退出）；
// 菜单导航全部在左侧树形菜单中（板块 → 页面 → 子页面）；
// 已优化为业务静态页的菜单项展示其正文；未优化项回退到原型预览，
// 裁掉原型自带的顶部菜单、左侧栏与面包屑，避免重复。
import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 顶部导航栏：品牌 + 退出
          _TopBar(onExit: () => Navigator.of(context).pop()),
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
                      ? const ColoredBox(color: Color(0xFFF5F6F8))
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

/// 顶部紫色导航栏（参照 管理后台 弹窗）：品牌名 + 退出。
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onExit});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _topBarHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF7172AD),
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          const Icon(
            IconData(0xE8B2, fontFamily: 'boldIconFont'),
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 135,
            child: Text(
              'XX运营后台',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.4286,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 31),
            child: InkWell(
              onTap: onExit,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 100,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFD7D7D7), width: 1),
                ),
                child: const Text(
                  '退出',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶栏高度，与 管理后台 弹窗一致。
const _topBarHeight = 65.0;

/// 右侧内容区：页面正文（业务静态页）或原型预览（未优化项）。
class _PageContent extends StatelessWidget {
  const _PageContent({super.key, required this.entry});

  final PrototypeEntry entry;

  @override
  Widget build(BuildContext context) {
    final bodyBuilder = _businessBodies[entry.id];
    return bodyBuilder != null
        ? ColoredBox(
            color: const Color(0xFFF5F6F8),
            child: bodyBuilder(context),
          )
        : OperationsPrototypePreview(entry: entry);
  }
}
