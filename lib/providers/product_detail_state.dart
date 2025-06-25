import 'package:flutter/foundation.dart';
import '../models/api_models.dart';

/// 商品详情状态管理
class ProductDetailState extends ChangeNotifier {
  ProductDetail? _productDetail;
  bool _isLoading = false;
  String? _error;

  // SKU选择相关
  ProductSku? _selectedSku;
  Map<String, String> _selectedAttributes = {};
  int _quantity = 1;

  // 页面状态
  int _currentImageIndex = 0;
  bool _showFullDescription = false;
  int _selectedTabIndex = 0; // 0: 详情, 1: 规格, 2: 评价

  // Getters
  ProductDetail? get productDetail => _productDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _productDetail != null;

  // SKU相关getters
  ProductSku? get selectedSku => _selectedSku;
  Map<String, String> get selectedAttributes =>
      Map.unmodifiable(_selectedAttributes);
  int get quantity => _quantity;
  bool get canAddToCart => _selectedSku?.hasStock == true && _quantity > 0;

  // 页面状态getters
  int get currentImageIndex => _currentImageIndex;
  bool get showFullDescription => _showFullDescription;
  int get selectedTabIndex => _selectedTabIndex;

  // 当前价格（基于选中的SKU或商品价格）
  double get currentPrice {
    return _selectedSku?.price ?? _productDetail?.product.price ?? 0.0;
  }

  // 当前原价
  double? get currentOriginalPrice {
    return _selectedSku?.originalPrice ?? _productDetail?.product.originalPrice;
  }

  // 当前库存
  int get currentStock {
    return _selectedSku?.stock ?? _productDetail?.stock ?? 0;
  }

  // 是否有折扣
  bool get hasDiscount {
    final original = currentOriginalPrice;
    return original != null && original > currentPrice;
  }

