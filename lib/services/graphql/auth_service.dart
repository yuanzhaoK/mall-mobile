import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/services/graphql/graphql_client.dart';
import 'package:flutter_home_mall/services/graphql/mutations.dart';
import 'package:flutter_home_mall/services/graphql/queries.dart';

/// 认证服务 - 处理用户登录、注册、注销等认证相关操作
class AuthService {
  /// 用户登录
  static Future<AuthResponse?> login(String identity, String password) async {
    try {
      debugPrint('🔐 尝试登录...');
      debugPrint('   Identity: $identity');
      debugPrint('   Password length: ${password.length}');

      final loginInput = {'identity': identity, 'password': password};

      debugPrint('🔐 Login input: $loginInput');

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.login,
        variables: {'input': loginInput},
        timeout: const Duration(seconds: 30),
      );

      debugPrint('🔐 GraphQL响应状态:');
      debugPrint('   Has exception: ${result.hasException}');
      debugPrint('   Loading: ${result.isLoading}');
      debugPrint('   Data: ${result.data}');

      if (result.hasException) {
        debugPrint('🔐 Login Error Details:');
        debugPrint('   Exception: ${result.exception.toString()}');
        if (result.exception?.graphqlErrors != null) {
          for (final error in result.exception!.graphqlErrors) {
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
        await GraphQLClientManager.setToken(authResponse.token);
        return authResponse;
      }

      debugPrint('🔐 登录失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🔐 登录异常: $e');
      rethrow;
    }
  }

  /// 用户注册
  static Future<AuthResponse?> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
    String? nickname,
  }) async {
    try {
      debugPrint('🔐 尝试注册...');
      debugPrint('   Email: $email');

      final registerInput = {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        if (phone != null) 'phone': phone,
        if (nickname != null) 'nickname': nickname,
      };

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.register,
        variables: {'input': registerInput},
        timeout: const Duration(seconds: 30),
      );

      if (result.hasException) {
        debugPrint('🔐 注册失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['register'] != null) {
        debugPrint('🔐 注册成功！');
        final authResponse = AuthResponse.fromJson(result.data!['register']);
        // 保存token
        await GraphQLClientManager.setToken(authResponse.token);
        return authResponse;
      }

      debugPrint('🔐 注册失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🔐 注册异常: $e');
      rethrow;
    }
  }

  /// 用户注销
  static Future<bool> logout() async {
    try {
      debugPrint('🔐 用户注销...');

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.logout,
        timeout: const Duration(seconds: 10),
      );

      // 清除本地token
      await GraphQLClientManager.clearAuth();

      if (result.hasException) {
        debugPrint('🔐 注销时出现错误，但仍清除本地token: ${result.exception}');
      } else {
        debugPrint('🔐 注销成功');
      }

      return true;
    } catch (e) {
      debugPrint('🔐 注销异常: $e');
      // 即使API调用失败，也要清除本地token
      await GraphQLClientManager.clearAuth();
      return true;
    }
  }

  /// 获取用户资料
  static Future<User?> getUserProfile() async {
    try {
      debugPrint('🔐 获取用户资料...');

      final result = await GraphQLClientManager.executeQuery(
        GraphQLQueries.userProfile,
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🔐 获取用户资料失败: ${result.exception}');
        return null;
      }

      if (result.data != null && result.data!['appProfile'] != null) {
        debugPrint('🔐 获取用户资料成功');
        return User.fromJson(result.data!['appProfile']);
      }

      debugPrint('🔐 获取用户资料失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🔐 获取用户资料异常: $e');
      return null;
    }
  }

  /// 更新用户资料
  static Future<User?> updateProfile({
    String? nickname,
    String? avatar,
    String? phone,
    String? email,
  }) async {
    try {
      debugPrint('🔐 更新用户资料...');

      final updateInput = <String, dynamic>{};
      if (nickname != null) updateInput['nickname'] = nickname;
      if (avatar != null) updateInput['avatar'] = avatar;
      if (phone != null) updateInput['phone'] = phone;
      if (email != null) updateInput['email'] = email;

      if (updateInput.isEmpty) {
        debugPrint('🔐 没有需要更新的字段');
        return null;
      }

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.updateProfile,
        variables: {'input': updateInput},
        timeout: const Duration(seconds: 20),
      );

      if (result.hasException) {
        debugPrint('🔐 更新用户资料失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['updateProfile'] != null) {
        debugPrint('🔐 更新用户资料成功');
        return User.fromJson(result.data!['updateProfile']);
      }

      debugPrint('🔐 更新用户资料失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🔐 更新用户资料异常: $e');
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
      debugPrint('🔐 修改密码...');

      final changePasswordInput = {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.changePassword,
        variables: {'input': changePasswordInput},
        timeout: const Duration(seconds: 20),
      );

      if (result.hasException) {
        debugPrint('🔐 修改密码失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['changePassword'] != null) {
        final success = result.data!['changePassword']['success'] as bool;
        debugPrint('🔐 修改密码${success ? '成功' : '失败'}');
        return success;
      }

      debugPrint('🔐 修改密码失败：未收到预期的响应数据');
      return false;
    } catch (e) {
      debugPrint('🔐 修改密码异常: $e');
      rethrow;
    }
  }

  /// 发送验证码
  static Future<bool> sendVerificationCode({
    required String target, // 手机号或邮箱
    required String type, // sms 或 email
    required String purpose, // register, reset_password, change_phone 等
  }) async {
    try {
      debugPrint('🔐 发送验证码...');
      debugPrint('   Target: $target');
      debugPrint('   Type: $type');
      debugPrint('   Purpose: $purpose');

      final sendCodeInput = {
        'target': target,
        'type': type,
        'purpose': purpose,
      };

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.sendVerificationCode,
        variables: {'input': sendCodeInput},
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🔐 发送验证码失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['sendVerificationCode'] != null) {
        final success = result.data!['sendVerificationCode']['success'] as bool;
        debugPrint('🔐 发送验证码${success ? '成功' : '失败'}');
        return success;
      }

      debugPrint('🔐 发送验证码失败：未收到预期的响应数据');
      return false;
    } catch (e) {
      debugPrint('🔐 发送验证码异常: $e');
      rethrow;
    }
  }

  /// 验证验证码
  static Future<String?> verifyCode({
    required String target,
    required String code,
    required String purpose,
  }) async {
    try {
      debugPrint('🔐 验证验证码...');

      final verifyCodeInput = {
        'target': target,
        'code': code,
        'purpose': purpose,
      };

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.verifyCode,
        variables: {'input': verifyCodeInput},
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🔐 验证验证码失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['verifyCode'] != null) {
        final success = result.data!['verifyCode']['success'] as bool;
        final token = result.data!['verifyCode']['token'] as String?;
        debugPrint('🔐 验证验证码${success ? '成功' : '失败'}');
        return success ? token : null;
      }

      debugPrint('🔐 验证验证码失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🔐 验证验证码异常: $e');
      rethrow;
    }
  }

  /// 重置密码
  static Future<bool> resetPassword({
    required String target, // 手机号或邮箱
    required String code, // 验证码
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      debugPrint('🔐 重置密码...');

      final resetPasswordInput = {
        'target': target,
        'code': code,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.resetPassword,
        variables: {'input': resetPasswordInput},
        timeout: const Duration(seconds: 20),
      );

      if (result.hasException) {
        debugPrint('🔐 重置密码失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['resetPassword'] != null) {
        final success = result.data!['resetPassword']['success'] as bool;
        debugPrint('🔐 重置密码${success ? '成功' : '失败'}');
        return success;
      }

      debugPrint('🔐 重置密码失败：未收到预期的响应数据');
      return false;
    } catch (e) {
      debugPrint('🔐 重置密码异常: $e');
      rethrow;
    }
  }

  /// 检查是否已登录
  static bool get isLoggedIn => GraphQLClientManager.isLoggedIn;

  /// 检查是否有token
  static bool get hasToken => GraphQLClientManager.hasToken;

  /// 获取当前token
  static String? get token => GraphQLClientManager.token;

  /// 初始化认证服务（从本地存储加载token）
  static Future<void> initialize() async {
    await GraphQLClientManager.loadToken();
    debugPrint('�� 认证服务初始化完成');
  }
}
