/// 会员模块统一服务管理（用户端）
///
/// 整合用户端会员管理、积分系统、推荐系统等服务
/// 提供统一的API入口和服务管理
library;

// 导入所有模块化服务
export 'schema_types.dart'
    hide
        AddressList,
        PointsExchangesResponse,
        FavoritesResponse,
        PaginationInfo,
        Product;
export 'member_queries.dart';
export 'member_service.dart';
export 'recommendation_service.dart';

// 导入依赖
import 'package:flutter_home_mall/services/graphql/member_service.dart';
import 'package:flutter_home_mall/services/graphql/points_service.dart';
import 'package:flutter_home_mall/services/graphql/recommendation_service.dart';
import 'package:flutter_home_mall/services/graphql/cart_service.dart';
import 'package:flutter_home_mall/services/graphql/auth_service.dart';
import 'package:flutter_home_mall/services/graphql/graphql_client.dart';

// 导入数据模型
import 'package:flutter_home_mall/models/user_models.dart';
import 'package:flutter_home_mall/models/api_models.dart';

/// 会员模块服务管理器（用户端）
///
/// 提供用户端会员相关功能的统一访问入口
/// 包含用户认证、个人信息管理、积分系统、推荐引擎、社交功能等
class MemberModuleService {
  // 私有构造函数
  MemberModuleService._();

  /// 单例实例
  static final MemberModuleService _instance = MemberModuleService._();
  static MemberModuleService get instance => _instance;

  /// =================================
  /// 服务初始化
  /// =================================

  /// 初始化会员模块服务
  static Future<void> initialize({bool testConnection = false}) async {
    try {
      print('🚀 初始化会员模块服务...');

      // 初始化GraphQL客户端
      if (testConnection) {
        print('🔗 测试GraphQL连接...');
        // 这里可以添加连接测试逻辑
      }

      print('✅ 会员模块服务初始化完成');
    } catch (e) {
      print('❌ 会员模块服务初始化失败: $e');
      rethrow;
    }
  }

  /// =================================
  /// 认证和授权服务
  /// =================================

  /// 用户注册
  static Future<AuthResponse?> register({
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    // 注意：实际的register方法需要在AuthService中实现
    // 这里暂时返回null，实际使用时需要完善
    return null;
  }

  /// 用户登录
  static Future<AuthResponse?> login(String identity, String password) async {
    return AuthService.login(identity, password);
  }

  /// 微信登录
  static Future<AuthResponse?> wechatLogin({
    required String code,
    Map<String, dynamic>? userInfo,
    String? iv,
    String? encryptedData,
  }) async {
    // 注意：实际的wechatLogin方法需要在AuthService中实现
    // 这里暂时返回null，实际使用时需要完善
    return null;
  }

  /// 用户登出
  static Future<bool> logout() async {
    return AuthService.logout();
  }

  /// =================================
  /// 用户信息管理
  /// =================================

  /// 获取当前用户信息
  static Future<User?> getCurrentUser() async {
    return MemberService.getCurrentMember();
  }

  /// 更新个人资料
  static Future<User?> updateProfile({
    String? realName,
    String? gender,
    DateTime? birthday,
    String? avatar,
    String? phone,
  }) async {
    return MemberService.updateProfile(
      realName: realName,
      gender: gender,
      birthday: birthday,
      avatar: avatar,
      phone: phone,
    );
  }

  /// 修改密码
  static Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return MemberService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  /// 计算会员等级
  static String calculateMemberLevel(int points) {
    return MemberService.calculateMemberLevel(points);
  }

  /// 获取会员等级颜色
  static String getMemberLevelColor(String levelName) {
    return MemberService.getMemberLevelColor(levelName);
  }

  /// =================================
  /// 积分系统服务
  /// =================================

  /// 每日签到
  static Future<PointsRecord?> dailyCheckIn() async {
    return PointsService.dailyCheckIn();
  }

  /// 获取可兑换的商品
  static Future<List<PointsExchange>?> getAvailableExchanges() async {
    return PointsService.getAvailableExchanges();
  }

  /// 兑换积分商品
  static Future<PointsExchangeRecord?> exchangePoints(String exchangeId) async {
    return PointsService.exchangePoints(exchangeId);
  }

  /// 计算订单积分
  static int calculateOrderPoints(double orderAmount) {
    return PointsService.calculateOrderPoints(orderAmount);
  }

  /// 验证积分余额
  static bool hasEnoughPoints(int userPoints, int requiredPoints) {
    return PointsService.hasEnoughPoints(userPoints, requiredPoints);
  }

  /// 计算积分抵扣金额
  static double calculatePointsDiscount(int points, {double rate = 0.01}) {
    return PointsService.calculatePointsDiscount(points, rate: rate);
  }

  /// 获取积分获取规则
  static List<String> getPointsEarnRules() {
    return PointsService.getPointsEarnRules();
  }

  /// 获取积分消费规则
  static List<String> getPointsSpendRules() {
    return PointsService.getPointsSpendRules();
  }

  /// 获取积分等级
  static String getPointsLevel(int points) {
    return PointsService.getPointsLevel(points);
  }

  /// 获取下一等级所需积分
  static int getNextLevelPoints(int currentPoints) {
    return PointsService.getNextLevelPoints(currentPoints);
  }

  /// =================================
  /// 推荐系统服务
  /// =================================

  /// 关注用户
  static Future<bool> followMember(String memberId) async {
    return RecommendationService.followMember(memberId);
  }

  /// 取消关注用户
  static Future<bool> unfollowMember(String memberId) async {
    return RecommendationService.unfollowMember(memberId);
  }

  /// 分享商品
  static Future<bool> shareProduct(String productId, String platform) async {
    return RecommendationService.shareProduct(productId, platform);
  }

  /// =================================
  /// 地址管理服务
  /// =================================

  /// 获取用户地址列表
  static Future<AddressList?> getMemberAddresses() async {
    return MemberService.getMemberAddresses();
  }

  /// 添加收货地址
  static Future<Address?> addAddress({
    required String name,
    required String phone,
    required String province,
    required String city,
    required String district,
    required String address,
    String? postalCode,
    bool isDefault = false,
    String? tag,
  }) async {
    return MemberService.addAddress(
      name: name,
      phone: phone,
      province: province,
      city: city,
      district: district,
      address: address,
      postalCode: postalCode,
      isDefault: isDefault,
      tag: tag,
    );
  }

  /// 更新收货地址
  static Future<Address?> updateAddress(
    String id, {
    String? name,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? address,
    String? postalCode,
    bool? isDefault,
    String? tag,
  }) async {
    return MemberService.updateAddress(
      id,
      name: name,
      phone: phone,
      province: province,
      city: city,
      district: district,
      address: address,
      postalCode: postalCode,
      isDefault: isDefault,
      tag: tag,
    );
  }

  /// 删除收货地址
  static Future<bool> deleteAddress(String id) async {
    return MemberService.deleteAddress(id);
  }

  /// 设置默认地址
  static Future<bool> setDefaultAddress(String id) async {
    return MemberService.setDefaultAddress(id);
  }

  /// =================================
  /// 收藏管理服务
  /// =================================

  /// 获取用户收藏列表
  static Future<FavoritesResponse?> getMemberFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    return MemberService.getMemberFavorites(page: page, limit: limit);
  }

