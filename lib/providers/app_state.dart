import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/services/graphql_service.dart';

/// 应用全局状态管理
class AppState extends ChangeNotifier {
  // 用户状态
  User? _user;
  bool _isLoggedIn = false;
  bool _isInitializing = false;

  // 错误状态
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  bool get hasError => _error != null;

  /// 初始化应用
  Future<void> initialize() async {
    if (_isInitializing) return;

    _isInitializing = true;
    _error = null;
    notifyListeners();

    try {
      // 检查是否有保存的用户登录状态
      await _checkLoginStatus();
    } catch (e) {
      _error = '初始化失败: $e';
      debugPrint('AppState初始化错误: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    try {
      // 如果有保存的token，尝试获取用户信息
      if (GraphQLService.hasToken) {
        final userProfile = await GraphQLService.getUserProfile();
        if (userProfile != null) {
          _user = userProfile;
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      // 登录状态检查失败，清除token
      await GraphQLService.logout();
      _user = null;
      _isLoggedIn = false;
      debugPrint('登录状态检查失败: $e');
    }
  }

  /// 用户登录
  Future<bool> login(String username, String password) async {
    _error = null;
    notifyListeners();

    try {
      final authResponse = await GraphQLService.login(username, password);
      if (authResponse != null) {
        // 登录成功，获取用户信息
        final userProfile = await GraphQLService.getUserProfile();
        if (userProfile != null) {
          _user = userProfile;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }

      _error = '登录失败，请检查用户名和密码';
      notifyListeners();
      return false;
    } catch (e) {
      _error = '登录错误: $e';
      notifyListeners();
      return false;
    }
  }

  /// 用户注销
  Future<void> logout() async {
    try {
      await GraphQLService.logout();
    } catch (e) {
      debugPrint('注销错误: $e');
    } finally {
      _user = null;
      _isLoggedIn = false;
      _error = null;
      notifyListeners();
    }
  }

  /// 更新用户信息
  Future<void> updateUserProfile() async {
    if (!_isLoggedIn) return;

    try {
      final userProfile = await GraphQLService.getUserProfile();
      if (userProfile != null) {
        _user = userProfile;
        notifyListeners();
      }
    } catch (e) {
      _error = '更新用户信息失败: $e';
      notifyListeners();
    }
  }

  /// 直接更新用户信息（用于本地更新）
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 设置错误
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// 显示成功消息（可以用于全局状态管理）
  void showSuccess(String message) {
    // 这里可以实现全局成功消息显示
    debugPrint('成功: $message');
  }
}
