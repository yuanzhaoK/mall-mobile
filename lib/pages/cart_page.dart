import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/pages/order_confirm_page.dart';
import 'package:flutter_home_mall/providers/cart_state.dart';
import 'package:flutter_home_mall/widgets/cart_item_widget.dart';
import 'package:provider/provider.dart';

/// 购物车页面
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('购物车'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Consumer<CartState>(
        builder: (context, cartState, child) {
          if (cartState.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // 购物车商品列表
              Expanded(child: _buildCartList(context, cartState)),

              // 底部结算栏
              _buildBottomBar(context, cartState),
            ],
          );
        },
      ),
    );
  }

  /// 构建空购物车界面
  Widget _buildEmptyCart(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '购物车空空的',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快去添加喜欢的商品吧～',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('去逛逛'),
          ),
        ],
      ),
    );
  }

  /// 构建购物车商品列表
  Widget _buildCartList(BuildContext context, CartState cartState) {
    return Column(
      children: [
        // 全选和删除操作栏
        _buildOperationBar(context, cartState),

        // 商品列表
        Expanded(
          child: ListView.builder(
            itemCount: cartState.items.length,
            itemBuilder: (context, index) {
              final item = cartState.items[index];

              return CartItemWidget(
                item: item,
                isSelected: cartState.isItemSelected(item.id),
                onToggleSelection: () {
                  cartState.toggleItemSelection(item.id);
                },
                onQuantityChanged: (quantity) {
                  cartState.updateQuantity(item.id, quantity);
                },
                onRemove: () {
                  _showRemoveDialog(context, cartState, item.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建操作栏（全选、删除等）
  Widget _buildOperationBar(BuildContext context, CartState cartState) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // 全选
          Row(
            children: [
              Checkbox(
                value: cartState.selectAll,
                onChanged: (_) => cartState.toggleSelectAll(),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text('全选', style: theme.textTheme.bodyMedium),
            ],
          ),

          const Spacer(),

          // 删除选中商品
          if (cartState.selectedItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                _showRemoveSelectedDialog(context, cartState);
              },
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
              label: Text(
                '删除选中',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建底部结算栏
  Widget _buildBottomBar(BuildContext context, CartState cartState) {
    final theme = Theme.of(context);
    final hasSelectedItems = cartState.selectedItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 优惠和运费信息
            if (hasSelectedItems) ...[
              _buildPriceInfo(context, cartState),
              const SizedBox(height: 12),
            ],

            // 结算栏
            Row(
              children: [
                // 价格信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasSelectedItems) ...[
                        Text(
                          '合计：',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¥${cartState.totalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.price,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '请选择商品',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 结算按钮
                FilledButton(
                  onPressed: hasSelectedItems
                      ? () => _proceedToCheckout(context, cartState)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    hasSelectedItems
                        ? '结算(${cartState.selectedItemCount})'
                        : '结算',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建价格信息
  Widget _buildPriceInfo(BuildContext context, CartState cartState) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 商品总价
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('商品总价：', style: theme.textTheme.bodyMedium),
              Text(
                '¥${cartState.selectedSubtotalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),

          // 运费
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('运费：', style: theme.textTheme.bodyMedium),
              Text(
                cartState.shippingText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cartState.shippingFee == 0
                      ? AppColors.success
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // 优惠
          if (cartState.discountAmount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('优惠：', style: theme.textTheme.bodyMedium),
                Text(
                  '-¥${cartState.discountAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ] else if (cartState.discountText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cartState.discountText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 显示删除单个商品确认对话框
  void _showRemoveDialog(
    BuildContext context,
    CartState cartState,
    String itemId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要从购物车中删除这件商品吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              cartState.removeFromCart(itemId);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示删除选中商品确认对话框
  void _showRemoveSelectedDialog(BuildContext context, CartState cartState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的${cartState.selectedItems.length}件商品吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              cartState.removeSelectedItems();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 进入结算流程
  void _proceedToCheckout(BuildContext context, CartState cartState) {
    if (cartState.selectedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择要结算的商品')));
      return;
    }

    // 获取选中的商品
    final selectedItems = cartState.items
        .where((item) => cartState.selectedItems.contains(item.id))
        .toList();

    // 跳转到订单确认页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmPage(items: selectedItems),
      ),
    );
  }
}