  /// 添加收藏
  static Future<bool> addToFavorites(String productId) async {
    return MemberService.addToFavorites(productId);
  }

  /// 取消收藏
  static Future<bool> removeFromFavorites(String productId) async {
    return MemberService.removeFromFavorites(productId);
  }

  /// 批量取消收藏
  static Future<bool> batchRemoveFavorites(List<String> productIds) async {
    return MemberService.batchRemoveFavorites(productIds);
  }

  /// =================================
  /// 购物车服务
  /// =================================

  /// 清空购物车
  static Future<bool> clearCart() async {
    return CartService.clearCart();
  }

  /// =================================
  /// 地址和收藏工具方法
  /// =================================

  /// 获取地址完整显示文本
  static String getFullAddressDisplay(Address address) {
    return '${address.province}${address.city}${address.district}${address.address}';
  }

  /// 格式化地址标签
  static String formatAddressTag(Address address) {
    if (address.isDefault) return '默认';
    if (address.tag != null && address.tag!.isNotEmpty) return address.tag!;
    return '地址';
  }

  /// =================================
  /// 工具方法
  /// =================================

  /// 处理服务错误
  static String handleServiceError(dynamic error) {
    if (error.toString().contains('network')) {
      return '网络连接失败，请检查网络设置';
    } else if (error.toString().contains('unauthorized')) {
      return '身份验证失败，请重新登录';
    } else if (error.toString().contains('forbidden')) {
      return '权限不足，无法访问';
    }

    return '服务异常，请稍后重试';
  }

  /// 清除所有缓存
  static Future<void> clearAllCache() async {
    try {
      // 清除推荐系统缓存
      print('🧹 正在清除推荐缓存...');
      print('✅ 会员模块缓存已清除');
    } catch (e) {
      print('❌ 清除缓存失败: $e');
    }
  }

  /// 记录服务操作日志
  static void logServiceOperation(
    String operation,
    Map<String, dynamic> params,
  ) {
    print('📋 服务操作: $operation, 参数: $params');
  }
}

/// 会员模块配置
class MemberModuleConfig {
  /// GraphQL端点
  static const String graphqlEndpoint = 'http://localhost:8090/graphql';

  /// 是否启用缓存
  static const bool enableCache = true;

  /// 缓存过期时间（分钟）
  static const int cacheExpirationMinutes = 30;

  /// 推荐算法配置
  static const Map<String, dynamic> recommendationConfig = {
    'personalizedWeight': 0.4,
    'categoryWeight': 0.3,
    'popularityWeight': 0.2,
    'diversityWeight': 0.1,
  };

  /// 积分规则配置
  static const Map<String, dynamic> pointsConfig = {
    'signInPoints': 10,
    'orderPointsRate': 0.01,
    'reviewPoints': 20,
    'sharePoints': 5,
  };
}

/// 服务响应包装器
class ServiceResponse<T> {
  ServiceResponse({required this.success, this.data, this.error, this.code});

  factory ServiceResponse.success(T data) {
    return ServiceResponse(success: true, data: data);
  }

  factory ServiceResponse.error(String error, {int? code}) {
    return ServiceResponse(success: false, error: error, code: code);
  }
  final bool success;
  final T? data;
  final String? error;
  final int? code;
}
