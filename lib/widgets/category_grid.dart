import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/api_models.dart';
import '../constants/app_colors.dart';
import '../core/themes/app_theme.dart';

/// 分类网格组件
class CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final int crossAxisCount;
  final double itemHeight;
  final Function(Category)? onCategoryTap;
  final VoidCallback? onViewAll;
  final bool showViewAll;
  final String title;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.crossAxisCount = 4,
    this.itemHeight = 80,
    this.onCategoryTap,
    this.onViewAll,
    this.showViewAll = true,
    this.title = '商品分类',
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          _buildHeader(),

          const SizedBox(height: AppSpacing.md),

          // 分类网格
          _buildGrid(),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headline3),
        if (showViewAll && onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '查看全部',
                  style: AppTextStyles.body2.copyWith(color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建网格
  Widget _buildGrid() {
    // 计算需要显示的分类数量
    final displayCategories = categories.take(crossAxisCount * 2).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: displayCategories.length,
      itemBuilder: (context, index) {
        final category = displayCategories[index];
        return _buildCategoryItem(category, index);
      },
    );
  }

  /// 构建单个分类项
  Widget _buildCategoryItem(Category category, int index) {
    return GestureDetector(
      onTap: () => onCategoryTap?.call(category),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCategoryColor(index),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 分类图标
            _buildCategoryIcon(category, index),

            const SizedBox(height: AppSpacing.xs),

            // 分类名称
            Text(
              category.name,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // 商品数量（可选）
            if (category.productCount > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${category.productCount}件',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建分类图标
  Widget _buildCategoryIcon(Category category, int index) {
    // 如果有网络图标URL
    if (category.iconUrl != null && category.iconUrl!.isNotEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: CachedNetworkImage(
            imageUrl: category.iconUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.white,
              child: Icon(
                _getDefaultIcon(category.name),
                size: 20,
                color: AppColors.primary,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.white,
              child: Icon(
                _getDefaultIcon(category.name),
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    }

    // 使用默认图标
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getDefaultIcon(category.name),
        size: 20,
        color: AppColors.primary,
      ),
    );
  }

  /// 根据分类名称获取默认图标
  IconData _getDefaultIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('服装') ||
        name.contains('衣服') ||
        name.contains('fashion')) {
      return Icons.checkroom;
    } else if (name.contains('数码') ||
        name.contains('电子') ||
        name.contains('手机')) {
      return Icons.smartphone;
    } else if (name.contains('家居') ||
        name.contains('家具') ||
        name.contains('home')) {
      return Icons.home;
    } else if (name.contains('美妆') ||
        name.contains('化妆') ||
        name.contains('beauty')) {
      return Icons.face_retouching_natural;
    } else if (name.contains('食品') ||
        name.contains('美食') ||
        name.contains('food')) {
      return Icons.restaurant;
    } else if (name.contains('运动') ||
        name.contains('健身') ||
        name.contains('sport')) {
      return Icons.fitness_center;
    } else if (name.contains('图书') ||
        name.contains('书籍') ||
        name.contains('book')) {
      return Icons.menu_book;
    } else if (name.contains('母婴') ||
        name.contains('儿童') ||
        name.contains('baby')) {
      return Icons.child_care;
    } else if (name.contains('汽车') ||
        name.contains('车辆') ||
        name.contains('car')) {
      return Icons.directions_car;
    } else if (name.contains('旅游') ||
        name.contains('旅行') ||
        name.contains('travel')) {
      return Icons.flight;
    } else {
      return Icons.category;
    }
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 48, color: AppColors.textLight),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '暂无分类数据',
            style: AppTextStyles.body2.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

/// 快捷入口组件（营销活动入口）
class QuickEntryGrid extends StatelessWidget {
  final List<QuickEntry> entries;
  final Function(QuickEntry)? onEntryTap;

  const QuickEntryGrid({super.key, required this.entries, this.onEntryTap});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('快捷入口', style: AppTextStyles.headline3),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: entries
                .map((entry) => Expanded(child: _buildQuickEntryItem(entry)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEntryItem(QuickEntry entry) {
    return GestureDetector(
      onTap: () => onEntryTap?.call(entry),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: entry.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: entry.gradientColors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(entry.icon, size: 32, color: Colors.white),
            const SizedBox(height: AppSpacing.xs),
            Text(
              entry.title,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (entry.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                entry.subtitle!,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 快捷入口数据模型
class QuickEntry {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String? linkUrl;

  QuickEntry({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.linkUrl,
  });

  // 预定义的快捷入口
  static List<QuickEntry> defaultEntries = [
    QuickEntry(
      id: 'flash_sale',
      title: '限时抢购',
      subtitle: '低至1折',
      icon: Icons.flash_on,
      gradientColors: [AppColors.limitedTime, Colors.pink],
    ),
    QuickEntry(
      id: 'coupon',
      title: '优惠券',
      subtitle: '免费领取',
      icon: Icons.card_giftcard,
      gradientColors: [AppColors.warning, Colors.orange],
    ),
    QuickEntry(
      id: 'vip',
      title: '会员专享',
      subtitle: '专属特权',
      icon: Icons.diamond,
      gradientColors: [AppColors.vipGold, Colors.amber],
    ),
    QuickEntry(
      id: 'points',
      title: '积分商城',
      subtitle: '好礼兑换',
      icon: Icons.stars,
      gradientColors: [AppColors.primary, Colors.blue],
    ),
  ];
}
