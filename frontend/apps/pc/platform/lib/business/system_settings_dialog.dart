import 'package:flutter/material.dart';

import '../prototype_registry.dart';

/// 系统管理（一账通 ID 独立体系）入口弹窗。
///
/// 样式还原自 管理后台 原型：
/// - 顶部紫色导航栏（#7172AD）：品牌名 + 板块 Tab + 退出管理；
/// - 左侧菜单（300px，右侧描边，含搜索框）：参照 权限 页的左侧面板实现，
///   列出当前板块的子菜单，选中项为 #807172AD 紫色底 + 白字；
/// - 右侧内容区：按比例展示对应原型页面（裁掉原型自身的顶栏与侧栏，避免重复）。
///
/// 后续接入真实业务页面时，把 [_sections] 中每一项的 pageId 换成真实页面即可。
class SystemSettingsDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
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
    _SidebarItem('保存权限', 'PRkO8x-5W', Offset(325, 189), Size(1585, 930)),
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

/// 原型页面顶部导航栏高度。
const _topBarHeight = 65.0;

/// 原型页面标题条（顶栏下方、侧栏上方）高度。
const _titleStripHeight = 80.0;

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

  @override
  Widget build(BuildContext context) {
    final item = _section.items[_itemIndex];
    final entry = prototypePageById[item.pageId]!;
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _TopBar(
            sectionIndex: _sectionIndex,
            onSectionSelected: _selectSection,
            onExit: () => Navigator.of(context).pop(),
          ),
          _TitleStrip(label: _section.label),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

/// 顶部紫色导航栏：品牌名 + 板块 Tab + 退出管理。
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.sectionIndex,
    required this.onSectionSelected,
    required this.onExit,
  });

  final int sectionIndex;
  final ValueChanged<int> onSectionSelected;
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
              'XX管理后台',
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
          for (var i = 0; i < _sections.length; i++)
            _TabButton(
              label: _sections[i].label,
              selected: i == sectionIndex,
              onTap: () => onSectionSelected(i),
            ),
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
                  '退出管理',
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: _topBarHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.white : const Color(0xA1FFFFFF),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                height: 1.4286,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 顶栏下方的标题条，展示当前板块名（还原原型 65~145 区间的样式）。
class _TitleStrip extends StatelessWidget {
  const _TitleStrip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _titleStripHeight,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16),
      color: Colors.white,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 21,
          color: Color(0xFF949AAB),
          fontWeight: FontWeight.w700,
          height: 0.9524,
        ),
      ),
    );
  }
}

/// 左侧菜单：300px 宽、右侧描边，含搜索框；
/// 选中项样式参照 权限 页（#807172AD 底 + 白字）。
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
    final items = widget.section.items
        .where((item) => item.label.contains(_query))
        .toList();
    return Container(
      width: _leftMenuWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFD7D7D7), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFFD7D7D7), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _query = value.trim());
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: '搜索菜单',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFAAAAAA),
                        ),
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.search,
                      size: 18,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      '无匹配菜单',
                      style: TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
                    ),
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
                        child: Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 40),
                          color: selected
                              ? const Color(0x807172AD)
                              : Colors.transparent,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF333333),
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
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
  });

  final PrototypeEntry entry;
  final Offset cropOffset;
  final Size viewSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F6F8),
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
