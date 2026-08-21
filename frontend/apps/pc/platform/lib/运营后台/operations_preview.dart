// 运营后台原型页面预览（手写，勿被 rp2flutter 生成逻辑覆盖）。
//
// 弹窗内容区与右侧内容区共用的原型预览：按页面布局裁切
// （标准布局裁掉顶栏/侧栏/面包屑，个人中心子页面裁掉 64px 顶栏，
// 弹窗类页面整页展示），按宽度适配并支持纵向滚动。
import 'package:flutter/material.dart';

import '../prototype_registry.dart';

/// 个人中心子页面原型顶部有 64px “Personal Center” 顶栏，裁掉后整宽展示。
const personalCenterCropIds = <String>{
  'rjvZWT5Dw', // API秘钥
  'zBO3EW3ax', // 修改密码
  'i8ZEUJ9_N', // 设置密码
};

/// 弹窗类原型页（无顶栏/侧栏），整页展示。
const fullViewFallbackIds = <String>{
  '9U6oXpOcF', // 取消绑定
  'hG6mHCdXn', // 绑定(手机号、邮箱)
  'xdLB4kjm1', // 通用验证(手机号、邮箱)
  'Q5vjP_vc9', // 审核弹窗-外部
};

/// 标准布局原型页的裁切起点（去掉 190px 左侧栏与顶部菜单/面包屑）。
const standardCropOffset = Offset(215, 118);

/// 原型预览的裁切区域：
/// 标准布局裁掉侧栏与顶栏；个人中心子页面裁掉 64px 顶栏；弹窗类页面整页展示。
(Offset, Size) operationsPreviewGeometry(PrototypeEntry entry) {
  if (fullViewFallbackIds.contains(entry.id)) {
    return (Offset.zero, Size(entry.width, entry.height));
  }
  if (personalCenterCropIds.contains(entry.id)) {
    return (const Offset(0, 64), Size(entry.width, entry.height - 64));
  }
  return (
    standardCropOffset,
    Size(
      entry.width - standardCropOffset.dx,
      entry.height - standardCropOffset.dy,
    ),
  );
}

/// 原型预览：裁掉原型自带的顶栏/侧栏后按比例展示，支持纵向滚动。
class OperationsPrototypePreview extends StatelessWidget {
  const OperationsPrototypePreview({super.key, required this.entry});

  final PrototypeEntry entry;

  @override
  Widget build(BuildContext context) {
    final (cropOffset, viewSize) = operationsPreviewGeometry(entry);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FittedBox(
            // 默认按宽度适配：窄而高的页面不再被整体缩小，
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
