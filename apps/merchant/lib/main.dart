import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'home_page.dart';

void main() {
  runApp(const MerchantApp());
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuoQi 商户',
      debugShowCheckedModeBanner: false,
      theme: ruoQiTheme(),
      home: const HomePage(),
    );
  }
}
