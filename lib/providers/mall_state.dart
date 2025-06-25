import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../models/home_models.dart' as home_models;

/// 商场状态管理
class MallState extends ChangeNotifier {
  List<Product> _products = [];
  List<home_models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // 筛选和排序条件
  String _selectedCategoryId = '';
  double _minPrice = 0;
  double _maxPrice = 10000;
  String _sortBy = 'default'; // default, price_asc, price_desc, sales, rating
  bool _hasDiscount = false;
  String _searchKeyword = '';

  // 分页相关
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // 视图模式
  bool _isGridView = true; // true: 网格视图, false: 列表视图

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  List<home_models.Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _products.isNotEmpty;
  bool get isEmpty => _products.isEmpty && !_isLoading;

  // 筛选条件getters
  String get selectedCategoryId => _selectedCategoryId;
  home_models.Category? get selectedCategory => _categories.firstWhere(
    (cat) => cat.id == _selectedCategoryId,
    orElse: () => home_models.Category(id: '', name: '全部分类', productCount: 0),
  );
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get sortBy => _sortBy;
  bool get hasDiscount => _hasDiscount;
  String get searchKeyword => _searchKeyword;

  // 分页相关getters
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  // 视图模式getter
  bool get isGridView => _isGridView;

  // 是否有激活的筛选条件
  bool get hasActiveFilters =>
      _selectedCategoryId.isNotEmpty ||
      _minPrice > 0 ||
      _maxPrice < 10000 ||
      _sortBy != 'default' ||
      _hasDiscount ||
      _searchKeyword.isNotEmpty;

  // 筛选条件文本描述
  String get filtersDescription {
    final filters = <String>[];

    if (_selectedCategoryId.isNotEmpty) {
      filters.add(selectedCategory?.name ?? '');
    }

    if (_minPrice > 0 || _maxPrice < 10000) {
      if (_minPrice > 0 && _maxPrice < 10000) {
        filters.add('¥${_minPrice.toInt()}-${_maxPrice.toInt()}');
      } else if (_minPrice > 0) {
        filters.add('¥${_minPrice.toInt()}以上');
      } else {
        filters.add('¥${_maxPrice.toInt()}以下');
      }
    }

    if (_hasDiscount) {
      filters.add('有折扣');
    }

    if (_searchKeyword.isNotEmpty) {
      filters.add('搜索: $_searchKeyword');
    }

    switch (_sortBy) {
      case 'price_asc':
        filters.add('价格升序');
        break;
      case 'price_desc':
        filters.add('价格降序');
        break;
      case 'sales':
        filters.add('销量优先');
        break;
      case 'rating':
        filters.add('评分优先');
        break;
    }

    return filters.join(' · ');
  }

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

  /// 设置加载更多状态
  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  /// 初始化数据
  Future<void> initialize() async {
    await Future.wait([loadCategories(), loadProducts(refresh: true)]);
  }

  /// 加载分类数据
  Future<void> loadCategories() async {
    try {
      // 这里应该调用后端API获取分类数据
      // 目前使用模拟数据
      await Future.delayed(const Duration(milliseconds: 500));

      _categories = _generateMockCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('加载分类失败: $e');
    }
  }

