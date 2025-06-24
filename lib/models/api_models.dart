/// 商城API数据模型定义

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
  final String username;
  final String email;
  final String? avatarUrl;
  final String memberLevel;
  final int points;
  final double balance;
  final int couponsCount;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.memberLevel,
    required this.points,
    required this.balance,
    required this.couponsCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
      memberLevel: json['member_level'] ?? 'NORMAL',
      points: json['points'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      couponsCount: json['coupons_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
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
