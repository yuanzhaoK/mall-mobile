// 商城API数据模型定义
import 'package:flutter/material.dart';

// 轮播图模型
class BannerItem {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String type;
  final int sortOrder;

  BannerItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.type,
    required this.sortOrder,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      linkUrl: json['link_url'],
      type: json['type'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }
}

// 商品模型
class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final double rating;
  final int salesCount;
  // final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.rating,
    required this.salesCount,
    // this.tags = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      salesCount: json['sales_count'] ?? 0,
      // tags: List<String>.from(json['tags'] ?? []),
    );
  }

  // 计算折扣百分比
  double? get discountPercentage {
    if (originalPrice != null && originalPrice! > price) {
      return ((originalPrice! - price) / originalPrice!) * 100;
    }
    return null;
  }

  // 是否有折扣
  bool get hasDiscount => discountPercentage != null;

  // 格式化价格显示
  String get formattedPrice => '¥${price.toStringAsFixed(2)}';
  String get formattedOriginalPrice =>
      originalPrice != null ? '¥${originalPrice!.toStringAsFixed(2)}' : '';
}

// 商品详情模型
class ProductDetail {
  final Product product;
  final List<String> images;
  final String description;
  final String brand;
  final String category;
  final List<ProductSpec> specifications;
  final List<ProductSku> skus;
  final ProductService service;
  final List<ProductReview> reviews;
  final int stock;
  final bool isInWishlist;
  final String shopName;
  final double shopRating;

  ProductDetail({
    required this.product,
    required this.images,
    required this.description,
    required this.brand,
    required this.category,
    required this.specifications,
    required this.skus,
    required this.service,
    required this.reviews,
    required this.stock,
    required this.isInWishlist,
    required this.shopName,
    required this.shopRating,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      product: Product.fromJson(json['product'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      description: json['description'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      specifications:
          (json['specifications'] as List<dynamic>?)
              ?.map((item) => ProductSpec.fromJson(item))
              .toList() ??
          [],
      skus:
          (json['skus'] as List<dynamic>?)
              ?.map((item) => ProductSku.fromJson(item))
              .toList() ??
          [],
      service: ProductService.fromJson(json['service'] ?? {}),
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((item) => ProductReview.fromJson(item))
              .toList() ??
          [],
      stock: json['stock'] ?? 0,
      isInWishlist: json['is_in_wishlist'] ?? false,
      shopName: json['shop_name'] ?? '',
      shopRating: (json['shop_rating'] ?? 0).toDouble(),
    );
  }

  // 是否有库存
  bool get hasStock => stock > 0;

  // 库存状态文本
  String get stockText {
    if (stock <= 0) return '缺货';
    if (stock <= 10) return '仅剩$stock件';
    return '有库存';
  }

  // 平均评分
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    return reviews.fold(0.0, (sum, review) => sum + review.rating) /
        reviews.length;
  }

  // 评价统计
  Map<int, int> get ratingStats {
    final stats = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in reviews) {
      stats[review.rating.round()] = (stats[review.rating.round()] ?? 0) + 1;
    }
    return stats;
  }
}

// 商品规格模型
class ProductSpec {
  final String name;
  final String value;
  final String? unit;

  ProductSpec({required this.name, required this.value, this.unit});

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    return ProductSpec(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      unit: json['unit'],
    );
  }

  String get displayValue => unit != null ? '$value$unit' : value;
}

// 商品SKU模型
class ProductSku {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final int stock;
  final String? image;
  final Map<String, String> attributes;

  ProductSku({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.stock,
    this.image,
    required this.attributes,
  });

  factory ProductSku.fromJson(Map<String, dynamic> json) {
    return ProductSku(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      stock: json['stock'] ?? 0,
      image: json['image'],
      attributes: Map<String, String>.from(json['attributes'] ?? {}),
    );
  }

  bool get hasStock => stock > 0;
  String get formattedPrice => '¥${price.toStringAsFixed(2)}';
}

// 商品服务模型
class ProductService {
  final bool freeShipping;
  final bool returnGuarantee;
  final bool qualityAssurance;
  final int returnDays;
  final String warranty;

  ProductService({
    required this.freeShipping,
    required this.returnGuarantee,
    required this.qualityAssurance,
    required this.returnDays,
    required this.warranty,
  });

  factory ProductService.fromJson(Map<String, dynamic> json) {
    return ProductService(
      freeShipping: json['free_shipping'] ?? false,
      returnGuarantee: json['return_guarantee'] ?? false,
      qualityAssurance: json['quality_assurance'] ?? false,
      returnDays: json['return_days'] ?? 7,
      warranty: json['warranty'] ?? '',
    );
  }

