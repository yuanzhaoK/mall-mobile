// ignore_for_file: dead_code

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class NetworkHelper {
  /// 获取适合当前平台的API端点
  static String getApiEndpoint({String? port, String path = '/graphql'}) {
    // 直接使用全局配置
    if (path == '/graphql') {
      final endpoint = AppConfig.config.graphqlEndpoint;
      debugPrint('🔗 使用配置的GraphQL端点: $endpoint');
      debugPrint('🔧 配置来源: ${AppConfig.hasLocalConfig ? "本地配置" : "默认配置"}');
      return endpoint;
    }

    // 对于其他路径，从配置中提取基础信息
    final baseUrl = AppConfig.config.baseUrl;
    final uri = Uri.parse(baseUrl);
    final host = uri.host;
    final configPort = port ?? uri.port.toString();

    final endpoint = 'http://$host:$configPort$path';
    debugPrint('🔗 构建的API端点: $endpoint');
    return endpoint;
  }

  /// 获取常用的网络配置
  static Map<String, String> getDefaultHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  /// 检查网络连接状态的工具方法（可扩展）
  static Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
