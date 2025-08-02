/// 应用日志系统
///
/// 提供统一的日志记录功能，支持不同日志级别和输出格式
library;

import 'package:flutter/foundation.dart';

import 'package:flutter_home_mall/config/app_config.dart';

/// 日志级别
enum LogLevel {
  verbose(0, 'VERBOSE', '🔍'),
  debug(1, 'DEBUG', '🐛'),
  info(2, 'INFO', 'ℹ️'),
  warning(3, 'WARNING', '⚠️'),
  error(4, 'ERROR', '❌'),
  fatal(5, 'FATAL', '💀');

  const LogLevel(this.priority, this.name, this.emoji);

  final int priority;
  final String name;
  final String emoji;
}

/// 应用日志记录器
class Logger {
  /// 创建带标签的日志记录器
  factory Logger.forTag(String tag) => Logger._(tag);

  /// 创建带类名的日志记录器
  factory Logger.forClass(Type type) => Logger._(type.toString());
  Logger._(this._tag);

  final String _tag;

  /// 当前最小日志级别
  static LogLevel _minLevel = LogLevel.debug;

  /// 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 记录详细日志
  void verbose(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.verbose, message, error, stackTrace);
  }

  /// 记录调试日志
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// 记录信息日志
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// 记录警告日志
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  /// 记录错误日志
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  /// 记录致命错误日志
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.fatal, message, error, stackTrace);
  }

  /// 内部日志记录方法
  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    // 检查是否需要记录此级别的日志
    if (!_shouldLog(level)) return;

    final now = DateTime.now();
    final timestamp = _formatTimestamp(now);
    final logMessage = _formatLogMessage(level, timestamp, message, error);

    // 输出日志
    _outputLog(level, logMessage);

    // 如果有堆栈跟踪，也记录下来
    if (stackTrace != null) {
      _outputLog(level, _formatStackTrace(stackTrace));
    }
  }

  /// 检查是否应该记录此级别的日志
  bool _shouldLog(LogLevel level) {
    // 如果禁用了日志记录，则不记录
    if (!AppConfig.config.enableLogging) return false;

    // 检查日志级别
    return level.priority >= _minLevel.priority;
  }

  /// 格式化时间戳
  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}.'
        '${dateTime.millisecond.toString().padLeft(3, '0')}';
  }

  /// 格式化日志消息
  String _formatLogMessage(
    LogLevel level,
    String timestamp,
    String message, [
    Object? error,
  ]) {
    final buffer = StringBuffer()
      // 添加emoji和级别
      ..write('${level.emoji} [$timestamp] ')
      // 添加标签
      ..write('[$_tag] ')
      // 添加消息
      ..write(message);

    // 添加错误信息
    if (error != null) {
      buffer.write(' | Error: $error');
    }

    return buffer.toString();
  }

  /// 格式化堆栈跟踪
  String _formatStackTrace(StackTrace stackTrace) {
    return '📍 Stack trace:\n$stackTrace';
  }

  /// 输出日志
  void _outputLog(LogLevel level, String message) {
    // 在调试模式下输出到控制台
    if (kDebugMode) {
      debugPrint(message);
    }

    // 在生产环境中，可以将日志发送到远程日志服务
    // 例如：Firebase Crashlytics、Sentry等
    if (AppConfig.environment.isProduction &&
        level.priority >= LogLevel.error.priority) {
      _sendToRemoteLoggingService(level, message);
    }
  }

  /// 发送到远程日志服务（示例）
  void _sendToRemoteLoggingService(LogLevel level, String message) {
    // 这里可以集成实际的远程日志服务
    // 例如：
    // FirebaseCrashlytics.instance.log(message);
    // Sentry.addBreadcrumb(Breadcrumb(message: message, level: level));
  }
}

/// 网络日志记录器
class NetworkLogger {
  static final Logger _logger = Logger.forTag('Network');

  /// 记录请求开始
  static void logRequest(
    String method,
    String url, [
    Map<String, dynamic>? headers,
  ]) {
    _logger.info('🌐 Request: $method $url', headers);
  }

  /// 记录请求成功
  static void logRequestSuccess(
    String method,
    String url,
    int statusCode,
    Duration duration,
  ) {
    _logger.info(
      '✅ Response: $method $url - $statusCode (${duration.inMilliseconds}ms)',
    );
  }

  /// 记录请求失败
  static void logRequestError(
    String method,
    String url,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    _logger.error('❌ Request Failed: $method $url', error, stackTrace);
  }

  /// 记录GraphQL查询
  static void logGraphQLQuery(String operationName, String query) {
    _logger.debug('🔍 GraphQL Query: $operationName\n$query');
  }

  /// 记录GraphQL变更
  static void logGraphQLMutation(String operationName, String mutation) {
    _logger.debug('✏️ GraphQL Mutation: $operationName\n$mutation');
  }
}

/// 性能日志记录器
class PerformanceLogger {
  static final Logger _logger = Logger.forTag('Performance');

  /// 记录页面加载时间
  static void logPageLoad(String pageName, Duration duration) {
    _logger.info('📱 Page Load: $pageName - ${duration.inMilliseconds}ms');
  }

  /// 记录API响应时间
  static void logApiResponse(String endpoint, Duration duration) {
    _logger.info('⚡ API Response: $endpoint - ${duration.inMilliseconds}ms');
  }

  /// 记录内存使用情况
  static void logMemoryUsage() {
    // 注意：这个功能在某些平台上可能不可用
    try {
      // 这里可以添加内存使用情况的检测
      _logger.info('🧠 Memory usage logged');
    } catch (e) {
      _logger.warning('Memory usage logging not available on this platform');
    }
  }
}

/// 用户行为日志记录器
class UserActionLogger {
  static final Logger _logger = Logger.forTag('UserAction');

  /// 记录用户点击事件
  static void logTap(String elementName, [Map<String, dynamic>? context]) {
    _logger.info('👆 User tapped: $elementName', context);
  }

  /// 记录页面访问
  static void logPageView(String pageName, [Map<String, dynamic>? parameters]) {
    _logger.info('👀 Page view: $pageName', parameters);
  }

  /// 记录搜索行为
  static void logSearch(String query, [int? resultCount]) {
    _logger.info(
      '🔍 Search: "$query"${resultCount != null ? ' ($resultCount results)' : ''}',
    );
  }

  /// 记录购买行为
  static void logPurchase(String productId, double amount, String currency) {
    _logger.info('💰 Purchase: $productId - $amount $currency');
  }

  /// 记录分享行为
  static void logShare(String content, String platform) {
    _logger.info('📤 Share: $content on $platform');
  }
}

/// 应用生命周期日志记录器
class AppLifecycleLogger {
  static final Logger _logger = Logger.forTag('AppLifecycle');

  /// 记录应用启动
  static void logAppStart() {
    _logger.info('🚀 App started');
  }

  /// 记录应用进入前台
  static void logAppResumed() {
    _logger.info('▶️ App resumed');
  }

  /// 记录应用进入后台
  static void logAppPaused() {
    _logger.info('⏸️ App paused');
  }

  /// 记录应用关闭
  static void logAppStopped() {
    _logger.info('⏹️ App stopped');
  }

  /// 记录应用崩溃
  static void logAppCrash(Object error, StackTrace stackTrace) {
    _logger.fatal('💥 App crashed', error, stackTrace);
  }
}
