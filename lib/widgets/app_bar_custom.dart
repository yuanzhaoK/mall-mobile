import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../constants/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../providers/app_state.dart';
import '../providers/cart_state.dart';

/// 自定义顶部栏组件
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onUserTap;
  final bool showSearch;
  final bool showNotification;
  final bool showCart;
  final bool showUser;

  const CustomAppBar({
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
              if (showUser) _buildUserSection(context),

              const SizedBox(width: AppSpacing.sm),

              // 搜索框
              if (showSearch) Expanded(child: _buildSearchBar(context)),

              const SizedBox(width: AppSpacing.sm),

              // 右侧图标组
              _buildActionIcons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户区域
  Widget _buildUserSection(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.user;

        return GestureDetector(
          onTap: onUserTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: user != null
                  ? AppColors.primary
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: user != null
                ? _buildUserAvatar(user.avatarUrl, user.username)
                : const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
          ),
        );
      },
    );
  }

  /// 构建用户头像
  Widget _buildUserAvatar(String? avatarUrl, String username) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(username);
          },
        ),
      );
    }

    return _buildDefaultAvatar(username);
  }

  /// 构建默认头像
  Widget _buildDefaultAvatar(String username) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar(BuildContext context) {
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
  Widget _buildActionIcons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 通知图标
        if (showNotification) ...[
          _buildNotificationIcon(),
          const SizedBox(width: AppSpacing.sm),
        ],

        // 购物车图标
        if (showCart) _buildCartIcon(context),
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
        child: badges.Badge(
          position: badges.BadgePosition.topEnd(top: 8, end: 8),
          showBadge: true, // 这里可以根据实际通知数量决定
          badgeContent: const SizedBox(width: 6, height: 6),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: AppColors.error,
            padding: EdgeInsets.zero,
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// 构建购物车图标
  Widget _buildCartIcon(BuildContext context) {
    return Consumer<CartState>(
      builder: (context, cartState, child) {
        final itemCount = cartState.itemCount;

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
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: 6, end: 6),
              showBadge: itemCount > 0,
              badgeContent: Text(
                itemCount > 99 ? '99+' : itemCount.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: AppColors.cartBadge,
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// 简化版顶部栏（用于商品详情等页面）
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: centerTitle,
      leading: onBack != null
          ? IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios),
            )
          : null,
      title: Text(title, style: AppTextStyles.headline3),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(57); // 56 + 1 for divider
}

/// 搜索页面顶部栏
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? initialQuery;
  final Function(String)? onSearch;
  final VoidCallback? onBack;
  final List<String>? suggestions;

  const SearchAppBar({
    super.key,
    this.initialQuery,
    this.onSearch,
    this.onBack,
    this.suggestions,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();

    // 自动聚焦搜索框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

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
          height: widget.preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              // 返回按钮
              GestureDetector(
                onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // 搜索输入框
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: AppTextStyles.body2,
                    decoration: InputDecoration(
                      hintText: '搜索商品、品牌、店铺',
                      hintStyle: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onSubmitted: widget.onSearch,
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // 搜索按钮
              GestureDetector(
                onTap: () => widget.onSearch?.call(_controller.text),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    '搜索',
                    style: AppTextStyles.button.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
