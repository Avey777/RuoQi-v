import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'login_page.dart';

void main() {
  runApp(const IamUserApp());
}

class IamUserApp extends StatelessWidget {
  const IamUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuoQi IAM User',
      debugShowCheckedModeBanner: false,
      theme: ruoQiTheme(),
      home: const LoginPage(),
    );
  }
}
