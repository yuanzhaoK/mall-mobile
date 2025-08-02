import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/services/graphql/graphql_client.dart';
import 'package:flutter_home_mall/services/graphql/member_queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// 积分系统GraphQL服务（用户端）
///
/// 提供用户端积分相关功能
/// 包含积分兑换、签到等功能
class PointsService {
  static GraphQLClient get _client => GraphQLClientManager.client;

  /// =================================
  /// 积分兑换功能
  /// =================================

  /// 获取积分兑换商品列表
  static Future<PointsExchangesResponse?> getPointsExchanges({
    String? exchangeType,
    String? status,
    Map<String, int>? pointsRange,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(MemberGraphQLQueries.pointsExchanges),
        variables: {
          'input': {
            'exchange_type': exchangeType,
            'status': status,
            'points_range': pointsRange != null
                ? {'min': pointsRange['min'], 'max': pointsRange['max']}
                : null,
            'pagination': {'page': page, 'limit': limit},
          },
        },
      );

      final result = await _client.query(options);

      if (result.hasException) {
        debugPrint('❌ 获取积分兑换商品失败: ${result.exception}');
        return null;
      }

      if (result.data?['pointsExchanges'] != null) {
        return PointsExchangesResponse.fromJson(
          result.data!['pointsExchanges'],
        );
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取积分兑换商品异常: $e');
      return null;
    }
  }

  /// 获取可兑换的商品
  static Future<List<PointsExchange>?> getAvailableExchanges() async {
    final response = await getPointsExchanges(status: 'ACTIVE', limit: 100);
    return response?.exchanges;
  }

  /// 兑换积分商品
  static Future<PointsExchangeRecord?> exchangePoints(String exchangeId) async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.exchangePoints),
        variables: {'exchange_id': exchangeId},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 积分兑换失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data?['exchangePoints'] != null) {
        return PointsExchangeRecord.fromJson(result.data!['exchangePoints']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ 积分兑换异常: $e');
      rethrow;
    }
  }

  /// =================================
  /// 积分操作功能
  /// =================================

  /// 每日签到获取积分
  static Future<PointsRecord?> dailyCheckIn() async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.dailyCheckIn),
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 每日签到失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data?['dailyCheckIn'] != null) {
        return PointsRecord.fromJson(result.data!['dailyCheckIn']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ 每日签到异常: $e');
      rethrow;
    }
  }

  /// =================================
  /// 积分计算和验证
  /// =================================

  /// 计算订单可获得的积分
  static int calculateOrderPoints(double orderAmount) {
    // 默认规则：消费1元 = 1积分
    return (orderAmount * 1).round();
  }

  /// 验证积分是否足够
  static bool hasEnoughPoints(int userPoints, int requiredPoints) {
    return userPoints >= requiredPoints;
  }

  /// 计算积分抵扣金额
  static double calculatePointsDiscount(int points, {double rate = 0.01}) {
    // 默认规则：100积分 = 1元
    return points * rate;
  }

  /// =================================
  /// 积分业务规则
  /// =================================

  /// 获取积分获取规则说明
  static List<String> getPointsEarnRules() {
    return [
      '注册奖励：100积分',
      '完善资料：50积分',
      '首次购买：200积分',
      '每日签到：5-20积分',
      '订单完成：消费金额1%',
      '评价商品：10-50积分',
      '分享商品：5积分',
      '邀请好友：500积分',
    ];
  }

  /// 获取积分消费规则说明
  static List<String> getPointsSpendRules() {
    return ['积分抵现：100积分=1元', '积分商城兑换商品', '参与抽奖活动', '购买会员特权', '积分有效期：获得后1年内有效'];
  }

  /// 获取用户积分等级
  static String getPointsLevel(int points) {
    if (points >= 50000) return '钻石会员';
    if (points >= 20000) return '铂金会员';
    if (points >= 5000) return '黄金会员';
    if (points >= 1000) return '白银会员';
    return '青铜会员';
  }

  /// 获取下一等级所需积分
  static int getNextLevelPoints(int currentPoints) {
    if (currentPoints < 1000) return 1000 - currentPoints;
    if (currentPoints < 5000) return 5000 - currentPoints;
    if (currentPoints < 20000) return 20000 - currentPoints;
    if (currentPoints < 50000) return 50000 - currentPoints;
    return 0; // 已达到最高等级
  }

  /// =================================
  /// 积分活动功能
  /// =================================

  /// 检查是否可以签到
  static Future<bool> canCheckInToday() async {
    try {
      // 实际实现中应该调用后端API检查
      // 这里简化处理，实际项目中需要根据后端接口返回值判断
      return true;
    } catch (e) {
      debugPrint('❌ 检查签到状态异常: $e');
      return false;
    }
  }

  /// 获取连续签到天数
  static Future<int> getConsecutiveCheckInDays() async {
    try {
      // 实际实现中应该调用后端API获取
      // 这里简化处理，返回模拟数据
      return 0;
    } catch (e) {
      debugPrint('❌ 获取连续签到天数异常: $e');
      return 0;
    }
  }

  /// 获取签到奖励预览
  static Map<int, int> getCheckInRewards() {
    return {
      1: 5, // 第1天：5积分
      2: 10, // 第2天：10积分
      3: 15, // 第3天：15积分
      7: 50, // 第7天：50积分
      15: 100, // 第15天：100积分
      30: 200, // 第30天：200积分
    };
  }

  /// =================================
  /// 错误处理和日志
  /// =================================

  /// 处理积分操作错误
  static String handlePointsError(dynamic error) {
    final errorMessage = error.toString();

    if (errorMessage.contains('insufficient_points')) {
      return '积分余额不足';
    } else if (errorMessage.contains('invalid_exchange')) {
      return '兑换商品无效或已下架';
    } else if (errorMessage.contains('daily_limit_exceeded')) {
      return '今日积分获取已达上限';
    } else if (errorMessage.contains('already_checked_in')) {
      return '今日已签到';
    } else if (errorMessage.contains('exchange_out_of_stock')) {
      return '兑换商品库存不足';
    }

    return '操作失败，请稍后重试';
  }

  /// 记录积分操作日志
  static void logPointsOperation(
    String operation,
    Map<String, dynamic> params,
  ) {
    debugPrint('🎯 积分操作: $operation, 参数: $params');
  }
}

