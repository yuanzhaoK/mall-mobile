/// 应用配置中心
///
/// 此文件包含应用的所有配置信息，包括环境配置、API配置、功能开关等
/// 遵循Flutter最佳实践，便于不同环境的配置管理
library app_config;

import 'package:flutter/foundation.dart';

/// 应用配置类
class AppConfig {
  // 私有构造函数，防止外部实例化
  AppConfig._();

  // 单例实例
  static final AppConfig _instance = AppConfig._();
  static AppConfig get instance => _instance;

  /// 应用基本信息
  static const String appName = 'Flutter Mall';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String packageName = 'com.example.flutter_home_mall';

  /// 支持的语言
  static const List<String> supportedLanguages = ['zh', 'en'];
  static const String defaultLanguage = 'zh';

  /// 环境配置
  static const Environment environment = Environment.development;

  /// 根据环境获取配置
  static EnvironmentConfig get config {
    switch (environment) {
      case Environment.development:
        return _developmentConfig;
      case Environment.staging:
        return _stagingConfig;
      case Environment.production:
        return _productionConfig;
    }
  }

  /// 开发环境配置
  static const EnvironmentConfig _developmentConfig = EnvironmentConfig(
    environment: Environment.development,
    baseUrl: 'http://10.241.25.183:8082',
    graphqlEndpoint: 'http://10.241.25.183:8082/graphql',
    websocketEndpoint: 'ws://10.241.25.183:8082/graphql',
    timeout: Duration(seconds: 30),
    enableLogging: true,
    enableDebugMode: true,
    enablePerformanceOverlay: false,
  );

  /// 测试环境配置
  static const EnvironmentConfig _stagingConfig = EnvironmentConfig(
    environment: Environment.staging,
    baseUrl: 'https://staging-api.example.com',
    graphqlEndpoint: 'https://staging-api.example.com/graphql',
    websocketEndpoint: 'wss://staging-api.example.com/graphql',
    timeout: Duration(seconds: 30),
    enableLogging: true,
    enableDebugMode: false,
    enablePerformanceOverlay: false,
  );

  /// 生产环境配置
  static const EnvironmentConfig _productionConfig = EnvironmentConfig(
    environment: Environment.production,
    baseUrl: 'https://api.example.com',
    graphqlEndpoint: 'https://api.example.com/graphql',
    websocketEndpoint: 'wss://api.example.com/graphql',
    timeout: Duration(seconds: 15),
    enableLogging: false,
    enableDebugMode: false,
    enablePerformanceOverlay: false,
  );

  /// 功能开关配置
  static const FeatureFlags featureFlags = FeatureFlags(
    enableBiometricAuth: true,
    enablePushNotifications: true,
    enableAnalytics: true,
    enableCrashReporting: true,
    enableA11ySupport: true,
    enableDarkMode: true,
    enableOfflineMode: false,
    enableExperimentalFeatures: kDebugMode,
  );

  /// 缓存配置
  static const CacheConfig cacheConfig = CacheConfig(
    maxCacheSize: 100 * 1024 * 1024, // 100MB
    imageCacheSize: 50 * 1024 * 1024, // 50MB
    networkCacheSize: 10 * 1024 * 1024, // 10MB
    defaultCacheTimeout: Duration(hours: 24),
    imageCacheTimeout: Duration(days: 7),
  );

  /// 数据库配置
  static const DatabaseConfig databaseConfig = DatabaseConfig(
    databaseName: 'flutter_mall.db',
    databaseVersion: 1,
    enableEncryption: true,
  );

  /// 安全配置
  static const SecurityConfig securityConfig = SecurityConfig(
    enableCertificatePinning: !kDebugMode,
    allowHttpTraffic: kDebugMode,
    tokenRefreshThreshold: Duration(minutes: 5),
    maxRetryAttempts: 3,
    sessionTimeout: Duration(hours: 24),
  );

  /// 分页配置
  static const PaginationConfig paginationConfig = PaginationConfig(
    defaultPageSize: 20,
    maxPageSize: 100,
    preloadThreshold: 5,
  );

  /// 动画配置
  static const AnimationConfig animationConfig = AnimationConfig(
    defaultDuration: Duration(milliseconds: 300),
    fastDuration: Duration(milliseconds: 150),
    slowDuration: Duration(milliseconds: 500),
    pageTransitionDuration: Duration(milliseconds: 250),
  );
}

/// 环境枚举
enum Environment {
  development,
  staging,
  production;

  /// 是否为开发环境
  bool get isDevelopment => this == Environment.development;

  /// 是否为测试环境
  bool get isStaging => this == Environment.staging;

  /// 是否为生产环境
  bool get isProduction => this == Environment.production;

  /// 环境名称
  String get name {
    switch (this) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
}

/// 环境配置
class EnvironmentConfig {
  const EnvironmentConfig({
    required this.environment,
    required this.baseUrl,
    required this.graphqlEndpoint,
    required this.websocketEndpoint,
    required this.timeout,
    required this.enableLogging,
    required this.enableDebugMode,
    required this.enablePerformanceOverlay,
  });

  final Environment environment;
  final String baseUrl;
  final String graphqlEndpoint;
  final String websocketEndpoint;
  final Duration timeout;
  final bool enableLogging;
  final bool enableDebugMode;
  final bool enablePerformanceOverlay;
}

/// 功能开关
class FeatureFlags {
  const FeatureFlags({
    required this.enableBiometricAuth,
    required this.enablePushNotifications,
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.enableA11ySupport,
    required this.enableDarkMode,
    required this.enableOfflineMode,
    required this.enableExperimentalFeatures,
  });

  final bool enableBiometricAuth;
  final bool enablePushNotifications;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enableA11ySupport;
  final bool enableDarkMode;
  final bool enableOfflineMode;
  final bool enableExperimentalFeatures;
}

/// 缓存配置
class CacheConfig {
  const CacheConfig({
    required this.maxCacheSize,
    required this.imageCacheSize,
    required this.networkCacheSize,
    required this.defaultCacheTimeout,
    required this.imageCacheTimeout,
  });

  final int maxCacheSize;
  final int imageCacheSize;
  final int networkCacheSize;
  final Duration defaultCacheTimeout;
  final Duration imageCacheTimeout;
}

/// 数据库配置
class DatabaseConfig {
  const DatabaseConfig({
    required this.databaseName,
    required this.databaseVersion,
    required this.enableEncryption,
  });

  final String databaseName;
  final int databaseVersion;
  final bool enableEncryption;
}

/// 安全配置
class SecurityConfig {
  const SecurityConfig({
    required this.enableCertificatePinning,
    required this.allowHttpTraffic,
    required this.tokenRefreshThreshold,
    required this.maxRetryAttempts,
    required this.sessionTimeout,
  });

  final bool enableCertificatePinning;
  final bool allowHttpTraffic;
  final Duration tokenRefreshThreshold;
  final int maxRetryAttempts;
  final Duration sessionTimeout;
}

/// 分页配置
class PaginationConfig {
  const PaginationConfig({
    required this.defaultPageSize,
    required this.maxPageSize,
    required this.preloadThreshold,
  });

  final int defaultPageSize;
  final int maxPageSize;
  final int preloadThreshold;
}

/// 动画配置
class AnimationConfig {
  const AnimationConfig({
    required this.defaultDuration,
    required this.fastDuration,
    required this.slowDuration,
    required this.pageTransitionDuration,
  });

  final Duration defaultDuration;
  final Duration fastDuration;
  final Duration slowDuration;
  final Duration pageTransitionDuration;
}
