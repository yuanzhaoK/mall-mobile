// ignore_for_file: dead_code

import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkHelper {
  /// 获取适合当前平台的API端点
  static String getApiEndpoint({
    String port = '8082',
    String path = '/graphql',
  }) {
    String host;

    // 如果是真机测试，请将这里改为你的电脑IP地址
    const String realDeviceIP = '10.241.25.183'; // 你的电脑IP地址

    // 设置为true来启用真机模式
    const bool isRealDevice = false; // 改为true来使用真机IP

    if (kIsWeb) {
      // Web平台直接使用localhost
      host = realDeviceIP;
    } else if (Platform.isAndroid) {
      // Android平台
      if (isRealDevice) {
        host = realDeviceIP; // 真机使用电脑的实际IP地址
      } else {
        host = realDeviceIP; // 模拟器使用10.0.2.2来访问宿主机
      }
    } else if (Platform.isIOS) {
      // iOS平台
      if (isRealDevice) {
        host = realDeviceIP; // 真机使用电脑的实际IP地址
      } else {
        // iOS模拟器也尝试使用127.0.0.1或者你的实际IP
        host = realDeviceIP; // 尝试使用127.0.0.1而不是localhost
        // 如果127.0.0.1不行，可以尝试使用实际IP：
        // host = realDeviceIP;
      }
    } else {
      // 其他平台（桌面应用等）使用localhost
      host = realDeviceIP;
    }

    final endpoint = 'http://$host:$port$path';
    debugPrint('Using API endpoint: $endpoint');
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
