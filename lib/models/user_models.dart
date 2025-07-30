// 用户相关数据模型

// 用户模型
class User {
  final String id;
  final String identity;
  final String username;
  final String? realName;
  final String? phone;
  final String? address;
  final String? nickname;
  final String? gender;
  final String email;
  final String? avatarUrl;
  final String memberLevel;
  final int points;
  final double balance;
  final int couponsCount;

  User({
    required this.id,
    required this.identity,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.realName,
    this.phone,
    this.address,
    this.nickname,
    this.gender,
    required this.memberLevel,
    required this.points,
    required this.balance,
    required this.couponsCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      identity: json['identity'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar'],
      memberLevel: json['member_level'] ?? 'NORMAL',
      points: json['points'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      couponsCount: json['coupons_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identity': identity,
      'email': email,
      'username': username,
      'avatar': avatarUrl,
      'member_level': memberLevel,
      'points': points,
      'balance': balance,
      'coupons_count': couponsCount,
    };
  }
}

// 认证响应模型
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['record'] ?? {}),
    );
  }
}

// 登录输入模型
class LoginInput {
  final String identity;
  final String password;

  LoginInput({required this.identity, required this.password});

  Map<String, dynamic> toJson() {
    return {'identity': identity, 'password': password};
  }
}
