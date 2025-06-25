import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// GraphQL客户端配置和管理
class GraphQLClientManager {
  // 使用确认可用的GraphQL端点
  static String get endpoint {
    const endpoint = 'http://10.241.25.183:8082/graphql';
    debugPrint('🔗 GraphQL使用端点: $endpoint');
    return endpoint;
  }

  static GraphQLClient? _client;
  static String? _token;

  /// 获取GraphQL客户端实例
  static GraphQLClient get client {
    if (_client == null) {
      _client = _createClient();
      debugPrint('🔗 GraphQL客户端已配置，端点: $endpoint');
    }
    return _client!;
  }

  /// 创建GraphQL客户端
  static GraphQLClient _createClient() {
    // 创建自定义HTTP客户端，增加超时时间
    final httpClient = http.Client();

    final HttpLink httpLink = HttpLink(
      endpoint,
      defaultHeaders: {'Content-Type': 'application/json'},
      httpClient: httpClient,
    );

    Link link = httpLink;

    // 如果有token，添加认证头
    if (_token != null) {
      debugPrint('🔗 添加认证头，token: ${_token?.substring(0, 10)}...');
      final AuthLink authLink = AuthLink(
        getToken: () async => 'Bearer $_token',
      );
      link = authLink.concat(httpLink);
    } else {
      debugPrint('🔗 无token，创建基础客户端');
    }

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  /// 设置认证token
  static Future<void> setToken(String? token) async {
    _token = token;
    // 重新创建客户端以应用新的token
    _client = _createClient();

    // 保存token到本地存储
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
      debugPrint('🔐 Token已保存到本地存储');
    } else {
      await prefs.remove('auth_token');
      debugPrint('🔐 Token已从本地存储移除');
    }
  }

  /// 从本地存储加载token
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _client = _createClient();
      debugPrint('🔐 从本地存储加载token成功');
    } else {
      debugPrint('🔐 本地存储中无token');
    }
  }

  /// 获取当前token
  static String? get token => _token;

  /// 检查是否已登录
  static bool get isLoggedIn => _token != null;

  /// 检查是否有token
  static bool get hasToken => _token != null;

  /// 清除认证信息
  static Future<void> clearAuth() async {
    await setToken(null);
    debugPrint('🔐 认证信息已清除');
  }

  /// 测试GraphQL连接
  static Future<bool> testConnection() async {
    try {
      debugPrint('🔗 测试GraphQL连接到: $endpoint');

      // 使用简单的introspection查询测试连接
      const testQuery = '''
        query TestConnection {
          __schema {
            queryType {
              name
            }
          }
        }
      ''';

      final QueryOptions options = QueryOptions(
        document: gql(testQuery),
        fetchPolicy: FetchPolicy.noCache,
      );

      final QueryResult result = await client
          .query(options)
          .timeout(const Duration(seconds: 15));

      if (result.hasException) {
        debugPrint('❌ GraphQL连接测试失败: ${result.exception}');
        return false;
      }

      debugPrint('✅ GraphQL连接测试成功');
      return true;
    } catch (e) {
      debugPrint('❌ GraphQL连接测试异常: $e');
      return false;
    }
  }

  /// 执行GraphQL查询的通用方法
  static Future<QueryResult> executeQuery(
    String query, {
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    Duration? timeout,
  }) async {
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy ?? FetchPolicy.networkOnly,
      errorPolicy: ErrorPolicy.all,
    );

    final Duration queryTimeout = timeout ?? const Duration(seconds: 30);
    return await client.query(options).timeout(queryTimeout);
  }

  /// 执行GraphQL变更的通用方法
  static Future<QueryResult> executeMutation(
    String mutation, {
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    Duration? timeout,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy ?? FetchPolicy.noCache,
      errorPolicy: ErrorPolicy.all,
    );

    final Duration mutationTimeout = timeout ?? const Duration(seconds: 30);
    return await client.mutate(options).timeout(mutationTimeout);
  }
}
