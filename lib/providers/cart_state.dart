import 'package:flutter/foundation.dart' hide Category;
import '../models/api_models.dart';
import '../services/graphql_service.dart';

/// 购物车状态管理
class CartState extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

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
        _items[existingIndex] = CartItem(
          id: existingItem.id,
          product: existingItem.product,
          quantity: existingItem.quantity + quantity,
          unitPrice: existingItem.unitPrice,
        );
      } else {
        // 如果不存在，添加新项目
        _items.add(
          CartItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            product: product,
            quantity: quantity,
            unitPrice: product.price,
          ),
        );
      }

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
      _setLoading(true);
      _setError(null);

      if (quantity <= 0) {
        await removeFromCart(itemId);
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
    } finally {
      _setLoading(false);
    }
  }

  /// 从购物车移除商品
  Future<void> removeFromCart(String itemId) async {
    try {
      _setLoading(true);
      _setError(null);

      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      _setError('移除商品失败: ${e.toString()}');
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
