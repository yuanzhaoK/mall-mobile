import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/models/user_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户数据持久化存储服务
/// 负责保存和恢复用户信息、会员等级等数据
class UserStorage {
  static const String _userKey = 'logged_in_user';
  static const String _memberLevelKey = 'member_level';
  static const String _loginStateKey = 'is_logged_in';

  /// 保存用户登录状态和数据
  static Future<void> saveUserData({
    required User user,
    MemberLevel? memberLevel,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 保存登录状态
      await prefs.setBool(_loginStateKey, true);

      // 保存用户信息
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      debugPrint('🔐 用户信息已保存: ${user.username}');

      // 保存会员等级信息
      if (memberLevel != null) {
        final memberLevelJson = jsonEncode(memberLevel.toJson());
        await prefs.setString(_memberLevelKey, memberLevelJson);
        debugPrint('🔐 会员等级已保存: ${memberLevel.displayName}');
        debugPrint('🔐 会员等级JSON: $memberLevelJson');
      } else {
        await prefs.remove(_memberLevelKey);
        debugPrint('🔐 会员等级为null，已清除保存的数据');
      }
    } catch (e) {
      debugPrint('🔐 保存用户数据失败: $e');
    }
  }

  /// 获取保存的用户数据
  static Future<UserData?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 检查登录状态
      final isLoggedIn = prefs.getBool(_loginStateKey) ?? false;
      if (!isLoggedIn) {
        debugPrint('🔐 用户未登录');
        return null;
      }

      // 获取用户信息
      final userJson = prefs.getString(_userKey);
      if (userJson == null) {
        debugPrint('🔐 未找到保存的用户信息');
        return null;
      }

      final user = User.fromJson(jsonDecode(userJson));
      debugPrint('🔐 已恢复用户信息: ${user.username}');

      // 获取会员等级信息
      MemberLevel? memberLevel;
      final memberLevelJson = prefs.getString(_memberLevelKey);
      debugPrint('🔐 会员等级原始JSON: $memberLevelJson');
      if (memberLevelJson != null) {
        try {
          memberLevel = MemberLevel.fromJson(jsonDecode(memberLevelJson));
          debugPrint('🔐 已恢复会员等级: ${memberLevel.displayName}');
          debugPrint(
            '🔐 会员等级详情: level=${memberLevel.level}, color=${memberLevel.color}',
          );
        } catch (e) {
          debugPrint('🔐 解析会员等级失败: $e');
        }
      } else {
        debugPrint('🔐 未找到保存的会员等级信息');
      }

      return UserData(user: user, memberLevel: memberLevel);
    } catch (e) {
      debugPrint('🔐 获取用户数据失败: $e');
      return null;
    }
  }

  /// 检查是否有已登录的用户
  static Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_loginStateKey) ?? false;
    } catch (e) {
      debugPrint('🔐 检查登录状态失败: $e');
      return false;
    }
  }

  /// 清除所有用户数据
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loginStateKey);
      await prefs.remove(_userKey);
      await prefs.remove(_memberLevelKey);
      debugPrint('🔐 用户数据已清除');
    } catch (e) {
      debugPrint('🔐 清除用户数据失败: $e');
    }
  }

  /// 更新用户信息（保持登录状态）
  static Future<void> updateUserInfo(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      debugPrint('🔐 用户信息已更新: ${user.username}');
    } catch (e) {
      debugPrint('🔐 更新用户信息失败: $e');
    }
  }

  /// 更新会员等级信息
  static Future<void> updateMemberLevel(MemberLevel? memberLevel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (memberLevel != null) {
        await prefs.setString(
          _memberLevelKey,
          jsonEncode(memberLevel.toJson()),
        );
        debugPrint('🔐 会员等级已更新: ${memberLevel.displayName}');
      } else {
        await prefs.remove(_memberLevelKey);
        debugPrint('🔐 会员等级已清除');
      }
    } catch (e) {
      debugPrint('🔐 更新会员等级失败: $e');
    }
  }
}

/// 用户数据包装类
class UserData {
  UserData({required this.user, this.memberLevel});

  final User user;
  final MemberLevel? memberLevel;

  @override
  String toString() {
    return 'UserData(user: ${user.username}, memberLevel: ${memberLevel?.displayName})';
  }
}