/// =================================
/// 用户端积分数据模型
/// =================================

/// 积分记录
class PointsRecord {
  PointsRecord({
    required this.id,
    required this.userId,
    required this.username,
    required this.type,
    required this.points,
    required this.balance,
    required this.reason,
    this.orderId,
    this.relatedId,
    this.expireTime,
    required this.created,
  });

  factory PointsRecord.fromJson(Map<String, dynamic> json) {
    return PointsRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      type: json['type'] ?? '',
      points: json['points'] ?? 0,
      balance: json['balance'] ?? 0,
      reason: json['reason'] ?? '',
      orderId: json['order_id'],
      relatedId: json['related_id'],
      expireTime: json['expire_time'] != null
          ? DateTime.parse(json['expire_time'])
          : null,
      created: DateTime.parse(
        json['created'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
  final String id;
  final String userId;
  final String username;
  final String type;
  final int points;
  final int balance;
  final String reason;
  final String? orderId;
  final String? relatedId;
  final DateTime? expireTime;
  final DateTime created;
}

/// 积分兑换商品响应
class PointsExchangesResponse {
  PointsExchangesResponse({
    required this.exchanges,
    required this.pagination,
    required this.total,
  });

  factory PointsExchangesResponse.fromJson(Map<String, dynamic> json) {
    return PointsExchangesResponse(
      exchanges: (json['exchanges'] as List)
          .map((item) => PointsExchange.fromJson(item))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
      total: json['total'] ?? 0,
    );
  }
  final List<PointsExchange> exchanges;
  final PaginationInfo pagination;
  final int total;
}

/// 积分兑换商品
class PointsExchange {
  PointsExchange({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.pointsRequired,
    required this.exchangeType,
    this.rewardValue,
    this.stock,
    required this.status,
    required this.sortOrder,
  });

  factory PointsExchange.fromJson(Map<String, dynamic> json) {
    return PointsExchange(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      pointsRequired: json['points_required'] ?? 0,
      exchangeType: json['exchange_type'] ?? '',
      rewardValue: json['reward_value']?.toDouble(),
      stock: json['stock'],
      status: json['status'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int pointsRequired;
  final String exchangeType;
  final double? rewardValue;
  final int? stock;
  final String status;
  final int sortOrder;
}

/// 积分兑换记录
class PointsExchangeRecord {
  PointsExchangeRecord({
    required this.id,
    required this.userId,
    required this.username,
    required this.exchange,
    required this.pointsCost,
    required this.rewardType,
    this.rewardValue,
    required this.status,
    required this.created,
    this.processedTime,
  });

  factory PointsExchangeRecord.fromJson(Map<String, dynamic> json) {
    return PointsExchangeRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      exchange: PointsExchange.fromJson(json['exchange'] ?? {}),
      pointsCost: json['points_cost'] ?? 0,
      rewardType: json['reward_type'] ?? '',
      rewardValue: json['reward_value']?.toDouble(),
      status: json['status'] ?? '',
      created: DateTime.parse(
        json['created'] ?? DateTime.now().toIso8601String(),
      ),
      processedTime: json['processed_time'] != null
          ? DateTime.parse(json['processed_time'])
          : null,
    );
  }
  final String id;
  final String userId;
  final String username;
  final PointsExchange exchange;
  final int pointsCost;
  final String rewardType;
  final double? rewardValue;
  final String status;
  final DateTime created;
  final DateTime? processedTime;
}

/// 分页信息
class PaginationInfo {
  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
    required this.perPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      hasMore: json['has_more'] ?? false,
      perPage: json['per_page'] ?? 20,
    );
  }
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  final int perPage;
}