  // 折扣百分比
  double? get discountPercentage {
    final original = currentOriginalPrice;
    if (original != null && original > currentPrice) {
      return ((original - currentPrice) / original) * 100;
    }
    return null;
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

  /// 加载商品详情
  Future<void> loadProductDetail(String productId) async {
    try {
      _setLoading(true);
      _setError(null);

      // 这里应该调用后端API获取商品详情
      // 目前使用模拟数据
      await Future.delayed(const Duration(milliseconds: 1000));

      _productDetail = _generateMockProductDetail(productId);

      // 初始化选中的SKU（如果有SKU的话）
      if (_productDetail!.skus.isNotEmpty) {
        _selectedSku = _productDetail!.skus.first;
        _selectedAttributes = Map.from(_selectedSku!.attributes);
      }
    } catch (e) {
      _setError('加载商品详情失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 生成模拟商品详情数据
  ProductDetail _generateMockProductDetail(String productId) {
    return ProductDetail(
      product: Product(
        id: productId,
        name: 'iPhone 15 Pro Max 256GB 深空黑色',
        price: 9999.0,
        originalPrice: 10999.0,
        imageUrl:
            'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=iPhone',
        rating: 4.8,
        salesCount: 12580,
      ),
      images: [
        'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=iPhone+1',
        'https://via.placeholder.com/400x400/4ECDC4/FFFFFF?text=iPhone+2',
        'https://via.placeholder.com/400x400/45B7D1/FFFFFF?text=iPhone+3',
        'https://via.placeholder.com/400x400/96CEB4/FFFFFF?text=iPhone+4',
        'https://via.placeholder.com/400x400/FFEAA7/000000?text=iPhone+5',
      ],
      description: '''
iPhone 15 Pro Max，搭载强大的A17 Pro芯片，采用钛金属设计，更轻更坚固。

【核心特性】
• A17 Pro芯片，3纳米工艺，性能提升20%
• 钛金属机身，重量减轻19克
• 6.7英寸超视网膜XDR显示屏
• 4800万像素主摄系统
• 支持USB-C接口
• 全天候电池续航

【拍照系统】
• 4800万像素主摄
• 1200万像素超广角
• 1200万像素长焦（5倍光学变焦）
• 电影级视频录制

【其他功能】
• Face ID面容识别
• 无线充电支持
• MagSafe磁吸充电
• IP68级防水
• 5G网络支持
      ''',
      brand: 'Apple',
      category: '手机数码',
      specifications: [
        ProductSpec(name: '屏幕尺寸', value: '6.7', unit: '英寸'),
        ProductSpec(name: '分辨率', value: '2796x1290'),
        ProductSpec(name: '处理器', value: 'A17 Pro'),
        ProductSpec(name: '存储容量', value: '256', unit: 'GB'),
        ProductSpec(name: '运行内存', value: '8', unit: 'GB'),
        ProductSpec(name: '电池容量', value: '4441', unit: 'mAh'),
        ProductSpec(name: '重量', value: '221', unit: 'g'),
        ProductSpec(name: '厚度', value: '8.25', unit: 'mm'),
        ProductSpec(name: '网络制式', value: '5G/4G/3G'),
        ProductSpec(name: '操作系统', value: 'iOS 17'),
      ],
      skus: [
        ProductSku(
          id: 'sku_1',
          name: '256GB 深空黑色',
          price: 9999.0,
          originalPrice: 10999.0,
          stock: 50,
          image: 'https://via.placeholder.com/100x100/000000/FFFFFF?text=Black',
          attributes: {'容量': '256GB', '颜色': '深空黑色'},
        ),
        ProductSku(
          id: 'sku_2',
          name: '256GB 银色',
          price: 9999.0,
          originalPrice: 10999.0,
          stock: 30,
          image:
              'https://via.placeholder.com/100x100/C0C0C0/000000?text=Silver',
          attributes: {'容量': '256GB', '颜色': '银色'},
        ),
        ProductSku(
          id: 'sku_3',
          name: '512GB 深空黑色',
          price: 11999.0,
          originalPrice: 12999.0,
          stock: 20,
          image: 'https://via.placeholder.com/100x100/000000/FFFFFF?text=Black',
          attributes: {'容量': '512GB', '颜色': '深空黑色'},
        ),
        ProductSku(
          id: 'sku_4',
          name: '512GB 银色',
          price: 11999.0,
          originalPrice: 12999.0,
          stock: 15,
          image:
              'https://via.placeholder.com/100x100/C0C0C0/000000?text=Silver',
          attributes: {'容量': '512GB', '颜色': '银色'},
        ),
      ],
      service: ProductService(
        freeShipping: true,
        returnGuarantee: true,
        qualityAssurance: true,
        returnDays: 15,
        warranty: '1年保修',
      ),
      reviews: [
        ProductReview(
          id: 'review_1',
          userId: 'user_1',
          userName: '张**',
          userAvatar: 'https://via.placeholder.com/50x50/FF6B6B/FFFFFF?text=Z',
          rating: 5.0,
          content: '手机非常棒！拍照效果超级好，A17 Pro芯片性能强劲，游戏运行非常流畅。钛金属机身手感很棒，比之前轻了不少。',
          images: [
            'https://via.placeholder.com/200x200/FF6B6B/FFFFFF?text=Photo1',
            'https://via.placeholder.com/200x200/4ECDC4/FFFFFF?text=Photo2',
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          skuInfo: '256GB 深空黑色',
          isAnonymous: false,
        ),
        ProductReview(
          id: 'review_2',
          userId: 'user_2',
          userName: '李**',
          rating: 4.0,
          content: '整体不错，就是价格有点贵。不过用料确实好，系统也很流畅。',
          images: [],
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          skuInfo: '512GB 银色',
          isAnonymous: false,
        ),
        ProductReview(
          id: 'review_3',
          userId: 'user_3',
          userName: '匿名用户',
          rating: 5.0,
          content: '苹果粉丝必买！每年都换新机，这次的升级还是很明显的。',
          images: [],
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          isAnonymous: true,
        ),
      ],
      stock: 115,
      isInWishlist: false,
      shopName: 'Apple官方旗舰店',
      shopRating: 4.9,
    );
  }

  /// 选择SKU
  void selectSku(ProductSku sku) {
    _selectedSku = sku;
    _selectedAttributes = Map.from(sku.attributes);

    // 重置数量为1
    _quantity = 1;

    notifyListeners();
  }

  /// 选择属性（用于SKU匹配）
  void selectAttribute(String attributeName, String attributeValue) {
    _selectedAttributes[attributeName] = attributeValue;

    // 根据选中的属性查找匹配的SKU
    _findMatchingSku();

    notifyListeners();
  }

  /// 根据选中属性查找匹配的SKU
  void _findMatchingSku() {
    if (_productDetail == null) return;

    for (final sku in _productDetail!.skus) {
      bool matches = true;
      for (final entry in _selectedAttributes.entries) {
        if (sku.attributes[entry.key] != entry.value) {
          matches = false;
          break;
        }
      }

      if (matches) {
        _selectedSku = sku;
        break;
      }
    }
  }

  /// 设置数量
  void setQuantity(int quantity) {
    if (quantity < 1) return;
    if (quantity > currentStock) return;
    if (quantity > 99) return; // 限制最大数量

    _quantity = quantity;
    notifyListeners();
  }

  /// 增加数量
  void increaseQuantity() {
    setQuantity(_quantity + 1);
  }

  /// 减少数量
  void decreaseQuantity() {
    setQuantity(_quantity - 1);
  }

  /// 切换收藏状态
  void toggleWishlist() {
    if (_productDetail != null) {
      _productDetail = ProductDetail(
        product: _productDetail!.product,
        images: _productDetail!.images,
        description: _productDetail!.description,
        brand: _productDetail!.brand,
        category: _productDetail!.category,
        specifications: _productDetail!.specifications,
        skus: _productDetail!.skus,
        service: _productDetail!.service,
        reviews: _productDetail!.reviews,
        stock: _productDetail!.stock,
        isInWishlist: !_productDetail!.isInWishlist,
        shopName: _productDetail!.shopName,
        shopRating: _productDetail!.shopRating,
      );
      notifyListeners();
    }
  }

  /// 设置当前图片索引
  void setCurrentImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  /// 切换描述展开状态
  void toggleDescriptionExpansion() {
    _showFullDescription = !_showFullDescription;
    notifyListeners();
  }

  /// 设置选中的标签页
  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  /// 获取可选的属性值
  Map<String, List<String>> getAvailableAttributes() {
    if (_productDetail == null) return {};

    final Map<String, Set<String>> attributeMap = {};

    for (final sku in _productDetail!.skus) {
      for (final entry in sku.attributes.entries) {
        attributeMap[entry.key] ??= <String>{};
        attributeMap[entry.key]!.add(entry.value);
      }
    }

    return attributeMap.map((key, value) => MapEntry(key, value.toList()));
  }

  /// 检查属性组合是否有库存
  bool isAttributeCombinationAvailable(
    String attributeName,
    String attributeValue,
  ) {
    if (_productDetail == null) return false;

    final testAttributes = Map<String, String>.from(_selectedAttributes);
    testAttributes[attributeName] = attributeValue;

    for (final sku in _productDetail!.skus) {
      bool matches = true;
      for (final entry in testAttributes.entries) {
        if (sku.attributes[entry.key] != entry.value) {
          matches = false;
          break;
        }
      }

      if (matches && sku.hasStock) {
        return true;
      }
    }

    return false;
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _productDetail = null;
    _selectedSku = null;
    _selectedAttributes.clear();
    _quantity = 1;
    _currentImageIndex = 0;
    _showFullDescription = false;
    _selectedTabIndex = 0;
    _error = null;
    notifyListeners();
  }
}
