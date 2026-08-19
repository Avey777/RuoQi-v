import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'login_page.dart';

void main() {
  runApp(const MemberApp());
}

class MemberApp extends StatelessWidget {
  const MemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuoQi 会员',
      debugShowCheckedModeBanner: false,
      theme: ruoQiTheme(),
      home: const LoginPage(),
    );
  }
}
