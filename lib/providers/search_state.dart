import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/models/api_models.dart';

/// 搜索状态管理
class SearchState extends ChangeNotifier {
  List<Product> _searchResults = [];
  List<String> _searchHistory = [];
  List<String> _hotSearches = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';

  // 筛选条件
  String _selectedCategory = '';
  double _minPrice = 0;
  double _maxPrice = 10000;
  String _sortBy = 'default'; // default, price_asc, price_desc, sales, rating
  bool _hasDiscount = false;

  // Getters
  List<Product> get searchResults => List.unmodifiable(_searchResults);
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  List<String> get hotSearches => List.unmodifiable(_hotSearches);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasSearched => _currentQuery.isNotEmpty;

  // 筛选条件getters
  String get selectedCategory => _selectedCategory;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get sortBy => _sortBy;
  bool get hasDiscount => _hasDiscount;

  // 是否有激活的筛选条件
  bool get hasActiveFilters =>
      _selectedCategory.isNotEmpty ||
      _minPrice > 0 ||
      _maxPrice < 10000 ||
      _sortBy != 'default' ||
      _hasDiscount;

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// 初始化热门搜索
  void initializeHotSearches() {
    _hotSearches = [
      '手机',
      '电脑',
      '耳机',
      '键盘',
      '鼠标',
      '充电器',
      '数据线',
      '移动电源',
      '蓝牙音箱',
      '智能手表',
    ];
    notifyListeners();
  }

  /// 搜索商品
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    try {
      _setLoading(true);
      _setError(null);
      _currentQuery = query.trim();

      // 添加到搜索历史
      _addToSearchHistory(query);

      // 这里应该调用后端API进行搜索
      // 目前使用模拟数据
      await Future.delayed(const Duration(milliseconds: 800));

      _searchResults = _generateMockSearchResults(query);

      // 应用筛选条件
      _applyFilters();
    } catch (e) {
      _setError('搜索失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 生成模拟搜索结果
  List<Product> _generateMockSearchResults(String query) {
    // 模拟搜索结果
    final mockResults = <Product>[
      Product(
        id: 'search_1',
        name: '苹果iPhone 15 Pro Max 256GB',
        price: 9999,
        originalPrice: 10999,
        imageUrl:
            'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=iPhone',
        rating: 4.8,
        salesCount: 12580,
      ),
      Product(
        id: 'search_2',
        name: '华为Mate 60 Pro 512GB',
        price: 6999,
        originalPrice: 7499,
        imageUrl:
            'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=Huawei',
        rating: 4.7,
        salesCount: 8960,
      ),
      Product(
        id: 'search_3',
        name: '小米14 Ultra 16GB+1TB',
        price: 5999,
        originalPrice: 6499,
        imageUrl:
            'https://via.placeholder.com/300x300/45B7D1/FFFFFF?text=Xiaomi',
        rating: 4.6,
        salesCount: 15420,
      ),
      Product(
        id: 'search_4',
        name: '三星Galaxy S24 Ultra 1TB',
        price: 8999,
        originalPrice: 9999,
        imageUrl:
            'https://via.placeholder.com/300x300/96CEB4/FFFFFF?text=Samsung',
        rating: 4.5,
        salesCount: 6780,
      ),
      Product(
        id: 'search_5',
        name: 'OPPO Find X7 Ultra 16GB+512GB',
        price: 5499,
        originalPrice: 5999,
        imageUrl: 'https://via.placeholder.com/300x300/FFEAA7/000000?text=OPPO',
        rating: 4.4,
        salesCount: 4320,
      ),
      Product(
        id: 'search_6',
        name: 'vivo X100 Pro+ 16GB+1TB',
        price: 4999,
        originalPrice: 5499,
        imageUrl: 'https://via.placeholder.com/300x300/DDA0DD/FFFFFF?text=vivo',
        rating: 4.3,
        salesCount: 3890,
      ),
    ];

    // 根据查询关键词过滤结果
    return mockResults.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains('手机') ||
          query.toLowerCase().contains('phone');
    }).toList();
  }

  /// 应用筛选条件
  void _applyFilters() {
    var results = List<Product>.from(_searchResults);

    // 分类筛选
    if (_selectedCategory.isNotEmpty) {
      // 这里应该根据实际的分类字段进行筛选
      // results = results.where((p) => p.categoryId == _selectedCategory).toList();
    }

    // 价格范围筛选
    results = results
        .where((p) => p.price >= _minPrice && p.price <= _maxPrice)
        .toList();

    // 折扣筛选
    if (_hasDiscount) {
      results = results.where((p) => p.hasDiscount).toList();
    }

    // 排序
    switch (_sortBy) {
      case 'price_asc':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'sales':
        results.sort((a, b) => b.salesCount.compareTo(a.salesCount));
        break;
      case 'rating':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        // 保持默认顺序
        break;
    }

    _searchResults = results;
  }

  /// 设置筛选条件
  void setFilters({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? hasDiscount,
  }) {
    var hasChanged = false;

    if (category != null && category != _selectedCategory) {
      _selectedCategory = category;
      hasChanged = true;
    }

    if (minPrice != null && minPrice != _minPrice) {
      _minPrice = minPrice;
      hasChanged = true;
    }

    if (maxPrice != null && maxPrice != _maxPrice) {
      _maxPrice = maxPrice;
      hasChanged = true;
    }

    if (sortBy != null && sortBy != _sortBy) {
      _sortBy = sortBy;
      hasChanged = true;
    }

    if (hasDiscount != null && hasDiscount != _hasDiscount) {
      _hasDiscount = hasDiscount;
      hasChanged = true;
    }

    if (hasChanged) {
      _applyFilters();
      notifyListeners();
    }
  }

  /// 清除所有筛选条件
  void clearFilters() {
    _selectedCategory = '';
    _minPrice = 0;
    _maxPrice = 10000;
    _sortBy = 'default';
    _hasDiscount = false;

    if (_currentQuery.isNotEmpty) {
      _applyFilters();
    }
    notifyListeners();
  }

  /// 清除搜索
  void clearSearch() {
    _searchResults.clear();
    _currentQuery = '';
    _error = null;
    notifyListeners();
  }

  /// 添加到搜索历史
  void _addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;

    // 移除重复项
    _searchHistory.remove(query);

    // 添加到开头
    _searchHistory.insert(0, query);

    // 限制历史记录数量
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.take(20).toList();
    }

    // 这里可以保存到本地存储
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.setStringList('search_history', _searchHistory);
    // });
  }

  /// 删除搜索历史项
  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }

  /// 清空搜索历史
  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  /// 获取搜索建议
  List<String> getSearchSuggestions(String query) {
    if (query.trim().isEmpty) return [];

    final suggestions = <String>[];

    // 从搜索历史中获取建议
    for (final history in _searchHistory) {
      if (history.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(history);
      }
    }

    // 从热门搜索中获取建议
    for (final hot in _hotSearches) {
      if (hot.toLowerCase().contains(query.toLowerCase()) &&
          !suggestions.contains(hot)) {
        suggestions.add(hot);
      }
    }

    return suggestions.take(10).toList();
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
