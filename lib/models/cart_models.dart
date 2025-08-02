// 购物车相关数据模型
import 'package:flutter_home_mall/models/product_models.dart';

// 购物车数量模型
class CartCount {
  CartCount({required this.totalItems});

  factory CartCount.fromJson(Map<String, dynamic> json) {
    return CartCount(totalItems: json['total_items'] ?? 0);
  }
  final int totalItems;
}

// 购物车项目模型
class CartItem {
  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;

  double get totalPrice => unitPrice * quantity;
}
