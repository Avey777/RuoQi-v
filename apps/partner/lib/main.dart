import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'home_page.dart';

void main() {
  runApp(const PartnerApp());
}

class PartnerApp extends StatelessWidget {
  const PartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuoQi 伙伴',
      debugShowCheckedModeBanner: false,
      theme: ruoQiTheme(),
      home: const HomePage(),
    );
  }
}
