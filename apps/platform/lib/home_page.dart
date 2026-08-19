import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RuoQi Platform')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('平台服务', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            const AppBadge(appName: 'platform', version: '1.0.0'),
          ],
        ),
      ),
    );
  }
}
