import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'home_page.dart';

void main() {
  runApp(const PlatformApp());
}

class PlatformApp extends StatelessWidget {
  const PlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.pc,
      child: MaterialApp(
        title: 'RuoQi Platform',
        debugShowCheckedModeBanner: false,
        theme: ruoQiTheme(),
        home: const HomePage(),
      ),
    );
  }
}
