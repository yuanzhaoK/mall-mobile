import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户凭据存储服务 - 处理记住密码功能
class CredentialsStorage {
  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _rememberKey = 'remember_credentials';

  /// 保存用户凭据
  static Future<void> saveCredentials({
    required String username,
    required String password,
    required bool remember,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (remember) {
        await prefs.setString(_usernameKey, username);
        await prefs.setString(_passwordKey, password);
        await prefs.setBool(_rememberKey, true);
        debugPrint('🔐 用户凭据已保存');
      } else {
        // 如果不记住，则清除保存的凭据
        await clearCredentials();
      }
    } catch (e) {
      debugPrint('🔐 保存凭据失败: $e');
    }
  }

  /// 加载保存的用户凭据
  static Future<SavedCredentials?> loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final remember = prefs.getBool(_rememberKey) ?? false;
      if (!remember) {
        return null;
      }

      final username = prefs.getString(_usernameKey);
      final password = prefs.getString(_passwordKey);

      if (username != null && password != null) {
        debugPrint('🔐 已加载保存的用户凭据');
        return SavedCredentials(
          username: username,
          password: password,
          remember: true,
        );
      }
    } catch (e) {
      debugPrint('🔐 加载凭据失败: $e');
    }

    return null;
  }

  /// 检查是否记住凭据
  static Future<bool> isRememberEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberKey) ?? false;
    } catch (e) {
      debugPrint('🔐 检查记住状态失败: $e');
      return false;
    }
  }

  /// 清除保存的凭据
  static Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usernameKey);
      await prefs.remove(_passwordKey);
      await prefs.remove(_rememberKey);
      debugPrint('🔐 已清除保存的凭据');
    } catch (e) {
      debugPrint('🔐 清除凭据失败: $e');
    }
  }

  /// 更新记住状态（不改变用户名密码）
  static Future<void> updateRememberStatus({required bool remember}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (remember) {
        await prefs.setBool(_rememberKey, true);
      } else {
        // 如果取消记住，清除所有凭据
        await clearCredentials();
      }
    } catch (e) {
      debugPrint('🔐 更新记住状态失败: $e');
    }
  }
}

/// 保存的用户凭据数据模型
class SavedCredentials {
  SavedCredentials({
    required this.username,
    required this.password,
    required this.remember,
  });
  final String username;
  final String password;
  final bool remember;

  @override
  String toString() {
    return 'SavedCredentials(username: $username, password: [HIDDEN], remember: $remember)';
  }
}
