import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PortScanner {
  /// 扫描常见端口寻找GraphQL服务
  static Future<List<String>> scanForGraphQLServices(String host) async {
    List<String> foundServices = [];

    // 常见的GraphQL端口
    final ports = [
      8082,
      // 8080,
      // 3000,
      // 4000,
      // 5000,
      // 8000,
      // 8001,
      // 8888,
      // 9000,
      // 3001,
      // 4001,
      // 5001,
      // 8003,
      // 8004,
      // 8005,
    ];

    final paths = ['/graphql', '/api/graphql', '/graphql-api'];

    debugPrint('🔍 开始扫描 $host 的GraphQL服务...');

    for (int port in ports) {
      for (String path in paths) {
        final url = 'http://$host:$port$path';

        try {
          debugPrint('扫描: $url');

          final response = await http
              .post(
                Uri.parse(url),
                headers: {'Content-Type': 'application/json'},
                body: '{"query": "{ __typename }"}',
              )
              .timeout(const Duration(seconds: 2));

          if (response.statusCode == 200 ||
              response.statusCode == 400 ||
              response.statusCode == 500) {
            // 检查响应是否看起来像GraphQL
            final body = response.body.toLowerCase();
            if (body.contains('graphql') ||
                body.contains('data') ||
                body.contains('errors') ||
                body.contains('typename')) {
              foundServices.add(url);
              debugPrint('✅ 找到GraphQL服务: $url');
            }
          }
        } catch (e) {
          // 忽略连接错误，继续扫描
        }
      }
    }

    debugPrint('🏁 扫描完成，找到 ${foundServices.length} 个服务');
    return foundServices;
  }

  /// 检查特定端口是否开放
  static Future<bool> isPortOpen(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 2),
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 扫描端口范围
  static Future<List<int>> scanPortRange(
    String host,
    int startPort,
    int endPort,
  ) async {
    List<int> openPorts = [];

    debugPrint('🔍 扫描 $host 端口范围 $startPort-$endPort');

    for (int port = startPort; port <= endPort; port++) {
      if (await isPortOpen(host, port)) {
        openPorts.add(port);
        debugPrint('✅ 端口 $port 开放');
      }
    }

    return openPorts;
  }

  /// 测试HTTP服务响应
  static Future<Map<String, dynamic>> testHttpService(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      return {
        'url': url,
        'status': response.statusCode,
        'success': true,
        'headers': response.headers,
        'body': response.body.length > 200
            ? '${response.body.substring(0, 200)}...'
            : response.body,
      };
    } catch (e) {
      return {'url': url, 'success': false, 'error': e.toString()};
    }
  }
}
