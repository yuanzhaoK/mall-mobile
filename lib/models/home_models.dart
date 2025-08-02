// 首页相关数据模型
import 'package:flutter_home_mall/models/product_models.dart';

// 轮播图模型
class BannerItem {
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
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String type;
  final int sortOrder;
}

// 分类模型
class Category {
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
  final String id;
  final String name;
  final String? iconUrl;
  final int productCount;
}

// 热门项目模型
class TrendingItem {
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
  final String id;
  final String name;
  final String imageUrl;
  final double score;
  final String type;
}

// 推荐模型
class Recommendation {
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
  final String id;
  final String name;
  final String type;
  final String position;
  final List<Product> products;
}

// 广告模型
class Advertisement {
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
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;
  final String position;
  final String type;
}

// 首页数据模型
class HomeData {
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
  final List<BannerItem> banners;
  final List<Product> featuredProducts;
  final List<Category> categories;
  final List<TrendingItem> trendingItems;
  final List<Recommendation> recommendations;
  final List<Advertisement> advertisements;
}
