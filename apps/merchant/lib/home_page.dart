import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _features = [
    (
      icon: Icons.dashboard_outlined,
      title: '数据概览',
      subtitle: 'dashboard',
    ),
    (
      icon: Icons.warehouse_outlined,
      title: '仓储管理',
      subtitle: 'wms',
    ),
    (
      icon: Icons.storefront_outlined,
      title: '店铺管理',
      subtitle: 'shop',
    ),
    (
      icon: Icons.settings_outlined,
      title: '商户设置',
      subtitle: 'settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RuoQi 商户')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isPc = RuoQiPlatformScope.of(context) == RuoQiPlatform.pc;
          final cards = [
            for (final feature in _features) _FeatureCard(feature: feature),
          ];

          if (isPc) {
            return Column(
              children: [
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: cards,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: AppBadge(appName: 'merchant', version: '1.0.0'),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final card in cards) ...[
                card,
                const SizedBox(height: 8),
              ],
              const Center(
                child: AppBadge(appName: 'merchant', version: '1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final ({IconData icon, String title, String subtitle}) feature;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          feature.icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(feature.title),
        subtitle: Text(feature.subtitle),
      ),
    );
  }
}
