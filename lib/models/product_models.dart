// 商品相关数据模型

// 商品模型
class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final double rating;
  final int salesCount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.rating,
    required this.salesCount,
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
