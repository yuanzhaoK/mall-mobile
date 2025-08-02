/// 应用异常处理系统
///
/// 统一管理应用中的所有异常类型，提供清晰的错误分类和处理机制
library;

import 'package:flutter/foundation.dart';

/// 应用异常基类
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    required this.code,
    this.details,
    this.stackTrace,
  });

  /// 错误消息
  final String message;

  /// 错误代码
  final String code;

  /// 错误详情
  final String? details;

  /// 堆栈跟踪
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'AppException($code): $message${details != null ? ' - $details' : ''}';
}

/// 网络异常
class NetworkException extends AppException {
  /// 创建网络异常
  factory NetworkException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return NetworkException(
          message: message ?? '请求参数错误',
          code: 'NETWORK_BAD_REQUEST',
          statusCode: statusCode,
        );
      case 401:
        return NetworkException(
          message: message ?? '未授权，请登录',
          code: 'NETWORK_UNAUTHORIZED',
          statusCode: statusCode,
        );
      case 403:
        return NetworkException(
          message: message ?? '访问被拒绝',
          code: 'NETWORK_FORBIDDEN',
          statusCode: statusCode,
        );
      case 404:
        return NetworkException(
          message: message ?? '请求的资源不存在',
          code: 'NETWORK_NOT_FOUND',
          statusCode: statusCode,
        );
      case 500:
        return NetworkException(
          message: message ?? '服务器内部错误',
          code: 'NETWORK_INTERNAL_SERVER_ERROR',
          statusCode: statusCode,
        );
      default:
        return NetworkException(
          message: message ?? '网络请求失败',
          code: 'NETWORK_UNKNOWN_ERROR',
          statusCode: statusCode,
        );
    }
  }
  const NetworkException({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
    this.statusCode,
  });

  /// HTTP状态码
  final int? statusCode;

  /// 连接超时
  static const NetworkException connectionTimeout = NetworkException(
    message: '连接超时，请检查网络连接',
    code: 'NETWORK_CONNECTION_TIMEOUT',
  );

  /// 请求超时
  static const NetworkException requestTimeout = NetworkException(
    message: '请求超时，请稍后重试',
    code: 'NETWORK_REQUEST_TIMEOUT',
  );

  /// 无网络连接
  static const NetworkException noConnection = NetworkException(
    message: '无网络连接，请检查网络设置',
    code: 'NETWORK_NO_CONNECTION',
  );

  /// 服务器错误
  static const NetworkException serverError = NetworkException(
    message: '服务器错误，请稍后重试',
    code: 'NETWORK_SERVER_ERROR',
    statusCode: 500,
  );
}

/// 认证异常
class AuthException extends AppException {
  const AuthException({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// 未登录
  static const AuthException notLoggedIn = AuthException(
    message: '用户未登录',
    code: 'AUTH_NOT_LOGGED_IN',
  );

  /// 登录失效
  static const AuthException tokenExpired = AuthException(
    message: '登录已过期，请重新登录',
    code: 'AUTH_TOKEN_EXPIRED',
  );

  /// 权限不足
  static const AuthException insufficientPermissions = AuthException(
    message: '权限不足',
    code: 'AUTH_INSUFFICIENT_PERMISSIONS',
  );

  /// 登录失败
  static const AuthException loginFailed = AuthException(
    message: '用户名或密码错误',
    code: 'AUTH_LOGIN_FAILED',
  );
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
    this.field,
  });

  /// 验证失败的字段
  final String? field;

  /// 必填字段为空
  static ValidationException requiredField(String field) => ValidationException(
    message: '$field不能为空',
    code: 'VALIDATION_REQUIRED_FIELD',
    field: field,
  );

  /// 格式无效
  static ValidationException invalidFormat(
    String field, [
    String? expectedFormat,
  ]) => ValidationException(
    message:
        '$field格式不正确${expectedFormat != null ? '，期望格式：$expectedFormat' : ''}',
    code: 'VALIDATION_INVALID_FORMAT',
    field: field,
  );

