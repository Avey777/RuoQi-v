// 运营后台左侧菜单面板（手写，勿被 rp2flutter 生成逻辑覆盖）。
//
// 左侧菜单为两级树形导航：一级为板块（租户 / 团队空间 / 项目 /
// API授权 / 个人中心），二级为主页面。查看/编辑/删除/绑定等动作
// 子页面不进入菜单，由主页面按钮以弹窗方式打开。
import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../prototype_registry.dart';

/// 板块顺序与 运营后台 原型一致（租户 / 团队空间 / 项目 / API授权 / 个人中心）。
const operationsSections = ['租户', '团队空间', '项目', 'API授权', '个人中心'];

/// 指定板块下的运营后台原型条目（顺序与原型注册表一致）。
List<PrototypeEntry> operationsEntriesOf(String section) {
  return [
    for (final e in prototypePages)
      if (e.path.startsWith('ops_pages/') &&
          (e.path.split('/').length > 2 ? e.path.split('/')[1] : '其他') ==
              section)
        e,
  ];
}

/// 主页面：板块下第一层页面（路径深度 3）；弹窗类页面不进入菜单。
List<PrototypeEntry> operationsMainPagesOf(String section) {
  return [
    for (final e in prototypePages)
      if (e.path.startsWith('ops_pages/') &&
          (e.path.split('/').length > 2 ? e.path.split('/')[1] : '其他') ==
              section &&
          e.path.split('/').length == 3 &&
          e.id != 'Q5vjP_vc9') // 审核弹窗-外部
        e,
  ];
}

/// 树形菜单节点：一级为板块组（entry 为 null），其余对应原型页面。
class _TreeNode {
  const _TreeNode(this.title, this.entry, this.children, this.path);

  final String title;
  final PrototypeEntry? entry;
  final List<_TreeNode> children;

  /// 节点在原型路径中的前缀，用于展开状态跟踪。
  final String path;
}

/// 全量菜单树：一级为板块组，二级为主页面（均为叶子节点）。
List<_TreeNode> _buildFullTree() {
  return [
    for (final s in operationsSections)
      _TreeNode(s, null, [
        for (final e in operationsMainPagesOf(s))
          _TreeNode(e.title, e, const [], e.path),
      ], 'ops_pages/$s'),
  ];
}

/// 搜索过滤：节点自身或任意子孙命中时保留，命中子树的祖先一并保留。
List<_TreeNode> _filterTree(List<_TreeNode> nodes, String query) {
  if (query.isEmpty) {
    return nodes;
  }
  return [
    for (final n in nodes)
      if (n.title.contains(query) ||
          n.children.any((c) => _filterTree([c], query).isNotEmpty))
        _TreeNode(n.title, n.entry, _filterTree(n.children, query), n.path),
  ];
}

class OperationsSidebar extends StatefulWidget {
  const OperationsSidebar({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  /// 当前选中的原型条目 id（用于高亮）。
  final String? selectedId;

  /// 点击菜单项时回调（由弹窗在右侧内容区展示对应页面）。
  final ValueChanged<PrototypeEntry> onSelected;

  @override
  State<OperationsSidebar> createState() => _OperationsSidebarState();
}

class _OperationsSidebarState extends State<OperationsSidebar> {
  String _query = '';

  /// 用户折叠的节点路径；板块组默认只展开包含当前选中页的那一个。
  final Set<String> _collapsed = {};

  String get _selectedSection {
    final id = widget.selectedId;
    if (id == null) {
      return '';
    }
    final entry = prototypePageById[id];
    if (entry == null) {
      return '';
    }
    final parts = entry.path.split('/');
    return parts.length > 2 ? parts[1] : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roots = _filterTree(_buildFullTree(), _query);

    return Container(
      width: 300,
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
            child: roots.isEmpty
                ? const Center(
                    child: Text('无匹配菜单', style: TextStyle(fontSize: 14)),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      for (final node in roots) ..._buildRows(node, 0),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRows(_TreeNode node, int depth) {
    final theme = Theme.of(context);
    final hasChildren = node.children.isNotEmpty;
    // 搜索时强制展开，方便查看命中项。
    final expanded = _isExpanded(node);
    final isSection = node.entry == null && hasChildren;
    final selected = node.entry?.id == widget.selectedId;
    return [
      InkWell(
        onTap: () => _onNodeTap(node, expanded, isSection),
        child: Container(
          height: 40,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 12.0 + depth * 20),
          color: selected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: hasChildren
                    ? Icon(
                        expanded ? Icons.expand_more : Icons.chevron_right,
                        size: 16,
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  node.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSection || selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (hasChildren && expanded)
        for (final child in node.children) ..._buildRows(child, depth + 1),
    ];
  }

  bool _isExpanded(_TreeNode node) {
    if (_query.isNotEmpty) {
      return true;
    }
    if (_collapsed.contains(node.path)) {
      return false;
    }
    // 板块组默认只展开包含当前选中页的那一个。
    final isSection = node.entry == null && node.children.isNotEmpty;
    if (isSection) {
      return _sectionOf(node.path) == _selectedSection;
    }
    return true;
  }

  String _sectionOf(String path) {
    final parts = path.split('/');
    return parts.length >= 2 ? parts[1] : '';
  }

  void _onNodeTap(_TreeNode node, bool expanded, bool isSection) {
    final entry = node.entry;
    if (entry != null) {
      widget.onSelected(entry);
    }
    if (node.children.isEmpty) {
      return;
    }
    setState(() {
      if (expanded) {
        _collapsed.add(node.path);
      } else {
        _collapsed.remove(node.path);
        // 展开板块组时顺带打开其第一个页面。
        if (isSection) {
          final first = node.children.firstWhere(
            (c) => c.entry != null,
            orElse: () => node.children.first,
          );
          if (first.entry != null) {
            widget.onSelected(first.entry!);
          }
        }
      }
    });
  }
}
