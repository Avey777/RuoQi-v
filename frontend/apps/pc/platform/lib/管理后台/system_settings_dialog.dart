import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../console_widgets/console_top_bar.dart';
import '../prototype_registry.dart';
import 'business/auth_login_settings_page.dart';
import 'business/email_settings_page.dart';
import 'business/encoding_rules_page.dart';
import 'business/general_settings_page.dart';
import 'business/localization_settings_page.dart';
import 'business/permission_management/permission_management_page.dart';
import 'business/sms_settings_page.dart';
import 'business/verification_messages_page.dart';
import 'business/user_management/roles_page.dart';
import 'business/user_management/user_management_page.dart';

/// 系统管理（一账通 ID 独立体系）入口弹窗。
///
/// 按 DESIGN-consensus.md 规范实现：
/// - 顶部导航栏：surface 背景 + onSurface 文本、高 56、无阴影（§6.7）；
/// - 左侧菜单：surface + `outlineVariant` 描边，选中项 `primaryContainer` + 主色；
/// - 右侧内容区：按比例展示对应原型页面（裁掉原型自身的顶栏与侧栏，避免重复）。
///
/// 后续接入真实业务页面时，把 [_sections] 中每一项的 pageId 换成真实页面即可。
class SystemSettingsDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim,
      builder: (_) => const _SystemSettingsDialog(),
    );
  }
}

class _SidebarItem {
  const _SidebarItem(this.label, this.pageId, this.cropOffset, this.viewSize);

  final String label;
  final String pageId;

  /// 原型页面内容区相对画布左上角的裁切起点（去掉原型自带的顶栏/侧栏）。
  final Offset cropOffset;

  /// 内容区展示尺寸（实际内容边界 + 少量安全边距）。
  final Size viewSize;
}

class _SidebarSection {
  const _SidebarSection(this.label, this.items);

  final String label;
  final List<_SidebarItem> items;
}

/// 已优化为业务静态页的菜单项（原型 pageId → 正文组件）。
/// 未收录的菜单项仍回退到原型预览。
final _businessBodies = <String, WidgetBuilder>{
  'ja7Hc6Rku': (_) => const VerificationMessagesBody(),
  '1_d9YGUlp': (_) => const SmsSettingsBody(),
  'S6BHB6tQQ': (_) => const AuthLoginBody(),
  'Z0K3xYMgZ': (_) => const GeneralSettingsBody(),
  'EDryRTyjx': (_) => const LocalizationBody(),
  'j7jNSg7DW': (_) => const EmailSettingsBody(),
  'jOWxGolr4': (_) => const EncodingRulesBody(),
  'StMQ4cWti': (_) => const UsersBody(),
  'c50tDa7pFz': (_) => const PermissionsBody(),
};

/// 七个板块及其左侧菜单项，顺序与 管理后台 原型顶部导航一致。
/// 每个菜单项的裁切起点与展示尺寸由原型页面实际内容边界计算得到，
/// 避免固定偏移把页面元素裁掉。
const _sections = [
  _SidebarSection('设置', [
    _SidebarItem('通用', 'Z0K3xYMgZ', Offset(260, 145), Size(686, 947)),
    _SidebarItem('本地化', 'EDryRTyjx', Offset(260, 145), Size(686, 2776)),
    _SidebarItem('电子邮件', 'j7jNSg7DW', Offset(260, 145), Size(686, 1260)),
    _SidebarItem('编码规则', 'jOWxGolr4', Offset(244, 145), Size(1668, 907)),
    _SidebarItem('短信', '1_d9YGUlp', Offset(250, 145), Size(516, 246)),
    _SidebarItem('auth登录', 'S6BHB6tQQ', Offset(250, 145), Size(516, 246)),
    _SidebarItem('验证消息', 'ja7Hc6Rku', Offset(250, 145), Size(1056, 770)),
  ]),
  _SidebarSection('用户', [
    _SidebarItem('用户', 'StMQ4cWti', Offset(228, 85), Size(1684, 997)),
    _SidebarItem('角色', 'c11sjQSJ1', Offset(244, 145), Size(1668, 740)),
  ]),
  _SidebarSection('权限', [
    _SidebarItem('权限', 'c50tDa7pFz', Offset(325, 189), Size(1585, 930)),
  ]),
  _SidebarSection('菜单', [
    _SidebarItem('菜单', 'XdvqIaB7_', Offset(244, 145), Size(1657, 613)),
  ]),
  _SidebarSection('基础', [
    _SidebarItem('世界地理规划', 'xZC4jWHWG', Offset(228, 145), Size(1680, 933)),
    _SidebarItem('地区&国家', 'X0RCGzKUh', Offset(244, 85), Size(1664, 991)),
    _SidebarItem('导入地区', '2SonlUXcm', Offset(244, 118), Size(1686, 892)),
    _SidebarItem('UTC', 'OJxsBTfEu', Offset(244, 138), Size(1583, 1133)),
    _SidebarItem('时区数据库', 'aDfXovdwxK', Offset(244, 138), Size(1583, 306)),
    _SidebarItem('货币', 'kFob4v_V6', Offset(228, 85), Size(1680, 948)),
    _SidebarItem('历史汇率', 'zvYxL_RQg', Offset(228, 85), Size(1680, 948)),
  ]),
  _SidebarSection('语言', [
    _SidebarItem('多语言', 'u7tmb4OBc', Offset(244, 85), Size(1664, 775)),
    _SidebarItem('翻译', 'UXGGZPuR9', Offset(255, 85), Size(1650, 620)),
    _SidebarItem('导入', 'TpHbkdGMq', Offset(678, 93), Size(1192, 575)),
    _SidebarItem('导出', 'yq9YeBSKX', Offset(678, 155), Size(716, 401)),
  ]),
  _SidebarSection('日志', [
    _SidebarItem('验证日志', 'JSCSQH1Kc', Offset(228, 93), Size(1684, 689)),
    _SidebarItem('操作日志', 'WkvHvCC8i', Offset(228, 93), Size(1684, 689)),
    _SidebarItem('登录日志', 'BYfUtX8cV', Offset(228, 93), Size(1684, 899)),
    _SidebarItem('支付日志', 'DwOYjtX0r', Offset(228, 93), Size(1684, 689)),
  ]),
];

