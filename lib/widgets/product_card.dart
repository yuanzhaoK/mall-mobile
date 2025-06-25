import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/api_models.dart';
import '../constants/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../providers/cart_state.dart';
import '../pages/product_detail_page.dart';

/// 商品卡片组件
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final bool showAddToCart;
  final bool showFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.showAddToCart = true,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap:
            onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    productId: product.id,
                    product: product,
                  ),
                ),
              );
            },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片区域
            _buildImageSection(context),

            // 商品信息区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品标题
                    _buildTitle(),
                    const SizedBox(height: AppSpacing.xs),

                    // 价格信息
                    _buildPriceSection(),
                    const SizedBox(height: AppSpacing.xs),

                    // 评分和销量
                    _buildRatingSection(),

                    const Spacer(),

                    // 底部操作区域
                    if (showAddToCart) _buildActionSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片区域
  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // 商品图片
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.md),
              topRight: Radius.circular(AppRadius.md),
            ),
            color: AppColors.surfaceVariant,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.md),
              topRight: Radius.circular(AppRadius.md),
            ),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppColors.textLight,
                  size: 32,
                ),
              ),
            ),
          ),
        ),

        // 收藏按钮
        if (showFavorite)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onFavorite,
                icon: const Icon(
                  Icons.favorite_border,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ),
          ),

        // 折扣标签
        if (product.hasDiscount)
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.discount,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: Text(
                '-${product.discountPercentage!.toStringAsFixed(0)}%',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Text(
      product.name,
      style: AppTextStyles.body2,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建价格区域
  Widget _buildPriceSection() {
    return Row(
      children: [
        // 现价
        Text(
          product.formattedPrice,
          style: AppTextStyles.price.copyWith(fontSize: 16),
        ),

        const SizedBox(width: AppSpacing.xs),

        // 原价
        if (product.hasDiscount)
          Text(
            product.formattedOriginalPrice,
            style: AppTextStyles.originalPrice.copyWith(fontSize: 12),
          ),
      ],
    );
  }

  /// 构建评分区域
  Widget _buildRatingSection() {
    return Row(
      children: [
        // 评分星星
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Icon(
              index < product.rating.floor()
                  ? Icons.star
                  : index < product.rating
                  ? Icons.star_half
                  : Icons.star_border,
              size: 12,
              color: AppColors.rating,
            );
          }),
        ),

        const SizedBox(width: AppSpacing.xs),

        // 评分数值
        Text(product.rating.toStringAsFixed(1), style: AppTextStyles.caption),

        const SizedBox(width: AppSpacing.sm),

        // 销量
        Text('销量${product.salesCount}', style: AppTextStyles.caption),
      ],
    );
  }

  /// 构建操作区域
  Widget _buildActionSection(BuildContext context) {
    return Consumer<CartState>(
      builder: (context, cartState, child) {
        final isInCart = cartState.isInCart(product.id);
        final quantity = cartState.getProductQuantity(product.id);

        return SizedBox(
          height: 32,
          child: Row(
            children: [
              // 数量显示（如果已在购物车中）
              if (isInCart) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text(
                    '已加$quantity件',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
              ] else
                const Spacer(),

              // 加购物车按钮
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InkWell(
                  onTap: cartState.isLoading
                      ? null
                      : () => _handleAddToCart(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cartState.isLoading)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Icon(
                            Icons.add_shopping_cart,
                            size: 14,
                            color: Colors.white,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          isInCart ? '再次购买' : '加购物车',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 处理加购物车
  void _handleAddToCart(BuildContext context) async {
    try {
      await context.read<CartState>().addToCart(product);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} 已加入购物车'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: '查看',
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
      }

      // 调用外部回调
      onAddToCart?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加入购物车失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
