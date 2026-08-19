import 'package:ruoqi_network/ruoqi_network.dart';

import '../models/partner_profile.dart';

/// 合作伙伴后端的 API 客户端。
///
/// 只属于 partner，与其他 App 的后端互不相干。
///
/// 用法：
/// ```dart
/// final client = RuoQiNetworkClient(
///   baseUrl: String.fromEnvironment('PARTNER_API_BASE_URL', defaultValue: 'https://partner.example.com'),
/// );
/// final api = PartnerApi(client);
/// ```
class PartnerApi {
  const PartnerApi(this._client);

  final RuoQiNetworkClient _client;

  /// 获取合作伙伴资料。
  Future<PartnerProfile> getProfile() async {
    final data = await _client.get('/partner/profile');
    return PartnerProfile.fromJson(data as Map<String, dynamic>);
  }
}