/// 左侧菜单宽度，与 权限 页左侧面板一致。
const _leftMenuWidth = 300.0;

class _SystemSettingsDialog extends StatefulWidget {
  const _SystemSettingsDialog();

  @override
  State<_SystemSettingsDialog> createState() => _SystemSettingsDialogState();
}

class _SystemSettingsDialogState extends State<_SystemSettingsDialog> {
  int _sectionIndex = 0;
  int _itemIndex = 0;

  _SidebarSection get _section => _sections[_sectionIndex];

  void _selectSection(int index) {
    setState(() {
      _sectionIndex = index;
      _itemIndex = 0;
    });
  }

  void _selectItem(int index) {
    setState(() => _itemIndex = index);
  }

  /// 角色页「设置权限」跳转到权限板块（选中 权限 子项）。
  void _openPermissions() {
    setState(() {
      _sectionIndex = _sections.indexWhere((section) => section.label == '权限');
      _itemIndex = 0;
    });
  }

  Widget? _bodyFor(BuildContext context, _SidebarItem item) {
    if (item.pageId == 'c11sjQSJ1') {
      return RolesBody(onOpenPermissions: _openPermissions);
    }
    return _businessBodies[item.pageId]?.call(context);
  }

  @override
  Widget build(BuildContext context) {
    final item = _section.items[_itemIndex];
    final entry = prototypePageById[item.pageId]!;
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          ConsoleTopBar(
            title: 'XX管理后台',
            sectionIndex: _sectionIndex,
            onSectionSelected: _selectSection,
            onExit: () => Navigator.of(context).pop(),
            tabs: [for (final s in _sections) s.label],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 权限板块使用页面自身的角色左侧栏（原型中角色栏位于最左侧），
                // 隐藏通用左菜单，板块切换仍通过顶部导航。
                if (_section.label != '权限')
                  _LeftMenu(
                    section: _section,
                    selectedIndex: _itemIndex,
                    onSelected: _selectItem,
                  ),
                Expanded(
                  child: _PageContentView(
                    key: ValueKey(item.pageId),
                    entry: entry,
                    cropOffset: item.cropOffset,
                    viewSize: item.viewSize,
                    body: _bodyFor(context, item),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 左侧菜单：300px 宽、右侧描边，含搜索框；
/// 选中项 `primaryContainer` 底 + 主色文本（规范 §6.6/§1.2）。
class _LeftMenu extends StatefulWidget {
  const _LeftMenu({
    required this.section,
    required this.selectedIndex,
    required this.onSelected,
  });

  final _SidebarSection section;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_LeftMenu> createState() => _LeftMenuState();
}

class _LeftMenuState extends State<_LeftMenu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = widget.section.items
        .where((item) => item.label.contains(_query))
        .toList();
    return Container(
      width: _leftMenuWidth,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RuQiSpacing.lg,
              RuQiSpacing.md,
              RuQiSpacing.lg,
              RuQiSpacing.sm,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() => _query = value.trim());
              },
              decoration: const InputDecoration(
                hintText: '搜索菜单',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: RuQiSpacing.xs,
                  vertical: 10,
                ),
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('无匹配菜单', style: TextStyle(fontSize: 14)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final originalIndex = widget.section.items.indexOf(item);
                      final selected = originalIndex == widget.selectedIndex;
                      return InkWell(
                        onTap: () => widget.onSelected(originalIndex),
                        onHover: (_) {},
                        child: Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 40),
                          color: selected
                              ? theme.colorScheme.primaryContainer
                              : Colors.transparent,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                              horizontal: RuQiSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? theme.colorScheme.primaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 内容区：裁掉原型页面自带的顶栏与左侧栏后按比例展示，支持缩放。
class _PageContentView extends StatelessWidget {
  const _PageContentView({
    super.key,
    required this.entry,
    required this.cropOffset,
    required this.viewSize,
    this.body,
  });

  final PrototypeEntry entry;
  final Offset cropOffset;
  final Size viewSize;

  /// 已优化为业务页的正文；为空时回退到原型裁剪预览。
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    if (body != null) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: body,
      );
    }
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            // 默认按宽度适配：窄而高的页面（如 本地化）不再被整体缩小，
            // 超高内容通过纵向滚动查看。
            fit: BoxFit.fitWidth,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: viewSize.width,
              height: viewSize.height,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: entry.width,
                  maxHeight: entry.height,
                  child: Transform.translate(
                    offset: -cropOffset,
                    child: entry.builder(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
