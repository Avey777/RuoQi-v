import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import '../settings_content_dialog.dart';
import '../shared/table_card.dart';
import '../用户/user_management_widgets.dart';

/// 大洲 / 大洋板块。
class GeoPlate {
  const GeoPlate({
    required this.code,
    required this.zhName,
    required this.enName,
  });

  final String code;
  final String zhName;
  final String enName;
}

const geoPlates = [
  GeoPlate(code: 'AS1', zhName: '亚洲', enName: 'Asia'),
  GeoPlate(code: 'AS2', zhName: '欧洲', enName: 'Europe'),
  GeoPlate(code: 'AS3', zhName: '非洲', enName: 'Africa'),
  GeoPlate(code: 'AS4', zhName: '北美洲', enName: 'North America'),
  GeoPlate(code: 'AS5', zhName: '南美洲', enName: 'South America'),
  GeoPlate(code: 'AS6', zhName: '南极洲', enName: 'Antarctica'),
  GeoPlate(code: 'AS7', zhName: '大洋洲', enName: 'Oceania'),
  GeoPlate(code: 'BS1', zhName: '太平洋', enName: 'Pacific Ocean'),
  GeoPlate(code: 'BS2', zhName: '大西洋', enName: 'Atlantic Ocean'),
  GeoPlate(code: 'BS3', zhName: '印度洋', enName: 'Indian Ocean'),
  GeoPlate(code: 'BS4', zhName: '北冰洋', enName: 'Arctic Ocean'),
];

/// 基础-世界地理规划 业务正文（对应 世界地理规划 原型）。
class WorldGeoBody extends StatelessWidget {
  const WorldGeoBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        const UserPageHeader(
          title: '世界地理规划',
          description: '地球板块地理划分资料。',
        ),
        const SizedBox(height: RuQiSpacing.md),
        TableCard(
          columns: const [
            (label: '代号', flex: 8),
            (label: '大洲(基本语)名称', flex: 14),
            (label: '英文简称', flex: 14),
            (label: '操作', flex: 8),
          ],
          rowCount: geoPlates.length,
          rowBuilder: (context, index) {
            final plate = geoPlates[index];
            return [
              CellText(plate.code, strong: true),
              CellText(plate.zhName),
              CellText(plate.enName, muted: true),
              TextButton(
                style: RuQiButtonStyles.tertiary(context),
                onPressed: () => showGeoPlateEditPanel(context, plate),
                child: const Text('编辑'),
              ),
            ];
          },
        ),
      ],
    );
  }
}

/// 打开大洲 / 大洋编辑面板。
Future<void> showGeoPlateEditPanel(BuildContext context, GeoPlate plate) {
  return showSystemSettingsPanel(
    context,
    title: '编辑 ${plate.zhName}',
    child: GeoPlateEditForm(plate: plate),
  );
}

/// 大洲 / 大洋编辑表单：代号 / 基本语名称 / 英文简称。
class GeoPlateEditForm extends StatefulWidget {
  const GeoPlateEditForm({super.key, required this.plate});

  final GeoPlate plate;

  @override
  State<GeoPlateEditForm> createState() => _GeoPlateEditFormState();
}

class _GeoPlateEditFormState extends State<GeoPlateEditForm> {
  late final TextEditingController _code;
  late final TextEditingController _zhName;
  late final TextEditingController _enName;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: widget.plate.code);
    _zhName = TextEditingController(text: widget.plate.zhName);
    _enName = TextEditingController(text: widget.plate.enName);
  }

  @override
  void dispose() {
    _code.dispose();
    _zhName.dispose();
    _enName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _code,
                  decoration: const InputDecoration(labelText: '代号'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _zhName,
                  decoration: const InputDecoration(labelText: '大洲(基本语)名称'),
                ),
                const SizedBox(height: RuQiSpacing.md),
                TextField(
                  controller: _enName,
                  decoration: const InputDecoration(labelText: '英文简称'),
                ),
              ],
            ),
          ),
        ),
        UserFormActions(
          confirmLabel: '保存修改',
          onConfirm: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
