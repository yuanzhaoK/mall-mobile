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

  // GraphQL查询语句 - 根据实际schema修正
  static const String _homeDataQuery = '''
    query AppHomeData {
      appHomeData {
        banners {
          id
          title
          image_url
          link_url
          type
          sort_order
        }
        featured_products {
          id 
          name 
          price 
          original_price 
          image_url 
          rating 
          sales_count
        }
        trending_items {
          id
          name
          image_url
          score
          type
        }
        recommendations {
          id
          name
          type
          position
          products {
            id
            name
            price
            original_price
            image_url
            rating
            sales_count
          }
        }
        advertisements {
          id
          title
          image_url
          link_url
          position
          type
        }
        categories {
          id
          name
          icon_url 
          product_count
        }
      }
    }
  ''';

  // 用户资料查询
  static const String _profileQuery = '''
    query AppProfile {
      appProfile {
        id
        identity
        email
        avatar
        member_level
        points
        balance
        coupons_count
      }
    }
  ''';

  // 购物车数量查询
  static const String _cartCountQuery = '''
    query AppCartCount {
      appCart {
        total_items
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
          identity
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
  static Future<HomeData?> getHomeData() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(_homeDataQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      if (result.data != null && result.data!['appHomeData'] != null) {
        return HomeData.fromJson(result.data!['appHomeData']);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching home data: $e');
      return null;
    }
  }

  // 获取用户资料
  static Future<User?> getUserProfile() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(_profileQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      if (result.data != null && result.data!['appProfile'] != null) {
        return User.fromJson(result.data!['appProfile']);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // 获取购物车数量
  static Future<CartCount?> getCartCount() async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(_cartCountQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        debugPrint('GraphQL Error: ${result.exception.toString()}');
        return null;
      }

      if (result.data != null && result.data!['appCart'] != null) {
        return CartCount.fromJson(result.data!['appCart']);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching cart count: $e');
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
          }
        }
        if (result.exception?.linkException != null) {
          debugPrint('   Link Exception: ${result.exception!.linkException}');
        }
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['mobileLogin'] != null) {
        debugPrint('🔐 登录成功！');
        final authResponse = AuthResponse.fromJson(result.data!['mobileLogin']);
        // 保存token
        await setToken(authResponse.token);
        return authResponse;
      }

      debugPrint('🔐 登录失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🔐 登录异常: $e');
      rethrow;
    }
  }

  // 用户注销
  static Future<bool> logout() async {
    try {
      debugPrint('🔐 用户注销...');

      final MutationOptions options = MutationOptions(
        document: gql(_logoutMutation),
        fetchPolicy: FetchPolicy.noCache,
      );

      final QueryResult result = await client
          .mutate(options)
          .timeout(const Duration(seconds: 10));

      // 清除本地token
      await setToken(null);

      if (result.hasException) {
        debugPrint('🔐 注销时出现错误，但仍清除本地token: ${result.exception}');
      } else {
        debugPrint('🔐 注销成功');
      }

      return true;
    } catch (e) {
      debugPrint('🔐 注销异常: $e');
      // 即使API调用失败，也要清除本地token
      await setToken(null);
      return true;
    }
  }

  // 检查是否已登录
  static bool get isLoggedIn => _token != null;

  // 检查是否有token
  static bool get hasToken => _token != null;

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
