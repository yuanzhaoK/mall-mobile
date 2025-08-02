// GraphQL服务模块化导出
// 统一的GraphQL服务入口文件

import 'package:flutter_home_mall/services/graphql/auth_service.dart';
import 'package:flutter_home_mall/services/graphql/cart_service.dart';
import 'package:flutter_home_mall/services/graphql/graphql_client.dart';
import 'package:flutter_home_mall/services/graphql/home_service.dart';

// 业务服务模块
export 'auth_service.dart';
export 'cart_service.dart';
// 核心客户端管理
export 'graphql_client.dart';
export 'home_service.dart';
export 'mutations.dart';
// 查询和变更语句
export 'queries.dart';

/// GraphQL服务统一管理类
///
/// 这个类提供了对所有GraphQL服务的统一访问入口
///
/// 使用示例:
/// ```dart
/// // 初始化服务
/// await GraphQLService.initialize();
///
/// // 用户登录
/// final authResponse = await GraphQLService.auth.login('user@example.com', 'password');
///
/// // 获取首页数据
/// final homeData = await GraphQLService.home.getHomeData();
///
/// // 添加到购物车
/// await GraphQLService.cart.addToCart(productId: 'product_123', quantity: 1);
/// ```
class GraphQLService {
  // 私有构造函数，防止外部实例化
  GraphQLService._();

  /// 认证服务
  static Type get auth => AuthService;

  /// 首页服务
  static Type get home => HomeService;

  /// 购物车服务
  static Type get cart => CartService;

  /// 初始化GraphQL服务
  ///
  /// 这个方法应该在应用启动时调用，用于：
  /// - 加载本地存储的认证token
  /// - 初始化GraphQL客户端
  /// - 测试网络连接（可选）
  static Future<void> initialize({bool testConnection = false}) async {
    try {
      // 加载认证信息
      await GraphQLClientManager.loadToken();

      // 可选：测试连接
      if (testConnection) {
        final isConnected = await GraphQLClientManager.testConnection();
        if (!isConnected) {
          throw Exception('GraphQL服务连接失败');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 检查服务是否已准备就绪
  static bool get isReady {
    try {
      // 检查客户端是否已初始化
      final client = GraphQLClientManager.client;
      // ignore: unnecessary_null_comparison
      return client != null;
    } catch (e) {
      return false;
    }
  }

  /// 获取当前认证状态
  static bool get isAuthenticated => GraphQLClientManager.isLoggedIn;

  /// 获取当前用户token
  static String? get currentToken => GraphQLClientManager.token;

  /// 测试GraphQL连接
  static Future<bool> testConnection() => GraphQLClientManager.testConnection();

  /// 清除所有认证信息
  static Future<void> clearAuth() => GraphQLClientManager.clearAuth();
}