  List<String> get serviceList {
    final services = <String>[];
    if (freeShipping) services.add('包邮');
    if (returnGuarantee) services.add('$returnDays天无理由退货');
    if (qualityAssurance) services.add('正品保证');
    if (warranty.isNotEmpty) services.add(warranty);
    return services;
  }
}

// 商品评价模型
class ProductReview {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final String? skuInfo;
  final bool isAnonymous;

  ProductReview({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.content,
    required this.images,
    required this.createdAt,
    this.skuInfo,
    required this.isAnonymous,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'],
      rating: (json['rating'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      skuInfo: json['sku_info'],
      isAnonymous: json['is_anonymous'] ?? false,
    );
  }

  String get displayUserName => isAnonymous ? '匿名用户' : userName;
  String get formattedDate =>
      '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
}

// 订单相关模型

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

// 分类模型
class Category {
  final String id;
  final String name;
  final String? iconUrl;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['icon_url'],
      productCount: json['product_count'] ?? 0,
    );
  }
}

// 热门项目模型
class TrendingItem {
  final String id;
  final String name;
  final String imageUrl;
  final double score;
  final String type;

  TrendingItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.score,
    required this.type,
  });

  factory TrendingItem.fromJson(Map<String, dynamic> json) {
    return TrendingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      type: json['type'] ?? '',
    );
  }
}

// 推荐模型
class Recommendation {
  final String id;
  final String name;
  final String type;
  final String position;
  final List<Product> products;

  Recommendation({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.products,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      position: json['position'] ?? '',
      products:
          (json['products'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
    );
  }
}

// 广告模型
class Advertisement {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String position;
  final String type;

  Advertisement({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
    required this.position,
    required this.type,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      linkUrl: json['link_url'],
      position: json['position'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

// 首页数据模型
class HomeData {
  final List<BannerItem> banners;
  final List<Product> featuredProducts;
  final List<Category> categories;
  final List<TrendingItem> trendingItems;
  final List<Recommendation> recommendations;
  final List<Advertisement> advertisements;

  HomeData({
    required this.banners,
    required this.featuredProducts,
    required this.categories,
    required this.trendingItems,
    required this.recommendations,
    required this.advertisements,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      banners:
          (json['banners'] as List<dynamic>?)
              ?.map((item) => BannerItem.fromJson(item))
              .toList() ??
          [],
      featuredProducts:
          (json['featured_products'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((item) => Category.fromJson(item))
              .toList() ??
          [],
      trendingItems:
          (json['trending_items'] as List<dynamic>?)
              ?.map((item) => TrendingItem.fromJson(item))
              .toList() ??
          [],
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((item) => Recommendation.fromJson(item))
              .toList() ??
          [],
      advertisements:
          (json['advertisements'] as List<dynamic>?)
              ?.map((item) => Advertisement.fromJson(item))
              .toList() ??
          [],
    );
  }
}

// 用户模型
class User {
  final String id;
  final String identity;
  final String username;
  final String email;
  final String? avatarUrl;
  final String memberLevel;
  final int points;
  final double balance;
  final int couponsCount;

  User({
    required this.id,
    required this.identity,
    required this.email,
    required this.username,
    this.avatarUrl,
    required this.memberLevel,
    required this.points,
    required this.balance,
    required this.couponsCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      identity: json['identity'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar'],
      memberLevel: json['member_level'] ?? 'NORMAL',
      points: json['points'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      couponsCount: json['coupons_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identity': identity,
      'email': email,
      'username': username,
      'avatar': avatarUrl,
      'member_level': memberLevel,
      'points': points,
      'balance': balance,
      'coupons_count': couponsCount,
    };
  }
}

// 认证响应模型
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['record'] ?? {}),
    );
  }
}

// 登录输入模型
class LoginInput {
  final String identity;
  final String password;

  LoginInput({required this.identity, required this.password});

  Map<String, dynamic> toJson() {
    return {'identity': identity, 'password': password};
  }
}

// 购物车数量模型
class CartCount {
  final int totalItems;

  CartCount({required this.totalItems});

  factory CartCount.fromJson(Map<String, dynamic> json) {
    return CartCount(totalItems: json['total_items'] ?? 0);
  }
}

// 购物车项目模型
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;

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

  double get totalPrice => unitPrice * quantity;
}
