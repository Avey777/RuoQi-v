import 'package:ruoqi_network/ruoqi_network.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';

/// IAM 后端的 API 客户端。
///
/// 只属于 iam_user，platform 不会用到：
/// baseUrl、接口路径、DTO 解析都在这里维护。
///
/// 用法：
/// ```dart
/// final client = RuoQiNetworkClient(
///   baseUrl: String.fromEnvironment('IAM_API_BASE_URL', defaultValue: 'https://iam.example.com'),
///   tokenProvider: MyTokenProvider(),
/// );
/// final api = IamApi(client);
/// ```
class IamApi {
  const IamApi(this._client);

  final RuoQiNetworkClient _client;

  /// 登录，返回令牌与用户 ID。
  Future<LoginResponse> login(LoginRequest request) async {
    final data = await _client.post('/auth/login', data: request.toJson());
    return LoginResponse.fromJson(data as Map<String, dynamic>);
  }
}
