import 'package:ruoqi_network/ruoqi_network.dart';

import '../models/system_info.dart';

/// platform 后端的 API 客户端。
///
/// baseUrl、接口路径、DTO 解析都只属于 platform，
/// 与 customer 的后端互不相干。
///
/// 用法：
/// ```dart
/// final client = RuoQiNetworkClient(
///   baseUrl: String.fromEnvironment('PLATFORM_API_BASE_URL', defaultValue: 'https://platform.example.com'),
/// );
/// final api = PlatformApi(client);
/// ```
class PlatformApi {
  const PlatformApi(this._client);

  final RuoQiNetworkClient _client;

  /// 获取平台系统信息。
  Future<SystemInfo> getSystemInfo() async {
    final data = await _client.get('/system/info');
    return SystemInfo.fromJson(data as Map<String, dynamic>);
  }
}
