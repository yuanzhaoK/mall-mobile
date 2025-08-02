import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/models/home_models.dart' as home_models;
import 'package:flutter_home_mall/services/graphql/graphql_client.dart';
import 'package:flutter_home_mall/services/graphql/queries.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// 首页服务 - 处理首页数据获取相关操作
class HomeService {
  /// 获取首页数据
  static Future<HomeData?> getHomeData() async {
    try {
      debugPrint('🏠 获取首页数据...');

      final result = await GraphQLClientManager.executeQuery(
        GraphQLQueries.homeData,
        timeout: const Duration(seconds: 20),
      );

      if (result.hasException) {
        debugPrint('🏠 获取首页数据失败: ${result.exception}');
        return null;
      }

      if (result.data != null && result.data!['appHomeData'] != null) {
        debugPrint('🏠 获取首页数据成功');
        return HomeData.fromJson(result.data!['appHomeData']);
      }

      debugPrint('🏠 获取首页数据失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🏠 获取首页数据异常: $e');
      return null;
    }
  }

  /// 获取轮播图数据
  static Future<List<home_models.BannerItem>?> getBanners() async {
    try {
      debugPrint('🏠 获取轮播图数据...');

      const query = '''
        query GetBanners {
          banners {
            id
            title
            image_url
            link_url
            type
            sort_order
          }
        }
      ''';

      final result = await GraphQLClientManager.executeQuery(
        query,
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🏠 获取轮播图数据失败: ${result.exception}');
        return null;
      }

      if (result.data != null && result.data!['banners'] != null) {
        debugPrint('🏠 获取轮播图数据成功');
        final List<dynamic> bannersData = result.data!['banners'];
        return bannersData
            .map((item) => home_models.BannerItem.fromJson(item))
            .toList();
      }

      debugPrint('🏠 获取轮播图数据失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🏠 获取轮播图数据异常: $e');
      return null;
    }
  }

  /// 获取推荐商品
  static Future<List<Product>?> getFeaturedProducts({int limit = 10}) async {
    try {
      debugPrint('🏠 获取推荐商品...');

      const query = r'''
        query GetFeaturedProducts($limit: Int) {
          featuredProducts(limit: $limit) {
            id 
            name 
            price 
            original_price 
            image_url 
            rating 
            sales_count
            category_id
            description
            is_hot
            is_new
            tags
          }
        }
      ''';

      final result = await GraphQLClientManager.executeQuery(
        query,
        variables: {'limit': limit},
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🏠 获取推荐商品失败: ${result.exception}');
        return null;
      }

      if (result.data != null && result.data!['featuredProducts'] != null) {
        debugPrint('🏠 获取推荐商品成功');
        final List<dynamic> productsData = result.data!['featuredProducts'];
        return productsData.map((item) => Product.fromJson(item)).toList();
      }

      debugPrint('🏠 获取推荐商品失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🏠 获取推荐商品异常: $e');
      return null;
    }
  }

  /// 获取热门分类
  static Future<List<home_models.Category>?> getHotCategories({
    int limit = 8,
  }) async {
    try {
      debugPrint('🏠 获取热门分类...');

      const query = r'''
        query GetHotCategories($limit: Int) {
          hotCategories(limit: $limit) {
            id
            name
            icon_url
            product_count
          }
        }
      ''';

      final result = await GraphQLClientManager.executeQuery(
        query,
        variables: {'limit': limit},
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🏠 获取热门分类失败: ${result.exception}');
        return null;
      }

      if (result.data != null && result.data!['hotCategories'] != null) {
        debugPrint('🏠 获取热门分类成功');
        final List<dynamic> categoriesData = result.data!['hotCategories'];
        return categoriesData
            .map((item) => home_models.Category.fromJson(item))
            .toList();
      }

      debugPrint('🏠 获取热门分类失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🏠 获取热门分类异常: $e');
      return null;
    }
  }

  /// 刷新首页数据（强制从网络获取）
  static Future<HomeData?> refreshHomeData() async {
    try {
      debugPrint('🏠 刷新首页数据...');

      final result = await GraphQLClientManager.executeQuery(
        GraphQLQueries.homeData,
        fetchPolicy: FetchPolicy.networkOnly,
        timeout: const Duration(seconds: 25),
      );

      if (result.hasException) {
        debugPrint('🏠 刷新首页数据失败: ${result.exception}');
        return null;
      }

      if (result.data != null && result.data!['appHomeData'] != null) {
        debugPrint('🏠 刷新首页数据成功');
        return HomeData.fromJson(result.data!['appHomeData']);
      }

      debugPrint('🏠 刷新首页数据失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🏠 刷新首页数据异常: $e');
      return null;
    }
  }
}