  /// 加载商品数据
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products.clear();
    }

    if (!_hasMore || _isLoadingMore) return;

    try {
      if (refresh) {
        _setLoading(true);
      } else {
        _setLoadingMore(true);
      }
      _setError(null);

      // 这里应该调用后端API获取商品数据
      // 目前使用模拟数据
      await Future.delayed(const Duration(milliseconds: 800));

      final newProducts = _generateMockProducts(_currentPage);

      if (refresh) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      // 应用筛选和排序
      _applyFiltersAndSort();

      _currentPage++;
      _hasMore = newProducts.isNotEmpty && newProducts.length >= 20;
    } catch (e) {
      _setError('加载商品失败: $e');
    } finally {
      if (refresh) {
        _setLoading(false);
      } else {
        _setLoadingMore(false);
      }
    }
  }

  /// 生成模拟分类数据
  List<home_models.Category> _generateMockCategories() {
    return [
      home_models.Category(id: 'phone', name: '手机数码', productCount: 1250),
      home_models.Category(id: 'computer', name: '电脑办公', productCount: 890),
      home_models.Category(id: 'appliance', name: '家用电器', productCount: 2100),
      home_models.Category(id: 'clothing', name: '服饰内衣', productCount: 3500),
      home_models.Category(id: 'home', name: '家居家装', productCount: 1800),
      home_models.Category(id: 'baby', name: '母婴', productCount: 980),
      home_models.Category(id: 'beauty', name: '美妆', productCount: 1200),
      home_models.Category(id: 'health', name: '个护健康', productCount: 750),
      home_models.Category(id: 'food', name: '食品饮料', productCount: 2800),
      home_models.Category(id: 'sport', name: '运动户外', productCount: 650),
      home_models.Category(id: 'car', name: '汽车用品', productCount: 420),
      home_models.Category(id: 'book', name: '图书', productCount: 1500),
    ];
  }

  /// 生成模拟商品数据
  List<Product> _generateMockProducts(int page) {
    final baseProducts = [
      // 手机数码
      Product(
        id: 'mall_${page}_1',
        name: '苹果iPhone 15 Pro Max 256GB',
        price: 9999.0,
        originalPrice: 10999.0,
        imageUrl:
            'https://via.placeholder.com/300x300/FF6B6B/FFFFFF?text=iPhone',
        rating: 4.8,
        salesCount: 12580,
      ),
      Product(
        id: 'mall_${page}_2',
        name: '华为Mate 60 Pro 512GB',
        price: 6999.0,
        originalPrice: 7499.0,
        imageUrl:
            'https://via.placeholder.com/300x300/4ECDC4/FFFFFF?text=Huawei',
        rating: 4.7,
        salesCount: 8960,
      ),
      Product(
        id: 'mall_${page}_3',
        name: '小米14 Ultra 16GB+1TB',
        price: 5999.0,
        originalPrice: 6499.0,
        imageUrl:
            'https://via.placeholder.com/300x300/45B7D1/FFFFFF?text=Xiaomi',
        rating: 4.6,
        salesCount: 15420,
      ),
      Product(
        id: 'mall_${page}_4',
        name: '三星Galaxy S24 Ultra 1TB',
        price: 8999.0,
        originalPrice: 9999.0,
        imageUrl:
            'https://via.placeholder.com/300x300/96CEB4/FFFFFF?text=Samsung',
        rating: 4.5,
        salesCount: 6780,
      ),

      // 电脑办公
      Product(
        id: 'mall_${page}_5',
        name: 'MacBook Pro 16英寸 M3 Max',
        price: 25999.0,
        originalPrice: 27999.0,
        imageUrl:
            'https://via.placeholder.com/300x300/A8E6CF/000000?text=MacBook',
        rating: 4.9,
        salesCount: 3200,
      ),
      Product(
        id: 'mall_${page}_6',
        name: '联想ThinkPad X1 Carbon',
        price: 12999.0,
        originalPrice: 14999.0,
        imageUrl:
            'https://via.placeholder.com/300x300/FFD93D/000000?text=ThinkPad',
        rating: 4.4,
        salesCount: 2100,
      ),

      // 家用电器
      Product(
        id: 'mall_${page}_7',
        name: '海尔冰箱 对开门 500L',
        price: 3999.0,
        originalPrice: 4999.0,
        imageUrl: 'https://via.placeholder.com/300x300/6C5CE7/FFFFFF?text=海尔',
        rating: 4.3,
        salesCount: 5600,
      ),
      Product(
        id: 'mall_${page}_8',
        name: '美的空调 1.5匹 变频',
        price: 2499.0,
        originalPrice: 2999.0,
        imageUrl: 'https://via.placeholder.com/300x300/FD79A8/FFFFFF?text=美的',
        rating: 4.2,
        salesCount: 8900,
      ),

      // 服饰内衣
      Product(
        id: 'mall_${page}_9',
        name: 'Nike Air Max 270 运动鞋',
        price: 899.0,
        originalPrice: 1199.0,
        imageUrl: 'https://via.placeholder.com/300x300/00B894/FFFFFF?text=Nike',
        rating: 4.6,
        salesCount: 12500,
      ),
      Product(
        id: 'mall_${page}_10',
        name: 'Adidas 三叶草卫衣',
        price: 599.0,
        originalPrice: 799.0,
        imageUrl:
            'https://via.placeholder.com/300x300/E17055/FFFFFF?text=Adidas',
        rating: 4.4,
        salesCount: 9800,
      ),

      // 家居家装
      Product(
        id: 'mall_${page}_11',
        name: '宜家 MALM 双人床架',
        price: 999.0,
        originalPrice: 1299.0,
        imageUrl: 'https://via.placeholder.com/300x300/FDCB6E/000000?text=IKEA',
        rating: 4.1,
        salesCount: 4200,
      ),
      Product(
        id: 'mall_${page}_12',
        name: '飞利浦 LED台灯 护眼',
        price: 299.0,
        originalPrice: 399.0,
        imageUrl:
            'https://via.placeholder.com/300x300/74B9FF/FFFFFF?text=Philips',
        rating: 4.5,
        salesCount: 7800,
      ),

      // 美妆
      Product(
        id: 'mall_${page}_13',
        name: '兰蔻小黑瓶精华液 50ml',
        price: 1080.0,
        originalPrice: 1280.0,
        imageUrl: 'https://via.placeholder.com/300x300/A29BFE/FFFFFF?text=兰蔻',
        rating: 4.7,
        salesCount: 6500,
      ),
      Product(
        id: 'mall_${page}_14',
        name: '雅诗兰黛红石榴套装',
        price: 899.0,
        originalPrice: 1099.0,
        imageUrl: 'https://via.placeholder.com/300x300/FD79A8/FFFFFF?text=雅诗兰黛',
        rating: 4.6,
        salesCount: 5200,
      ),

      // 食品饮料
      Product(
        id: 'mall_${page}_15',
        name: '茅台飞天 53度 500ml',
        price: 2699.0,
        originalPrice: 2999.0,
        imageUrl: 'https://via.placeholder.com/300x300/2D3436/FFFFFF?text=茅台',
        rating: 4.9,
        salesCount: 1800,
      ),
      Product(
        id: 'mall_${page}_16',
        name: '五常大米 东北珍珠米 5kg',
        price: 89.0,
        originalPrice: 119.0,
        imageUrl: 'https://via.placeholder.com/300x300/00B894/FFFFFF?text=大米',
        rating: 4.3,
        salesCount: 15600,
      ),

      // 运动户外
      Product(
        id: 'mall_${page}_17',
        name: '迪卡侬 瑜伽垫 防滑加厚',
        price: 159.0,
        originalPrice: 199.0,
        imageUrl: 'https://via.placeholder.com/300x300/00CEC9/FFFFFF?text=迪卡侬',
        rating: 4.2,
        salesCount: 8900,
      ),
      Product(
        id: 'mall_${page}_18',
        name: '李宁羽毛球拍 专业级',
        price: 899.0,
        originalPrice: 1199.0,
        imageUrl: 'https://via.placeholder.com/300x300/FDCB6E/000000?text=李宁',
        rating: 4.5,
        salesCount: 3400,
      ),

      // 图书
      Product(
        id: 'mall_${page}_19',
        name: '《Flutter实战》第二版',
        price: 89.0,
        originalPrice: 109.0,
        imageUrl:
            'https://via.placeholder.com/300x300/74B9FF/FFFFFF?text=Flutter',
        rating: 4.8,
        salesCount: 2800,
      ),
      Product(
        id: 'mall_${page}_20',
        name: '《设计模式》经典版',
        price: 69.0,
        originalPrice: 89.0,
        imageUrl: 'https://via.placeholder.com/300x300/A29BFE/FFFFFF?text=设计模式',
        rating: 4.6,
        salesCount: 4200,
      ),
    ];

    return baseProducts;
  }

  /// 应用筛选和排序
  void _applyFiltersAndSort() {
    var filteredProducts = List<Product>.from(_products);

    // 分类筛选
    if (_selectedCategoryId.isNotEmpty) {
      // 这里应该根据实际的分类字段进行筛选
      // 目前通过商品名称模糊匹配
      final categoryKeywords = _getCategoryKeywords(_selectedCategoryId);
      filteredProducts = filteredProducts.where((product) {
        return categoryKeywords.any(
          (keyword) =>
              product.name.toLowerCase().contains(keyword.toLowerCase()),
        );
      }).toList();
    }

    // 价格范围筛选
    filteredProducts = filteredProducts
        .where((p) => p.price >= _minPrice && p.price <= _maxPrice)
        .toList();

    // 折扣筛选
    if (_hasDiscount) {
      filteredProducts = filteredProducts.where((p) => p.hasDiscount).toList();
    }

    // 关键词搜索
    if (_searchKeyword.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.name.toLowerCase().contains(
          _searchKeyword.toLowerCase(),
        );
      }).toList();
    }

    // 排序
    switch (_sortBy) {
      case 'price_asc':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'sales':
        filteredProducts.sort((a, b) => b.salesCount.compareTo(a.salesCount));
        break;
      case 'rating':
        filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        // 保持默认顺序
        break;
    }

    _products = filteredProducts;
  }

  /// 获取分类关键词
  List<String> _getCategoryKeywords(String categoryId) {
    switch (categoryId) {
      case 'phone':
        return ['手机', 'iPhone', '华为', '小米', '三星', 'OPPO', 'vivo'];
      case 'computer':
        return ['电脑', 'MacBook', 'ThinkPad', '笔记本', '台式机'];
      case 'appliance':
        return ['冰箱', '空调', '洗衣机', '电视', '微波炉', '海尔', '美的'];
      case 'clothing':
        return ['鞋', '衣服', '裤子', 'Nike', 'Adidas', '服装'];
      case 'home':
        return ['床', '沙发', '桌子', '椅子', '台灯', '宜家', 'IKEA'];
      case 'baby':
        return ['奶粉', '纸尿裤', '玩具', '婴儿', '儿童'];
      case 'beauty':
        return ['化妆品', '护肤', '面膜', '口红', '兰蔻', '雅诗兰黛'];
      case 'health':
        return ['保健品', '维生素', '护理', '健康'];
      case 'food':
        return ['食品', '零食', '茶叶', '酒', '大米', '茅台'];
      case 'sport':
        return ['运动', '健身', '瑜伽', '羽毛球', '迪卡侬', '李宁'];
      case 'car':
        return ['汽车', '车载', '轮胎', '机油'];
      case 'book':
        return ['图书', '书', '教材', 'Flutter', '编程'];
      default:
        return [];
    }
  }

  /// 设置筛选条件
  void setFilters({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? hasDiscount,
    String? searchKeyword,
  }) {
    bool hasChanged = false;

    if (categoryId != null && categoryId != _selectedCategoryId) {
      _selectedCategoryId = categoryId;
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

    if (searchKeyword != null && searchKeyword != _searchKeyword) {
      _searchKeyword = searchKeyword;
      hasChanged = true;
    }

    if (hasChanged) {
      loadProducts(refresh: true);
    }
  }

  /// 清除所有筛选条件
  void clearFilters() {
    _selectedCategoryId = '';
    _minPrice = 0;
    _maxPrice = 10000;
    _sortBy = 'default';
    _hasDiscount = false;
    _searchKeyword = '';

    loadProducts(refresh: true);
  }

  /// 切换视图模式
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    await loadProducts(refresh: false);
  }
}
