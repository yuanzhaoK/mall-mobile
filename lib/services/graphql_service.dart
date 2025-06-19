import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';

class GraphQLService {
  // 使用确认可用的GraphQL端点
  static String get _endpoint {
    // 直接使用确认可用的端点
    const endpoint = 'http://10.241.25.183:8082/graphql';
    debugPrint('🔗 GraphQL使用端点: $endpoint');
    return endpoint;
  }

  static GraphQLClient? _client;
  static String? _token;

  static GraphQLClient get client {
    if (_client == null) {
      _client = _createClient();
      debugPrint('🔗 GraphQL客户端已配置，端点: $_endpoint');
    }
    return _client!;
  }

  static GraphQLClient _createClient() {
    // 创建自定义HTTP客户端，增加超时时间
    final httpClient = http.Client();

    final HttpLink httpLink = HttpLink(
      _endpoint,
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

  // 设置认证token
  static Future<void> setToken(String? token) async {
    _token = token;
    // 重新创建客户端以应用新的token
    _client = _createClient();

    // 保存token到本地存储
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  // 从本地存储获取token
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _client = _createClient();
    }
  }

  // 获取当前token
  static String? get token => _token;

  // GraphQL查询语句
  static const String _homeDataQuery = '''
    query {
      appHomeData {
        featured_products { id name price }
        categories { id name, created, description }
      }
    }
  ''';

  // 登录mutation - 更新为兼容的版本
  static const String _loginMutation = '''
    mutation mobileLogin(\$input: LoginInput!) {
      mobileLogin(input: \$input) {
        token
        record {
          id
          email
          name
          avatar
        }
      }
    }
  ''';

  // 注销mutation
  static const String _logoutMutation = '''
    mutation Logout {
      logout
    }
  ''';

  // 获取首页数据
  static Future<AppHomeData?> getHomeData() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(_homeDataQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        // 在生产环境中，应该使用适当的日志系统替代print
        debugPrint('GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      if (result.data != null && result.data!['appHomeData'] != null) {
        return AppHomeData.fromJson(result.data!['appHomeData']);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      return null;
    }
  }

  // 用户登录
  static Future<AuthResponse?> login(String identity, String password) async {
    try {
      debugPrint('🔐 尝试登录...');
      debugPrint('   Identity: $identity');
      debugPrint('   Password length: ${password.length}');

      final loginInput = {'identity': identity, 'password': password};
      debugPrint('🔐 Login input: $loginInput');

      final MutationOptions options = MutationOptions(
        document: gql(_loginMutation),
        variables: {'input': loginInput},
        fetchPolicy: FetchPolicy.noCache,
        errorPolicy: ErrorPolicy.all,
      );

      debugPrint('🔐 发送GraphQL mutation...');
      debugPrint('   Mutation: $_loginMutation');
      debugPrint('   Variables: ${options.variables}');

      // 添加超时控制
      final QueryResult result = await client
          .mutate(options)
          .timeout(const Duration(seconds: 30)); // 增加到30秒超时

      debugPrint('🔐 GraphQL响应状态:');
      debugPrint('   Has exception: ${result.hasException}');
      debugPrint('   Loading: ${result.isLoading}');
      debugPrint('   Data: ${result.data}');

      if (result.hasException) {
        debugPrint('🔐 Login Error Details:');
        debugPrint('   Exception: ${result.exception.toString()}');
        if (result.exception?.graphqlErrors != null) {
          for (var error in result.exception!.graphqlErrors) {
            debugPrint('   GraphQL Error: ${error.message}');
            debugPrint('   Extensions: ${error.extensions}');
            debugPrint('   Path: ${error.path}');
            debugPrint('   Locations: ${error.locations}');
          }
        }
        if (result.exception?.linkException != null) {
          debugPrint('   Link Exception: ${result.exception!.linkException}');
        }
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['mobileLogin'] != null) {
        debugPrint('🔐 登录成功！');
        debugPrint('   Response data: ${result.data!['mobileLogin']}');
        final authResponse = AuthResponse.fromJson(result.data!['mobileLogin']);
        // 保存token
        await setToken(authResponse.token);
        return authResponse;
      }

      debugPrint('🔐 登录失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🔐 Error during login: $e');
      rethrow;
    }
  }

  // 用户注销
  static Future<bool> logout() async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(_logoutMutation),
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        debugPrint('Logout Error: ${result.exception.toString()}');
        // 即使服务器端注销失败，也要清除本地token
      }

      // 清除本地token
      await setToken(null);

      return result.data?['logout'] ?? true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      // 即使出错也要清除本地token
      await setToken(null);
      return false;
    }
  }

  // 检查是否已登录
  static bool get isLoggedIn => _token != null;

  // 获取当前用户信息（如果需要的话，可以添加获取当前用户信息的查询）
  static Future<User?> getCurrentUser() async {
    if (!isLoggedIn) return null;

    // 这里可以添加获取当前用户信息的GraphQL查询
    // 暂时返回null，实际应用中需要实现
    return null;
  }

  // 测试GraphQL连接
  static Future<bool> testConnection() async {
    try {
      debugPrint('🔗 测试GraphQL连接到: $_endpoint');

      // 使用简单的introspection查询测试连接
      const testQuery = '''
        query {
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
}
