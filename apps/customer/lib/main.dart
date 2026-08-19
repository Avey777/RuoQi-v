import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'login_page.dart';

void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuoQi 客户',
      debugShowCheckedModeBanner: false,
      theme: ruoQiTheme(),
      home: const LoginPage(),
    );
  }
}
