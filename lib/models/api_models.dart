class FeaturedProduct {
  final String id;
  final String name;
  final int price;

  FeaturedProduct({required this.id, required this.name, required this.price});

  factory FeaturedProduct.fromJson(Map<String, dynamic> json) {
    return FeaturedProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
    );
  }

  // 格式化价格显示
  String get formattedPrice => '¥${(price / 100).toStringAsFixed(2)}';
}

class Category {
  final String id;
  final String name;
  final String created;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.created,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      created: json['created'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class AppHomeData {
  final List<FeaturedProduct> featuredProducts;
  final List<Category> categories;

  AppHomeData({required this.featuredProducts, required this.categories});

  factory AppHomeData.fromJson(Map<String, dynamic> json) {
    final featuredProductsJson =
        json['featured_products'] as List<dynamic>? ?? [];
    final categoriesJson = json['categories'] as List<dynamic>? ?? [];

    return AppHomeData(
      featuredProducts: featuredProductsJson
          .map((item) => FeaturedProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      categories: categoriesJson
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
