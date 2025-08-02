import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_home_mall/models/api_models.dart';

/// 购物车状态管理
class CartState extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;
  bool _selectAll = false;
  List<String> _selectedItems = [];

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get selectAll => _selectAll;
  List<String> get selectedItems => List.unmodifiable(_selectedItems);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// 计算商品总价（不含运费和优惠）
  double get subtotalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// 计算选中商品的总价
  double get selectedSubtotalPrice {
    return _items
        .where((item) => _selectedItems.contains(item.id))
        .fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// 计算运费
  double get shippingFee {
    if (isEmpty || selectedSubtotalPrice == 0) return 0;
    if (selectedSubtotalPrice >= 99) return 0; // 满99免运费
    return 10;
  }

  /// 计算优惠金额
  double get discountAmount {
    var discount = 0;
    final subtotal = selectedSubtotalPrice;

    // 满减优惠
    if (subtotal >= 300) {
      discount += 50.0;
    } else if (subtotal >= 200) {
      discount += 30.0;
    } else if (subtotal >= 100) {
      discount += 15.0;
    }

    return discount;
  }

  /// 最终价格（选中商品总价 + 运费 - 优惠）
  double get totalPrice => selectedSubtotalPrice + shippingFee - discountAmount;

  /// 获取优惠信息文本
  String get discountText {
    if (discountAmount > 0) {
      return '已优惠 ¥${discountAmount.toStringAsFixed(2)}';
    }
    final subtotal = selectedSubtotalPrice;
    if (subtotal < 100 && subtotal > 0) {
      return '再购买¥${(100 - subtotal).toStringAsFixed(2)}享受满减优惠';
    }
    return '';
  }

  /// 获取运费信息文本
  String get shippingText {
    if (shippingFee == 0) {
      return '免运费';
    }
    final subtotal = selectedSubtotalPrice;
    if (subtotal > 0 && subtotal < 99) {
      return '再购买¥${(99 - subtotal).toStringAsFixed(2)}享受包邮';
    }
    return '运费¥${shippingFee.toStringAsFixed(2)}';
  }

  /// 获取选中商品数量
  int get selectedItemCount {
    return _items
        .where((item) => _selectedItems.contains(item.id))
        .fold(0, (sum, item) => sum + item.quantity);
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

  /// 选中/取消选中商品
  void toggleItemSelection(String itemId) {
    if (_selectedItems.contains(itemId)) {
      _selectedItems.remove(itemId);
    } else {
      _selectedItems.add(itemId);
    }

    // 更新全选状态
    _selectAll = _selectedItems.length == _items.length;
    notifyListeners();
  }

  /// 全选/取消全选
  void toggleSelectAll() {
    _selectAll = !_selectAll;
    if (_selectAll) {
      _selectedItems = _items.map((item) => item.id).toList();
    } else {
      _selectedItems.clear();
    }
    notifyListeners();
  }

  /// 检查商品是否被选中
  bool isItemSelected(String itemId) {
    return _selectedItems.contains(itemId);
  }

  /// 添加商品到购物车
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      _setLoading(true);
      _setError(null);

      // 检查商品是否已在购物车中
      final existingIndex = _items.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingIndex >= 0) {
        // 如果已存在，增加数量
        final existingItem = _items[existingIndex];
        final newQuantity = existingItem.quantity + quantity;

        if (newQuantity > 99) {
          _setError('商品数量不能超过99件');
          return;
        }

        _items[existingIndex] = CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: newQuantity,
          unitPrice: existingItem.unitPrice,
        );
      } else {
        // 如果不存在，添加新项目
        final newItem = CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: product,
          quantity: quantity,
          unitPrice: product.price,
        );
        _items.add(newItem);

        // 新添加的商品默认选中
        _selectedItems.add(newItem.id);
      }

      // 更新全选状态
      _selectAll = _selectedItems.length == _items.length;
      notifyListeners();
    } catch (e) {
      _setError('添加到购物车失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 更新购物车项目数量
  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      _setError(null);

      if (quantity <= 0) {
        await removeFromCart(itemId);
        return;
      }

      if (quantity > 99) {
        _setError('商品数量不能超过99件');
        return;
      }

      final index = _items.indexWhere((item) => item.id == itemId);
      if (index >= 0) {
        final item = _items[index];
        _items[index] = CartItem(
          id: item.id,
          product: item.product,
          quantity: quantity,
          unitPrice: item.unitPrice,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('更新数量失败: ${e.toString()}');
    }
  }

  /// 从购物车移除商品
  Future<void> removeFromCart(String itemId) async {
    try {
      _setError(null);

      _items.removeWhere((item) => item.id == itemId);
      _selectedItems.remove(itemId);

      // 更新全选状态
      _selectAll = _selectedItems.length == _items.length && _items.isNotEmpty;
      notifyListeners();
    } catch (e) {
      _setError('移除商品失败: ${e.toString()}');
    }
  }

  /// 删除选中的商品
  Future<void> removeSelectedItems() async {
    try {
      _setError(null);
      _setLoading(true);

      if (_selectedItems.isEmpty) {
        _setError('请选择要删除的商品');
        return;
      }

      _items.removeWhere((item) => _selectedItems.contains(item.id));
      _selectedItems.clear();
      _selectAll = false;

      notifyListeners();
    } catch (e) {
      _setError('删除选中商品失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 清空购物车
  Future<void> clearCart() async {
    try {
      _setLoading(true);
      _setError(null);

      _items.clear();
      _selectedItems.clear();
      _selectAll = false;
      notifyListeners();
    } catch (e) {
      _setError('清空购物车失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 获取购物车数量
  Future<void> loadCartCount() async {
    try {
      _setLoading(true);
      _setError(null);

      // 这里可以调用API获取购物车数量
      // final count = await GraphQLService.getCartCount();
      // 目前使用本地数据
    } catch (e) {
      _setError('获取购物车数量失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 检查商品是否在购物车中
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  /// 获取商品在购物车中的数量
  int getProductQuantity(String productId) {
    final item = _items
        .where((item) => item.product.id == productId)
        .firstOrNull;
    return item?.quantity ?? 0;
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
