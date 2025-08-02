// 用户相关数据模型

// 用户模型
import 'dart:ffi';

class User {
  User({
    required this.id,
    required this.identity,
    required this.email,
    required this.username,
    this.avatar,
    this.realName,
    this.phone,
    this.address,
    this.nickname,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      identity: json['identity'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
    );
  }
  final String id;
  final String identity;
  final String username;
  final String? realName;
  final String? phone;
  final String? address;
  final String? nickname;
  final String? gender;
  final String email;
  final String? avatar;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identity': identity,
      'email': email,
      'username': username,
      'avatar': avatar,
    };
  }
}

// 认证响应模型
class AuthResponse {
  AuthResponse({
    required this.token,
    required this.user,
    required this.refreshToken,
    required this.expiresIn,
  });
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
    );
  }
  final String token;
  final User user;
  final String refreshToken;
  final Int expiresIn;
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
