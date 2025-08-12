// 用户相关数据模型

// 用户模型

class User {
  User({
    required this.id,
    required this.email,
    required this.username,
    this.avatar,
    this.realName,
    this.nickname,
    this.phone,
    this.gender,
    this.role,
    this.status,
    this.balance,
    this.points,
    this.level,
    this.record,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      role: json['role'],
      status: json['status'],
      // 如果有record字段，从record中提取详细信息
      realName: json['record']?['real_name'] ?? json['real_name'],
      nickname: json['record']?['nickname'] ?? json['nickname'],
      phone: json['record']?['phone'] ?? json['phone'],
      gender: json['record']?['gender'] ?? json['gender'],
      balance: (json['record']?['balance'] ?? 0.0).toDouble(),
      points: json['record']?['points'] ?? 0,
      record: json['record'] != null
          ? UserRecord.fromJson(json['record'])
          : null,
    );
  }

  final String id;
  final String email;
  final String username;
  final String? avatar;
  final String? realName;
  final String? nickname;
  final String? phone;
  final String? gender;
  final String? role;
  final String? status;
  final double? balance;
  final int? points;
  final String? level;
  final UserRecord? record;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar': avatar,
      'real_name': realName,
      'nickname': nickname,
      'phone': phone,
      'gender': gender,
      'role': role,
      'status': status,
      'balance': balance,
      'points': points,
    };
  }
}

// 用户详细记录模型（从API返回的record字段）
class UserRecord {
  UserRecord({
    required this.id,
    this.realName,
    this.nickname,
    this.phone,
    this.gender,
    this.balance,
    this.points,
    this.frozenBalance,
    this.frozenPoints,
    this.totalEarnedPoints,
    this.totalSpentPoints,
    this.isVerified,
    this.location,
    this.preferences,
    this.stats,
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) {
    return UserRecord(
      id: json['id'] ?? '',
      realName: json['real_name'],
      nickname: json['nickname'],
      phone: json['phone'],
      gender: json['gender'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      points: json['points'] ?? 0,
      frozenBalance: (json['frozen_balance'] ?? 0.0).toDouble(),
      frozenPoints: json['frozen_points'] ?? 0,
      totalEarnedPoints: json['total_earned_points'] ?? 0,
      totalSpentPoints: json['total_spent_points'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      location: json['location'] != null
          ? UserLocation.fromJson(json['location'])
          : null,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
    );
  }

  final String id;
  final String? realName;
  final String? nickname;
  final String? phone;
  final String? gender;
  final double? balance;
  final int? points;
  final double? frozenBalance;
  final int? frozenPoints;
  final int? totalEarnedPoints;
  final int? totalSpentPoints;
  final bool? isVerified;
  final UserLocation? location;
  final UserPreferences? preferences;
  final UserStats? stats;
}

// 用户位置信息
class UserLocation {
  UserLocation({this.city, this.province, this.district, this.postalCode});

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      city: json['city'],
      province: json['province'],
      district: json['district'],
      postalCode: json['postalCode'],
    );
  }

  final String? city;
  final String? province;
  final String? district;
  final String? postalCode;
}

// 用户偏好设置
class UserPreferences {
  UserPreferences({this.currency, this.language, this.timezone});

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      currency: json['currency'],
      language: json['language'],
      timezone: json['timezone'],
    );
  }

  final String? currency;
  final String? language;
  final String? timezone;
}

// 用户统计信息
class UserStats {
  UserStats({
    this.totalOrders,
    this.totalAmount,
    this.averageOrderValue,
    this.totalSavings,
    this.loyaltyScore,
    this.engagementScore,
    this.membershipDuration,
    this.lastOrderDate,
    this.favoriteCategories,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalOrders: json['totalOrders'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0.0).toDouble(),
      totalSavings: (json['totalSavings'] ?? 0.0).toDouble(),
      loyaltyScore: json['loyaltyScore'] ?? 0,
      engagementScore: json['engagementScore'] ?? 0,
      membershipDuration: json['membershipDuration'] ?? 0,
      lastOrderDate: json['lastOrderDate'],
      favoriteCategories: json['favoriteCategories'] != null
          ? List<String>.from(json['favoriteCategories'])
          : [],
    );
  }

  final int? totalOrders;
  final double? totalAmount;
  final double? averageOrderValue;
  final double? totalSavings;
  final int? loyaltyScore;
  final int? engagementScore;
  final int? membershipDuration;
  final String? lastOrderDate;
  final List<String>? favoriteCategories;
}

// 会员等级模型
class MemberLevel {
  MemberLevel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.level,
    this.description,
    this.color,
    this.backgroundColor,
    this.discountRate,
    this.pointsRate,
    this.pointsRequired,
    this.slogan,
    this.benefits,
  });

  factory MemberLevel.fromJson(Map<String, dynamic> json) {
    return MemberLevel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      level: json['level'] ?? 1,
      description: json['description'],
      color: json['color'],
      backgroundColor: json['background_color'],
      discountRate: (json['discount_rate'] ?? 1.0).toDouble(),
      pointsRate: (json['points_rate'] ?? 1.0).toDouble(),
      pointsRequired: json['points_required'] ?? 0,
      slogan: json['slogan'],
      benefits: json['benefits'] != null
          ? MemberBenefits.fromJson(json['benefits'])
          : null,
    );
  }

  final String id;
  final String name;
  final String displayName;
  final int level;
  final String? description;
  final String? color;
  final String? backgroundColor;
  final double? discountRate;
  final double? pointsRate;
  final int? pointsRequired;
  final String? slogan;
  final MemberBenefits? benefits;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'level': level,
      'description': description,
      'color': color,
      'background_color': backgroundColor,
      'discount_rate': discountRate,
      'points_rate': pointsRate,
      'points_required': pointsRequired,
      'slogan': slogan,
      'benefits': benefits?.toJson(),
    };
  }
}

// 会员权益模型
class MemberBenefits {
  MemberBenefits({this.discounts, this.privileges, this.services});

  factory MemberBenefits.fromJson(Map<String, dynamic> json) {
    return MemberBenefits(
      discounts: json['discounts'] != null
          ? List<String>.from(json['discounts'])
          : [],
      privileges: json['privileges'] != null
          ? List<String>.from(json['privileges'])
          : [],
      services: json['services'] != null
          ? List<String>.from(json['services'])
          : [],
    );
  }

  final List<String>? discounts;
  final List<String>? privileges;
  final List<String>? services;

  Map<String, dynamic> toJson() {
    return {
      'discounts': discounts,
      'privileges': privileges,
      'services': services,
    };
  }
}

// 认证响应模型
class AuthResponse {
  AuthResponse({
    required this.success,
    required this.token,
    required this.user,
    required this.refreshToken,
    required this.expiresIn,
    this.memberLevel,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? true,
      token: json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      memberLevel: json['memberLevel'] != null
          ? MemberLevel.fromJson(json['memberLevel'])
          : null,
    );
  }

  final bool success;
  final String token;
  final User user;
  final String refreshToken;
  final int expiresIn;
  final MemberLevel? memberLevel;
}

// 登录输入模型
class LoginInput {
  LoginInput({required this.identity, required this.password});
  final String identity;
  final String password;

  Map<String, dynamic> toJson() {
    return {'identity': identity, 'password': password};
  }
}
