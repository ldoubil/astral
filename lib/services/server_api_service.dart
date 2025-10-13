import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/server_api_response.dart';

class ServerApiService {
  static const String _baseUrl = 'https://uptime.easytier.cn/api';
  static const Duration _timeout = Duration(seconds: 10);

  /// 获取公共服务器列表
  static Future<ServerApiResponse> getPublicServers({
    int page = 1,
    int perPage = 200,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/nodes')
          .replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ServerApiResponse.fromJson(jsonData);
      } else {
        throw ServerApiException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerApiException) {
        rethrow;
      }
      throw ServerApiException('网络请求失败: $e');
    }
  }
}

/// 服务器API异常类
class ServerApiException implements Exception {
  final String message;
  final int? statusCode;

  ServerApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerApiException: $message';
}