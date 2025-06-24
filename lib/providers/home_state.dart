import 'package:flutter/foundation.dart' hide Category;
import '../models/api_models.dart';
import '../services/graphql_service.dart';

/// 首页状态管理
class HomeState extends ChangeNotifier {
  HomeData? _homeData;
  bool _isLoading = false;
  String? _error;
  bool _isRefreshing = false;

  // Getters
  HomeData? get homeData => _homeData;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  bool get hasData => _homeData != null;

  // 分别获取各部分数据
  List<BannerItem> get banners => _homeData?.banners ?? [];
  List<Product> get featuredProducts => _homeData?.featuredProducts ?? [];
  List<Category> get categories => _homeData?.categories ?? [];
  List<TrendingItem> get trendingItems => _homeData?.trendingItems ?? [];
  List<Recommendation> get recommendations => _homeData?.recommendations ?? [];
  List<Advertisement> get advertisements => _homeData?.advertisements ?? [];

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置刷新状态
  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// 加载首页数据
  Future<void> loadHomeData() async {
    if (_isLoading) return; // 防止重复加载

    try {
      _setLoading(true);
      _setError(null);

      final data = await GraphQLService.getHomeData();
      if (data != null) {
        _homeData = data;
      } else {
        _setError('加载数据失败，请检查网络连接');
      }
    } catch (e) {
      _setError('加载数据时出现错误: ${e.toString()}');
      debugPrint('加载首页数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 刷新首页数据
  Future<void> refreshHomeData() async {
    if (_isRefreshing) return; // 防止重复刷新

    try {
      _setRefreshing(true);
      _setError(null);

      final data = await GraphQLService.getHomeData();
      if (data != null) {
        _homeData = data;
        debugPrint('首页数据刷新成功');
      } else {
        throw Exception('刷新数据失败，请检查网络连接');
      }
    } catch (e) {
      _setError('刷新数据时出现错误: ${e.toString()}');
      debugPrint('刷新首页数据失败: $e');
      rethrow; // 重新抛出异常，让UI层能够捕获
    } finally {
      _setRefreshing(false);
    }
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重试加载数据
  Future<void> retry() async {
    await loadHomeData();
  }

  /// 根据类型获取推荐商品
  List<Product> getRecommendationsByType(String type) {
    final recommendation = recommendations
        .where((rec) => rec.type == type)
        .firstOrNull;
    return recommendation?.products ?? [];
  }

  /// 根据位置获取广告
  List<Advertisement> getAdvertisementsByPosition(String position) {
    return advertisements.where((ad) => ad.position == position).toList();
  }
}
