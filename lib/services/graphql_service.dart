// 导入模块化的GraphQL服务
import 'package:flutter_home_mall/services/graphql/graphql_service.dart'
    as modular;
import 'package:flutter_home_mall/models/api_models.dart';

/// GraphQL服务主入口
///
/// 这个类现在作为新模块化GraphQL服务的统一入口
/// 推荐直接使用模块化服务：
/// - AuthService: 认证相关
/// - HomeService: 首页数据
/// - CartService: 购物车操作
class GraphQLService {
  // 私有构造函数
  GraphQLService._();

  /// 初始化GraphQL服务
  static Future<void> initialize({bool testConnection = false}) async {
    return modular.GraphQLService.initialize(testConnection: testConnection);
  }

  /// 用户登录
  static Future<AuthResponse?> login(String identity, String password) async {
    return modular.AuthService.login(identity, password);
  }

  /// 用户注销
  static Future<bool> logout() async {
    return modular.AuthService.logout();
  }

  /// 获取首页数据
  static Future<HomeData?> getHomeData() async {
    return modular.HomeService.getHomeData();
  }

  /// 获取用户资料
  static Future<User?> getUserProfile() async {
    return modular.AuthService.getUserProfile();
  }

  /// 获取购物车数量
  static Future<CartCount?> getCartCount() async {
    return modular.CartService.getCartCount();
  }

  /// 设置认证token
  static Future<void> setToken(String? token) async {
    return modular.GraphQLClientManager.setToken(token);
  }

  /// 从本地存储加载token
  static Future<void> loadToken() async {
    return modular.GraphQLClientManager.loadToken();
  }

  /// 获取当前token
  static String? get token => modular.GraphQLClientManager.token;

  /// 检查是否已登录
  static bool get isLoggedIn => modular.GraphQLClientManager.isLoggedIn;

  /// 检查是否有token
  static bool get hasToken => modular.GraphQLClientManager.hasToken;

  /// 获取当前用户信息
  static Future<User?> getCurrentUser() async {
    return modular.AuthService.getUserProfile();
  }

  /// 测试GraphQL连接
  static Future<bool> testConnection() async {
    return modular.GraphQLClientManager.testConnection();
  }

  /// 清除认证信息
  static Future<void> clearAuth() async {
    return modular.GraphQLClientManager.clearAuth();
  }

  // 模块化服务访问器
  /// 认证服务
  static Type get auth => modular.AuthService;

  /// 首页服务
  static Type get home => modular.HomeService;

  /// 购物车服务
  static Type get cart => modular.CartService;
}
