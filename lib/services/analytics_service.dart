import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/models/api_models.dart';

/// 简单的分析跟踪服务
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// 跟踪商品点击事件
  static void trackProductTap({
    required Product product,
    required String source, // 来源页面：home, search, mall, favorites
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Product Tap');
      debugPrint('   Product ID: ${product.id}');
      debugPrint('   Product Name: ${product.name}');
      debugPrint('   Price: ${product.formattedPrice}');
      debugPrint('   Source: $source');
      debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
      if (extra != null) {
        debugPrint('   Extra Data: $extra');
      }
    }

    // TODO: 这里可以集成实际的分析SDK
    // 例如: Firebase Analytics, 友盟统计, 神策数据等
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'product_view',
    //   parameters: {
    //     'product_id': product.id,
    //     'product_name': product.name,
    //     'product_price': product.price,
    //     'source_page': source,
    //     ...?extra,
    //   },
    // );
  }

  /// 跟踪商品分享事件
  static void trackProductShare({
    required Product product,
    required String platform, // 分享平台：wechat, moments, link, more
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Product Share');
      debugPrint('   Product ID: ${product.id}');
      debugPrint('   Product Name: ${product.name}');
      debugPrint('   Platform: $platform');
      debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
      if (extra != null) {
        debugPrint('   Extra Data: $extra');
      }
    }
  }

  /// 跟踪加购物车事件
  static void trackAddToCart({
    required Product product,
    required int quantity,
    String? source,
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Add to Cart');
      debugPrint('   Product ID: ${product.id}');
      debugPrint('   Product Name: ${product.name}');
      debugPrint('   Quantity: $quantity');
      debugPrint('   Source: $source');
      debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
      if (extra != null) {
        debugPrint('   Extra Data: $extra');
      }
    }
  }

  /// 跟踪立即购买事件
  static void trackBuyNow({
    required Product product,
    required int quantity,
    required double totalPrice,
    String? source,
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Buy Now');
      debugPrint('   Product ID: ${product.id}');
      debugPrint('   Product Name: ${product.name}');
      debugPrint('   Quantity: $quantity');
      debugPrint('   Total Price: ¥${totalPrice.toStringAsFixed(2)}');
      debugPrint('   Source: $source');
      debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
      if (extra != null) {
        debugPrint('   Extra Data: $extra');
      }
    }
  }

  /// 跟踪收藏事件
  static void trackFavorite({
    required Product product,
    required bool isFavorited, // true: 添加收藏, false: 取消收藏
    String? source,
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Favorite');
      debugPrint('   Product ID: ${product.id}');
      debugPrint('   Product Name: ${product.name}');
      debugPrint('   Action: ${isFavorited ? "Add" : "Remove"}');
      debugPrint('   Source: $source');
      debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
      if (extra != null) {
        debugPrint('   Extra Data: $extra');
      }
    }
  }

  /// 跟踪搜索事件
  static void trackSearch({
    required String query,
    int? resultCount,
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Search');
      debugPrint('   Query: $query');
      debugPrint('   Result Count: $resultCount');
      debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
      if (extra != null) {
        debugPrint('   Extra Data: $extra');
      }
    }
  }

  /// 跟踪页面浏览事件
  static void trackPageView({
    required String pageName,
    Map<String, dynamic>? extra,
  }) {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Page View');
      debugPrint('   Page: $pageName');
      debugPrint('   Timestamp: ${DateTime.now().toIso8601String()}');
      if (extra != null) {
        debugPrint('   Extra Data: $extra');
      }
    }
  }
}
