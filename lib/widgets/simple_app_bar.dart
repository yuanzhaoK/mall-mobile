import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../core/themes/app_theme.dart';

/// 简化版自定义顶部栏
class SimpleCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onUserTap;
  final bool showSearch;
  final bool showNotification;
  final bool showCart;
  final bool showUser;
  final int cartItemCount;

  const SimpleCustomAppBar({
    super.key,
    this.title = '',
    this.onSearchTap,
    this.onNotificationTap,
    this.onCartTap,
    this.onUserTap,
    this.showSearch = true,
    this.showNotification = true,
    this.showCart = true,
    this.showUser = true,
    this.cartItemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              // 用户头像/登录按钮
              if (showUser) _buildUserSection(),

              const SizedBox(width: AppSpacing.sm),

              // 搜索框
              if (showSearch) Expanded(child: _buildSearchBar()),

              const SizedBox(width: AppSpacing.sm),

              // 右侧图标组
              _buildActionIcons(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户区域
  Widget _buildUserSection() {
    return GestureDetector(
      onTap: onUserTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: const Icon(
          Icons.person_outline,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: onSearchTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '搜索商品、品牌、店铺',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  /// 构建操作图标组
  Widget _buildActionIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 通知图标
        if (showNotification) ...[
          _buildNotificationIcon(),
          const SizedBox(width: AppSpacing.sm),
        ],

        // 购物车图标
        if (showCart) _buildCartIcon(),
      ],
    );
  }

  /// 构建通知图标
  Widget _buildNotificationIcon() {
    return GestureDetector(
      onTap: onNotificationTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            // 小红点
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建购物车图标
  Widget _buildCartIcon() {
    return GestureDetector(
      onTap: onCartTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            // 购物车数量徽章
            if (cartItemCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.cartBadge,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
