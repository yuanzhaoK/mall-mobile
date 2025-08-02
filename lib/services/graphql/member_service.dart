import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/models/user_models.dart';
import 'package:flutter_home_mall/services/graphql/graphql_client.dart';
import 'package:flutter_home_mall/services/graphql/member_queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

///
/// 提供用户端会员相关功能
/// 包含用户信息管理、地址管理、收藏管理等
class MemberService {
  static GraphQLClient get _client => GraphQLClientManager.client;

  /// =================================
  /// 用户信息管理
  /// =================================

  /// 获取当前登录用户信息
  static Future<User?> getCurrentMember() async {
    try {
      final options = QueryOptions(
        document: gql(MemberGraphQLQueries.appMember),
      );

      final result = await _client.query(options);

      if (result.hasException) {
        debugPrint('❌ 获取当前用户信息失败: ${result.exception}');
        return null;
      }

      if (result.data?['appMember'] != null) {
        return User.fromJson(result.data!['appMember']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取当前用户信息异常: $e');
      return null;
    }
  }

  /// 更新个人资料
  static Future<User?> updateProfile({
    String? realName,
    String? gender,
    DateTime? birthday,
    String? avatar,
    String? phone,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.updateProfile),
        variables: {
          'input': {
            'real_name': realName,
            'gender': gender,
            'birthday': birthday?.toIso8601String(),
            'avatar': avatar,
            'phone': phone,
          },
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 更新个人资料失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data?['updateProfile'] != null) {
        return User.fromJson(result.data!['updateProfile']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ 更新个人资料异常: $e');
      rethrow;
    }
  }

  /// 修改密码
  static Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.changePassword),
        variables: {
          'input': {
            'old_password': oldPassword,
            'new_password': newPassword,
            'confirm_password': confirmPassword,
          },
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 修改密码失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['changePassword'] == true;
    } catch (e) {
      debugPrint('❌ 修改密码异常: $e');
      rethrow;
    }
  }

  /// =================================
  /// 地址管理功能
  /// =================================

  /// 获取用户地址列表
  static Future<AddressList?> getMemberAddresses() async {
    try {
      final options = QueryOptions(
        document: gql(MemberGraphQLQueries.appMemberAddresses),
      );

      final result = await _client.query(options);

      if (result.hasException) {
        debugPrint('❌ 获取地址列表失败: ${result.exception}');
        return null;
      }

      if (result.data?['appMemberAddresses'] != null) {
        return AddressList.fromJson(result.data!['appMemberAddresses']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取地址列表异常: $e');
      return null;
    }
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
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.addAddress),
        variables: {
          'input': {
            'name': name,
            'phone': phone,
            'province': province,
            'city': city,
            'district': district,
            'address': address,
            'postal_code': postalCode,
            'is_default': isDefault,
            'tag': tag,
          },
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 添加地址失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data?['addAddress'] != null) {
        return Address.fromJson(result.data!['addAddress']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ 添加地址异常: $e');
      rethrow;
    }
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
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.updateAddress),
        variables: {
          'id': id,
          'input': {
            'name': name,
            'phone': phone,
            'province': province,
            'city': city,
            'district': district,
            'address': address,
            'postal_code': postalCode,
            'is_default': isDefault,
            'tag': tag,
          },
        },
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 更新地址失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data?['updateAddress'] != null) {
        return Address.fromJson(result.data!['updateAddress']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ 更新地址异常: $e');
      rethrow;
    }
  }

  /// 删除收货地址
  static Future<bool> deleteAddress(String id) async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.deleteAddress),
        variables: {'id': id},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 删除地址失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['deleteAddress'] == true;
    } catch (e) {
      debugPrint('❌ 删除地址异常: $e');
      rethrow;
    }
  }

  /// 设置默认地址
  static Future<bool> setDefaultAddress(String id) async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.setDefaultAddress),
        variables: {'id': id},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 设置默认地址失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['setDefaultAddress'] == true;
    } catch (e) {
      debugPrint('❌ 设置默认地址异常: $e');
      rethrow;
    }
  }

  /// =================================
  /// 收藏管理功能
  /// =================================

  /// 获取用户收藏列表
  static Future<FavoritesResponse?> getMemberFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final options = QueryOptions(
        document: gql(MemberGraphQLQueries.memberFavorites),
        variables: {
          'input': {
            'pagination': {'page': page, 'limit': limit},
          },
        },
      );

      final result = await _client.query(options);

      if (result.hasException) {
        debugPrint('❌ 获取收藏列表失败: ${result.exception}');
        return null;
      }

      if (result.data?['memberFavorites'] != null) {
        return FavoritesResponse.fromJson(result.data!['memberFavorites']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取收藏列表异常: $e');
      return null;
    }
  }

  /// 添加收藏
  static Future<bool> addToFavorites(String productId) async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.addToFavorites),
        variables: {'product_id': productId},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 添加收藏失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['addToFavorites'] == true;
    } catch (e) {
      debugPrint('❌ 添加收藏异常: $e');
      rethrow;
    }
  }

  /// 取消收藏
  static Future<bool> removeFromFavorites(String productId) async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.removeFromFavorites),
        variables: {'product_id': productId},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 取消收藏失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['removeFromFavorites'] == true;
    } catch (e) {
      debugPrint('❌ 取消收藏异常: $e');
      rethrow;
    }
  }

  /// 批量取消收藏
  static Future<bool> batchRemoveFavorites(List<String> productIds) async {
    try {
      final options = MutationOptions(
        document: gql(MemberGraphQLMutations.batchRemoveFavorites),
        variables: {'product_ids': productIds},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        debugPrint('❌ 批量取消收藏失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result.data?['batchRemoveFavorites'] == true;
    } catch (e) {
      debugPrint('❌ 批量取消收藏异常: $e');
      rethrow;
    }
  }

  /// =================================
  /// 工具方法
  /// =================================

  /// 根据积分计算等级
  static String calculateMemberLevel(int points) {
    if (points >= 50000) return '钻石会员';
    if (points >= 20000) return '铂金会员';
    if (points >= 5000) return '黄金会员';
    if (points >= 1000) return '白银会员';
    return '青铜会员';
  }

  /// 计算会员折扣
  static double calculateDiscount(double originalPrice, double discountRate) {
    return originalPrice * discountRate;
  }

  /// 获取会员等级颜色
  static String getMemberLevelColor(String levelName) {
    switch (levelName) {
      case '钻石会员':
        return '#B9F2FF';
      case '铂金会员':
        return '#E5E5E5';
      case '黄金会员':
        return '#FFD700';
      case '白银会员':
        return '#C0C0C0';
      case '青铜会员':
      default:
        return '#CD7F32';
    }
  }

  /// 处理会员操作错误
  static String handleMemberError(dynamic error) {
    final errorMessage = error.toString();

    if (errorMessage.contains('username_exists')) {
      return '用户名已存在';
    } else if (errorMessage.contains('email_exists')) {
      return '邮箱已被注册';
    } else if (errorMessage.contains('phone_exists')) {
      return '手机号已被注册';
    } else if (errorMessage.contains('invalid_password')) {
      return '密码格式不正确';
    } else if (errorMessage.contains('member_not_found')) {
      return '会员不存在';
    } else if (errorMessage.contains('address_not_found')) {
      return '地址不存在';
    }

    return '操作失败，请稍后重试';
  }
}

/// =================================
/// 用户端数据模型
/// =================================

/// 地址列表
class AddressList {
  AddressList({
    required this.addresses,
    this.defaultAddress,
    required this.total,
  });

  factory AddressList.fromJson(Map<String, dynamic> json) {
    return AddressList(
      addresses: (json['addresses'] as List)
          .map((item) => Address.fromJson(item))
          .toList(),
      defaultAddress: json['default_address'] != null
          ? Address.fromJson(json['default_address'])
          : null,
      total: json['total'] ?? 0,
    );
  }
  final List<Address> addresses;
  final Address? defaultAddress;
  final int total;
}

/// 地址
class Address {
  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.address,
    this.postalCode,
    required this.isDefault,
    this.tag,
    required this.created,
    required this.updated,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      postalCode: json['postal_code'],
      isDefault: json['is_default'] ?? false,
      tag: json['tag'],
      created: DateTime.parse(
        json['created'] ?? DateTime.now().toIso8601String(),
      ),
      updated: DateTime.parse(
        json['updated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String address;
  final String? postalCode;
  final bool isDefault;
  final String? tag;
  final DateTime created;
  final DateTime updated;

  /// 获取完整地址
  String get fullAddress => '$province$city$district$address';

  /// 获取地址标签显示文本
  String get tagDisplay => tag ?? '默认';
}

/// 收藏列表响应
class FavoritesResponse {
  FavoritesResponse({
    required this.favorites,
    required this.pagination,
    required this.total,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      favorites: (json['favorites'] as List)
          .map((item) => Favorite.fromJson(item))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
      total: json['total'] ?? 0,
    );
  }
  final List<Favorite> favorites;
  final PaginationInfo pagination;
  final int total;
}

/// 收藏
class Favorite {
  Favorite({
    required this.id,
    required this.userId,
    required this.product,
    required this.created,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      created: DateTime.parse(
        json['created'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
  final String id;
  final String userId;
  final Product product;
  final DateTime created;
}

/// 商品信息
class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.rating,
    this.salesCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      imageUrl: json['image_url'] ?? '',
      rating: json['rating']?.toDouble(),
      salesCount: json['sales_count'],
    );
  }
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final double? rating;
  final int? salesCount;
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
