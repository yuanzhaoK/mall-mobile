import 'package:flutter/foundation.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/services/graphql/graphql_client.dart';
import 'package:flutter_home_mall/services/graphql/queries.dart';
import 'package:flutter_home_mall/services/graphql/mutations.dart';

/// 购物车服务 - 处理购物车相关操作
class CartService {
  /// 获取购物车数量
  static Future<CartCount?> getCartCount() async {
    try {
      debugPrint('🛒 获取购物车数量...');

      final result = await GraphQLClientManager.executeQuery(
        GraphQLQueries.cartCount,
        timeout: const Duration(seconds: 10),
      );

      if (result.hasException) {
        debugPrint('🛒 获取购物车数量失败: ${result.exception}');
        return null;
      }

      if (result.data != null && result.data!['appCart'] != null) {
        debugPrint('🛒 获取购物车数量成功');
        return CartCount.fromJson(result.data!['appCart']);
      }

      debugPrint('🛒 获取购物车数量失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🛒 获取购物车数量异常: $e');
      return null;
    }
  }

  /// 添加商品到购物车
  static Future<CartItem?> addToCart({
    required String productId,
    required int quantity,
    String? specifications,
  }) async {
    try {
      debugPrint('🛒 添加商品到购物车...');
      debugPrint('   Product ID: $productId');
      debugPrint('   Quantity: $quantity');

      final addToCartInput = {
        'product_id': productId,
        'quantity': quantity,
        if (specifications != null) 'specifications': specifications,
      };

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.addToCart,
        variables: {'input': addToCartInput},
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🛒 添加商品到购物车失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['addToCart'] != null) {
        debugPrint('🛒 添加商品到购物车成功');
        return CartItem.fromJson(result.data!['addToCart']);
      }

      debugPrint('🛒 添加商品到购物车失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🛒 添加商品到购物车异常: $e');
      rethrow;
    }
  }

  /// 更新购物车商品数量
  static Future<CartItem?> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      debugPrint('🛒 更新购物车商品数量...');
      debugPrint('   Cart Item ID: $cartItemId');
      debugPrint('   New Quantity: $quantity');

      final updateCartItemInput = {
        'cart_item_id': cartItemId,
        'quantity': quantity,
      };

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.updateCartItem,
        variables: {'input': updateCartItemInput},
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🛒 更新购物车商品数量失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['updateCartItem'] != null) {
        debugPrint('🛒 更新购物车商品数量成功');
        return CartItem.fromJson(result.data!['updateCartItem']);
      }

      debugPrint('🛒 更新购物车商品数量失败：未收到预期的响应数据');
      return null;
    } catch (e) {
      debugPrint('🛒 更新购物车商品数量异常: $e');
      rethrow;
    }
  }

  /// 从购物车移除商品
  static Future<bool> removeFromCart({required String cartItemId}) async {
    try {
      debugPrint('🛒 从购物车移除商品...');
      debugPrint('   Cart Item ID: $cartItemId');

      final removeFromCartInput = {'cart_item_id': cartItemId};

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.removeFromCart,
        variables: {'input': removeFromCartInput},
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🛒 从购物车移除商品失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['removeFromCart'] != null) {
        final success = result.data!['removeFromCart']['success'] as bool;
        debugPrint('🛒 从购物车移除商品${success ? '成功' : '失败'}');
        return success;
      }

      debugPrint('🛒 从购物车移除商品失败：未收到预期的响应数据');
      return false;
    } catch (e) {
      debugPrint('🛒 从购物车移除商品异常: $e');
      rethrow;
    }
  }

  /// 清空购物车
  static Future<bool> clearCart() async {
    try {
      debugPrint('🛒 清空购物车...');

      final result = await GraphQLClientManager.executeMutation(
        GraphQLMutations.clearCart,
        timeout: const Duration(seconds: 15),
      );

      if (result.hasException) {
        debugPrint('🛒 清空购物车失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['clearCart'] != null) {
        final success = result.data!['clearCart']['success'] as bool;
        debugPrint('🛒 清空购物车${success ? '成功' : '失败'}');
        return success;
      }

      debugPrint('🛒 清空购物车失败：未收到预期的响应数据');
      return false;
    } catch (e) {
      debugPrint('🛒 清空购物车异常: $e');
      rethrow;
    }
  }

  /// 批量更新购物车商品
  static Future<bool> batchUpdateCartItems({
    required List<Map<String, dynamic>> updates,
  }) async {
    try {
      debugPrint('🛒 批量更新购物车商品...');
      debugPrint('   Updates count: ${updates.length}');

      final batchUpdateInput = {'updates': updates};

      const mutation = r'''
        mutation BatchUpdateCartItems(\$input: BatchUpdateCartItemsInput!) {
          batchUpdateCartItems(input: \$input) {
            success
            updated_count
            cart_total_items
          }
        }
      ''';

      final result = await GraphQLClientManager.executeMutation(
        mutation,
        variables: {'input': batchUpdateInput},
        timeout: const Duration(seconds: 20),
      );

      if (result.hasException) {
        debugPrint('🛒 批量更新购物车商品失败: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data != null && result.data!['batchUpdateCartItems'] != null) {
        final success = result.data!['batchUpdateCartItems']['success'] as bool;
        debugPrint('🛒 批量更新购物车商品${success ? '成功' : '失败'}');
        return success;
      }

      debugPrint('🛒 批量更新购物车商品失败：未收到预期的响应数据');
      return false;
    } catch (e) {
      debugPrint('🛒 批量更新购物车商品异常: $e');
      rethrow;
    }
  }

  /// 检查商品库存
  static Future<bool> checkProductStock({
    required String productId,
    required int quantity,
  }) async {
    try {
      debugPrint('🛒 检查商品库存...');
      debugPrint('   Product ID: $productId');
      debugPrint('   Quantity: $quantity');

      const query = r'''
        query CheckProductStock(\$productId: ID!, \$quantity: Int!) {
          checkProductStock(productId: \$productId, quantity: \$quantity) {
            available
            stock_count
            message
          }
        }
      ''';

      final result = await GraphQLClientManager.executeQuery(
        query,
        variables: {'productId': productId, 'quantity': quantity},
        timeout: const Duration(seconds: 10),
      );

      if (result.hasException) {
        debugPrint('🛒 检查商品库存失败: ${result.exception}');
        return false;
      }

      if (result.data != null && result.data!['checkProductStock'] != null) {
        final available =
            result.data!['checkProductStock']['available'] as bool;
        debugPrint('🛒 商品库存检查完成，可用: $available');
        return available;
      }

      debugPrint('🛒 检查商品库存失败：未收到预期的响应数据');
      return false;
    } catch (e) {
      debugPrint('🛒 检查商品库存异常: $e');
      return false;
    }
  }
}
