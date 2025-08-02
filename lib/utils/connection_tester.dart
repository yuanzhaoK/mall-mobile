import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_home_mall/config/app_config.dart';

class ConnectionTester {
  /// 测试多个端点的连接状态
  static Future<String> findWorkingEndpoint({String port = '8082'}) async {
    // 从配置中获取当前设置的基础URL
    final currentBaseUrl = AppConfig.config.baseUrl;
    final currentHost = Uri.parse(currentBaseUrl).host;

    final endpoints = <String>[
      AppConfig.config.graphqlEndpoint, // 优先使用配置的端点
      'http://$currentHost:$port/graphql', // 使用配置的主机
      'http://10.0.2.2:$port/graphql', // Android模拟器
      'http://127.0.0.1:$port/graphql', // 本地回环
      'http://localhost:$port/graphql', // localhost
      'http://192.168.1.100:$port/graphql', // 常见路由器IP段
      'http://192.168.0.100:$port/graphql', // 另一个常见IP段
    ];

    debugPrint('🔍 开始测试GraphQL端点连接...');

    for (var endpoint in endpoints) {
      debugPrint('测试端点: $endpoint');

      try {
        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: {'Content-Type': 'application/json'},
              body: '{"query": "{ __typename }"}',
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200 || response.statusCode == 400) {
          // 200表示成功，400可能表示GraphQL语法错误但连接正常
          debugPrint('✅ 找到可用端点: $endpoint');
          return endpoint;
        } else {
          debugPrint('❌ 端点响应错误 ${response.statusCode}: $endpoint');
        }
      } catch (e) {
        debugPrint('❌ 端点连接失败: $endpoint - $e');
      }
    }

    debugPrint('🚨 所有端点都无法连接');
    return endpoints.first; // 返回默认端点
  }

  /// 获取本机网络信息
  static Future<List<String>> getNetworkInfo() async {
    var networkInfo = <String>[];

    try {
      for (final interface in await NetworkInterface.list()) {
        networkInfo.add('Interface: ${interface.name}');
        for (final addr in interface.addresses) {
          networkInfo.add('  Address: ${addr.address} (${addr.type})');
        }
      }
    } catch (e) {
      networkInfo.add('获取网络信息失败: $e');
    }

    return networkInfo;
  }

  /// 测试特定端点
  static Future<bool> testEndpoint(String endpoint) async {
    try {
      debugPrint('🔗 测试端点: $endpoint');

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: '{"query": "{ __typename }"}',
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📊 响应状态码: ${response.statusCode}');
      debugPrint('📋 响应内容: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 400;
    } catch (e) {
      debugPrint('❌ 连接测试失败: $e');
      debugPrint('❌ 错误类型: ${e.runtimeType}');
      if (e.toString().contains('SocketException')) {
        debugPrint('❌ 网络连接错误，可能是服务器未启动或防火墙阻止');
      } else if (e.toString().contains('TimeoutException')) {
        debugPrint('❌ 连接超时，服务器响应太慢');
      } else if (e.toString().contains('FormatException')) {
        debugPrint('❌ URL格式错误');
      }
      return false;
    }
  }

  /// 测试特定端点并返回详细结果
  static Future<Map<String, dynamic>> testEndpointDetailed(
    String endpoint,
  ) async {
    try {
      debugPrint('🔗 详细测试端点: $endpoint');

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: '{"query": "{ __typename }"}',
          )
          .timeout(const Duration(seconds: 10));

      return {
        'success': true,
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': response.body.length > 500
            ? '${response.body.substring(0, 500)}...'
            : response.body,
        'bodyLength': response.body.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }
  }
}