  /// 长度不符合要求
  static ValidationException invalidLength(
    String field,
    int minLength, [
    int? maxLength,
  ]) => ValidationException(
    message: '$field长度应为$minLength${maxLength != null ? '-$maxLength' : '以上'}位',
    code: 'VALIDATION_INVALID_LENGTH',
    field: field,
  );
}

/// 业务逻辑异常
class BusinessException extends AppException {
  const BusinessException({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// 库存不足
  static const BusinessException insufficientStock = BusinessException(
    message: '商品库存不足',
    code: 'BUSINESS_INSUFFICIENT_STOCK',
  );

  /// 订单不存在
  static const BusinessException orderNotFound = BusinessException(
    message: '订单不存在',
    code: 'BUSINESS_ORDER_NOT_FOUND',
  );

  /// 商品已下架
  static const BusinessException productUnavailable = BusinessException(
    message: '商品已下架',
    code: 'BUSINESS_PRODUCT_UNAVAILABLE',
  );

  /// 优惠券已过期
  static const BusinessException couponExpired = BusinessException(
    message: '优惠券已过期',
    code: 'BUSINESS_COUPON_EXPIRED',
  );
}

/// 存储异常
class StorageException extends AppException {
  const StorageException({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// 读取失败
  static const StorageException readFailed = StorageException(
    message: '数据读取失败',
    code: 'STORAGE_READ_FAILED',
  );

  /// 写入失败
  static const StorageException writeFailed = StorageException(
    message: '数据保存失败',
    code: 'STORAGE_WRITE_FAILED',
  );

  /// 数据不存在
  static const StorageException dataNotFound = StorageException(
    message: '数据不存在',
    code: 'STORAGE_DATA_NOT_FOUND',
  );
}

/// 系统异常
class SystemException extends AppException {
  const SystemException({
    required super.message,
    required super.code,
    super.details,
    super.stackTrace,
  });

  /// 初始化失败
  static const SystemException initializationFailed = SystemException(
    message: '应用初始化失败',
    code: 'SYSTEM_INITIALIZATION_FAILED',
  );

  /// 权限被拒绝
  static const SystemException permissionDenied = SystemException(
    message: '权限被拒绝',
    code: 'SYSTEM_PERMISSION_DENIED',
  );

  /// 功能不可用
  static const SystemException featureUnavailable = SystemException(
    message: '功能暂时不可用',
    code: 'SYSTEM_FEATURE_UNAVAILABLE',
  );
}

/// 异常处理工具类
class ExceptionHandler {
  ExceptionHandler._();

  /// 处理异常并返回用户友好的错误消息
  static String handleException(dynamic exception) {
    if (exception is AppException) {
      return exception.message;
    }

    // 处理常见的Dart异常
    if (exception is FormatException) {
      return '数据格式错误';
    }

    if (exception is TypeError) {
      return '数据类型错误';
    }

    if (exception is ArgumentError) {
      return '参数错误';
    }

    if (exception is StateError) {
      return '状态错误';
    }

    // 开发模式下显示详细错误，生产模式下显示通用错误
    if (kDebugMode) {
      return exception.toString();
    } else {
      return '未知错误，请稍后重试';
    }
  }

  /// 记录异常
  static void logException(dynamic exception, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('🚨 Exception: $exception');
      if (stackTrace != null) {
        debugPrint('📍 Stack trace: $stackTrace');
      }
    }

    // 在生产环境中，这里可以集成Firebase Crashlytics等崩溃报告服务
    // FirebaseCrashlytics.instance.recordError(exception, stackTrace);
  }

  /// 是否为网络相关异常
  static bool isNetworkException(dynamic exception) {
    return exception is NetworkException;
  }

  /// 是否为认证相关异常
  static bool isAuthException(dynamic exception) {
    return exception is AuthException;
  }

  /// 是否为验证相关异常
  static bool isValidationException(dynamic exception) {
    return exception is ValidationException;
  }
}
