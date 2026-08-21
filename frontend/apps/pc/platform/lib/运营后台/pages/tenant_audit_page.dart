import 'package:flutter/material.dart';

import '../../prototype_registry.dart';
import '../operations_action_dialog.dart';
import '../项目/审核弹窗-外部-拆分.dart';

/// 开户审核（运营后台）——业务静态页。
class TenantAuditPage extends StatelessWidget {
  const TenantAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('开户审核')),
      body: const TenantAuditBody(),
    );
  }
}

/// 开户审核正文（供运营后台对话框右侧内容区内嵌展示）。
class TenantAuditBody extends StatelessWidget {
  const TenantAuditBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _auditCard(context, '启明信息技术有限公司', '申请人：陈晨', '2024-08-18 10:24'),
        _auditCard(context, '宏图物流有限公司', '申请人：刘洋', '2024-08-17 15:40'),
        _auditCard(context, '绿源环保科技有限公司', '申请人：孙悦', '2024-08-16 09:12'),
      ],
    );
  }

  Widget _auditCard(
    BuildContext context,
    String name,
    String applicant,
    String time,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name),
        subtitle: Text('$applicant · $time'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => showOperationsActionDialog(
                context,
                title: '查看',
                entry: prototypePageById['CbJh5Rt66c'],
              ),
              child: const Text('查看'),
            ),
            FilledButton(
              onPressed: () => showOperationsActionDialog(
                context,
                title: '审核',
                child: const AuditFormOptionalDialog(),
                size: const Size(700, 600),
              ),
              child: const Text('通过'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => showOperationsActionDialog(
                context,
                title: '审核',
                child: const AuditFormRequiredDialog(),
                size: const Size(700, 600),
              ),
              child: const Text('拒绝'),
            ),
          ],
        ),
      ),
    );
  }
}
