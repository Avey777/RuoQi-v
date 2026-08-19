import 'package:flutter/material.dart';

/// RuoQi 品牌主题色。
const Color ruoQiSeedColor = Color(0xFF1677FF);

/// 构建 RuoQi 品牌 Material 3 主题。
ThemeData ruoQiTheme({Brightness brightness = Brightness.light}) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: ruoQiSeedColor,
      brightness: brightness,
    ),
    useMaterial3: true,
  );
}
