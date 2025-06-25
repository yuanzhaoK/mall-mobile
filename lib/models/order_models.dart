// 订单相关数据模型
import 'package:flutter/material.dart';
import 'cart_models.dart';

// 订单状态枚举
enum OrderStatus {
  pending('pending', '待付款'),
  paid('paid', '已付款'),
  processing('processing', '处理中'),
  shipped('shipped', '已发货'),
  delivered('delivered', '已送达'),
  completed('completed', '已完成'),
  cancelled('cancelled', '已取消'),
  refunded('refunded', '已退款');

  const OrderStatus(this.code, this.label);
  final String code;
  final String label;

  static OrderStatus fromCode(String code) {
    return OrderStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => OrderStatus.pending,
    );
  }
}

// 支付方式枚举
enum PaymentMethod {
  alipay('alipay', '支付宝'),
  wechat('wechat', '微信支付'),
  bankCard('bank_card', '银行卡'),
  balance('balance', '余额支付');

  const PaymentMethod(this.code, this.label);
  final String code;
  final String label;

  static PaymentMethod fromCode(String code) {
    return PaymentMethod.values.firstWhere(
      (method) => method.code == code,
      orElse: () => PaymentMethod.alipay,
    );
  }
}

// 订单商品项模型
class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double? originalPrice;
  final int quantity;
  final String? skuId;
  final String? skuName;
  final Map<String, String> attributes;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.originalPrice,
    required this.quantity,
    this.skuId,
    this.skuName,
    required this.attributes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      quantity: json['quantity'] ?? 0,
      skuId: json['sku_id'],
      skuName: json['sku_name'],
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'original_price': originalPrice,
      'quantity': quantity,
      'sku_id': skuId,
      'sku_name': skuName,
      'attributes': attributes,
    };
  }

  // 从购物车项创建订单项
  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      id: cartItem.id,
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      productImage: cartItem.product.imageUrl,
      price: cartItem.unitPrice,
      originalPrice: cartItem.product.originalPrice,
      quantity: cartItem.quantity,
      skuId: null, // 当前CartItem不包含SKU信息
      skuName: null,
      attributes: {}, // 当前CartItem不包含属性信息
    );
  }

  // 小计金额
  double get subtotal => price * quantity;

  // 原价小计
  double? get originalSubtotal =>
      originalPrice != null ? originalPrice! * quantity : null;

  // 是否有折扣
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  // 格式化价格
  String get formattedPrice => '¥${price.toStringAsFixed(2)}';
  String get formattedSubtotal => '¥${subtotal.toStringAsFixed(2)}';

  // 属性显示文本
  String get attributesText {
    if (attributes.isEmpty) return '';
    return attributes.values.join(' ');
  }
}

// 收货地址模型
class ShippingAddress {
  final String id;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String address;
  final String? postalCode;
  final bool isDefault;

  ShippingAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.address,
    this.postalCode,
    required this.isDefault,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      address: json['address'] ?? '',
      postalCode: json['postal_code'],
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'province': province,
      'city': city,
      'district': district,
      'address': address,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }

  // 完整地址
  String get fullAddress => '$province$city$district$address';

  // 地址标签
  String get addressLabel => '$name $phone';
}

// 订单模型
class Order {
  final String id;
  final String orderNo;
  final String userId;
  final OrderStatus status;
  final List<OrderItem> items;
  final ShippingAddress shippingAddress;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double totalAmount;
  final PaymentMethod? paymentMethod;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? remark;
  final String? trackingNumber;
  final String? cancelReason;

  Order({
    required this.id,
    required this.orderNo,
    required this.userId,
    required this.status,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.totalAmount,
    this.paymentMethod,
    required this.createdAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.remark,
    this.trackingNumber,
    this.cancelReason,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      orderNo: json['order_no'] ?? '',
      userId: json['user_id'] ?? '',
      status: OrderStatus.fromCode(json['status'] ?? ''),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      shippingAddress: ShippingAddress.fromJson(json['shipping_address'] ?? {}),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shipping_fee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] != null
          ? PaymentMethod.fromCode(json['payment_method'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.tryParse(json['shipped_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'])
          : null,
      remark: json['remark'],
      trackingNumber: json['tracking_number'],
      cancelReason: json['cancel_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_no': orderNo,
      'user_id': userId,
      'status': status.code,
      'items': items.map((item) => item.toJson()).toList(),
      'shipping_address': shippingAddress.toJson(),
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'discount': discount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod?.code,
      'created_at': createdAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'remark': remark,
      'tracking_number': trackingNumber,
      'cancel_reason': cancelReason,
    };
  }

  // 商品数量
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  // 商品种类数
  int get itemTypeCount => items.length;

  // 是否可以取消
  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.paid;

  // 是否可以支付
  bool get canPay => status == OrderStatus.pending;

  // 是否可以确认收货
  bool get canConfirmDelivery => status == OrderStatus.shipped;

  // 是否可以评价
  bool get canReview =>
      status == OrderStatus.delivered || status == OrderStatus.completed;

  // 是否可以申请退款
  bool get canRefund =>
      status == OrderStatus.paid || status == OrderStatus.processing;

  // 格式化金额
  String get formattedSubtotal => '¥${subtotal.toStringAsFixed(2)}';
  String get formattedShippingFee => '¥${shippingFee.toStringAsFixed(2)}';
  String get formattedDiscount => '¥${discount.toStringAsFixed(2)}';
  String get formattedTotalAmount => '¥${totalAmount.toStringAsFixed(2)}';

  // 格式化日期
  String get formattedCreatedAt => _formatDate(createdAt);
  String? get formattedPaidAt => paidAt != null ? _formatDate(paidAt!) : null;
  String? get formattedShippedAt =>
      shippedAt != null ? _formatDate(shippedAt!) : null;
  String? get formattedDeliveredAt =>
      deliveredAt != null ? _formatDate(deliveredAt!) : null;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // 主要商品信息（用于列表显示）
  OrderItem? get primaryItem => items.isNotEmpty ? items.first : null;

  // 状态颜色
  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paid:
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Colors.red;
    }
  }
}

// 订单创建请求模型
class CreateOrderRequest {
  final List<CartItem> items;
  final ShippingAddress shippingAddress;
  final String? remark;
  final String? couponId;

  CreateOrderRequest({
    required this.items,
    required this.shippingAddress,
    this.remark,
    this.couponId,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items
          .map(
            (item) => {
              'product_id': item.product.id,
              'sku_id': null, // 当前CartItem不包含SKU信息
              'quantity': item.quantity,
              'price': item.unitPrice,
            },
          )
          .toList(),
      'shipping_address': shippingAddress.toJson(),
      'remark': remark,
      'coupon_id': couponId,
    };
  }
}
