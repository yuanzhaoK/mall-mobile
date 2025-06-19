import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class GraphQLDiagnostics {
  /// 全面诊断GraphQL连接问题
  static Future<Map<String, dynamic>> diagnoseConnection(
    String endpoint,
  ) async {
    final results = <String, dynamic>{};

    debugPrint('🔍 开始GraphQL连接诊断: $endpoint');

    // 1. 基础连接测试
    results['basicConnection'] = await _testBasicConnection(endpoint);

    // 2. GraphQL格式测试
    results['graphqlFormat'] = await _testGraphQLFormat(endpoint);

    // 3. 超时测试
    results['timeoutTest'] = await _testWithTimeout(endpoint);

    // 4. Headers测试
    results['headersTest'] = await _testWithHeaders(endpoint);

    return results;
  }

  /// 测试基础HTTP连接
  static Future<Map<String, dynamic>> _testBasicConnection(
    String endpoint,
  ) async {
    try {
      debugPrint('📡 测试基础HTTP连接...');

      final response = await http
          .get(Uri.parse(endpoint.replaceAll('/graphql', '')))
          .timeout(const Duration(seconds: 10));

      return {
        'success': true,
        'statusCode': response.statusCode,
        'headers': response.headers,
        'responseTime': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      debugPrint('❌ 基础连接失败: $e');
      return {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }
  }

  /// 测试GraphQL格式请求
  static Future<Map<String, dynamic>> _testGraphQLFormat(
    String endpoint,
  ) async {
    try {
      debugPrint('🔗 测试GraphQL格式请求...');

      final query = {'query': '{ __typename }'};

      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(query),
          )
          .timeout(const Duration(seconds: 15));

      final responseBody = response.body;

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': responseBody,
        'bodyLength': responseBody.length,
        'isGraphQLResponse':
            responseBody.contains('data') || responseBody.contains('errors'),
      };
    } catch (e) {
      debugPrint('❌ GraphQL格式测试失败: $e');
      return {
        'success': false,
        'error': e.toString(),
        'errorType': e.runtimeType.toString(),
      };
    }
  }

  /// 测试不同超时时间
  static Future<Map<String, dynamic>> _testWithTimeout(String endpoint) async {
    final timeouts = [5, 10, 15, 30];
    final results = <String, dynamic>{};

    for (int timeout in timeouts) {
      try {
        debugPrint('⏱️ 测试 ${timeout}秒 超时...');

        final startTime = DateTime.now();

        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'query': '{ __typename }'}),
            )
            .timeout(Duration(seconds: timeout));

        final endTime = DateTime.now();
        final actualTime = endTime.difference(startTime).inMilliseconds;

        results['timeout_${timeout}s'] = {
          'success': true,
          'statusCode': response.statusCode,
          'actualTime': actualTime,
        };

        debugPrint('✅ ${timeout}秒超时测试成功，实际耗时: ${actualTime}ms');

        // 如果成功，不需要测试更长的超时
        break;
      } catch (e) {
        results['timeout_${timeout}s'] = {
          'success': false,
          'error': e.toString(),
        };
        debugPrint('❌ ${timeout}秒超时测试失败: $e');
      }
    }

    return results;
  }

  /// 测试不同Headers组合
  static Future<Map<String, dynamic>> _testWithHeaders(String endpoint) async {
    final headerCombinations = [
      {'Content-Type': 'application/json'},
      {'Content-Type': 'application/json', 'Accept': 'application/json'},
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Flutter GraphQL Client',
      },
    ];

    final results = <String, dynamic>{};

    for (int i = 0; i < headerCombinations.length; i++) {
      try {
        debugPrint('📋 测试Headers组合 ${i + 1}...');

        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: headerCombinations[i],
              body: json.encode({'query': '{ __typename }'}),
            )
            .timeout(const Duration(seconds: 15));

        results['headers_$i'] = {
          'success': true,
          'statusCode': response.statusCode,
          'headers': headerCombinations[i],
        };

        debugPrint('✅ Headers组合 ${i + 1} 成功');
      } catch (e) {
        results['headers_$i'] = {'success': false, 'error': e.toString()};
        debugPrint('❌ Headers组合 ${i + 1} 失败: $e');
      }
    }

    return results;
  }

  /// 生成诊断报告
  static String generateReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('🔍 GraphQL连接诊断报告');
    buffer.writeln('=' * 40);

    // 基础连接
    final basicConnection = results['basicConnection'] as Map<String, dynamic>;
    buffer.writeln('\n📡 基础连接测试:');
    if (basicConnection['success']) {
      buffer.writeln('✅ 成功 - 状态码: ${basicConnection['statusCode']}');
    } else {
      buffer.writeln('❌ 失败 - ${basicConnection['error']}');
    }

    // GraphQL格式
    final graphqlFormat = results['graphqlFormat'] as Map<String, dynamic>;
    buffer.writeln('\n🔗 GraphQL格式测试:');
    if (graphqlFormat['success']) {
      buffer.writeln('✅ 成功 - 状态码: ${graphqlFormat['statusCode']}');
      buffer.writeln(
        '   GraphQL响应: ${graphqlFormat['isGraphQLResponse'] ? '是' : '否'}',
      );
    } else {
      buffer.writeln('❌ 失败 - ${graphqlFormat['error']}');
    }

    // 超时测试
    final timeoutTest = results['timeoutTest'] as Map<String, dynamic>;
    buffer.writeln('\n⏱️ 超时测试:');
    timeoutTest.forEach((key, value) {
      if (key.startsWith('timeout_')) {
        final timeout = key.replaceAll('timeout_', '').replaceAll('s', '');
        if (value['success']) {
          buffer.writeln('✅ ${timeout}秒: 成功 (${value['actualTime']}ms)');
        } else {
          buffer.writeln('❌ ${timeout}秒: 失败');
        }
      }
    });

    buffer.writeln('\n🏁 诊断完成');
    return buffer.toString();
  }
}
