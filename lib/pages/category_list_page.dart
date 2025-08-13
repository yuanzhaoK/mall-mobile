import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/core/themes/app_theme.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/providers/home_state.dart';
import 'package:flutter_home_mall/widgets/category_grid.dart';
import 'package:flutter_home_mall/widgets/simple_app_bar.dart';
import 'package:provider/provider.dart';

/// 分类列表页面 - 展示所有商品分类
class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  List<Category> _getFilteredCategories(List<Category> allCategories) {
    if (_searchQuery.isEmpty) {
      return allCategories;
    }

    return allCategories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SimpleAppBar(title: '商品分类', showBackButton: true),
      body: Consumer<HomeState>(
        builder: (context, homeState, child) {
          final allCategories = homeState.categories;
          final filteredCategories = _getFilteredCategories(allCategories);

          return Column(
            children: [
              // 搜索栏
              _buildSearchBar(),

              // 分类统计信息
              _buildCategoryStats(allCategories, filteredCategories),

              // 分类列表
              Expanded(child: _buildCategoryList(filteredCategories)),
            ],
          );
        },
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索分类...',
          hintStyle: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  /// 构建分类统计信息
  Widget _buildCategoryStats(
    List<Category> allCategories,
    List<Category> filteredCategories,
  ) {
    final totalProducts = allCategories.fold<int>(
      0,
      (sum, category) => sum + category.productCount,
    );

    final filteredProducts = filteredCategories.fold<int>(
      0,
      (sum, category) => sum + category.productCount,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            '分类总数',
            _searchQuery.isEmpty
                ? '${allCategories.length}'
                : '${filteredCategories.length}/${allCategories.length}',
            Icons.category,
          ),
          const SizedBox(width: AppSpacing.lg),
          _buildStatItem(
            '商品总数',
            _searchQuery.isEmpty
                ? '$totalProducts'
                : '$filteredProducts/$totalProducts',
            Icons.inventory_2,
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建分类列表
  Widget _buildCategoryList(List<Category> categories) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),

          // 使用CategoryGrid组件显示所有分类
          CategoryGrid(
            categories: categories,
            crossAxisCount: 3, // 3列布局
            showViewAll: false, // 不显示查看全部按钮
            title: '',
            onCategoryTap: _handleCategoryTap,
          ),

          const SizedBox(height: AppSpacing.md),

          // 列表视图选项
          _buildListViewToggle(categories),
        ],
      ),
    );
  }

  /// 构建列表视图切换
  Widget _buildListViewToggle(List<Category> categories) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('列表视图', style: AppTextStyles.headline3),
              const Spacer(),
              Icon(Icons.list, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 分类列表
          ...categories.map((category) => _buildListItem(category)),
        ],
      ),
    );
  }

  /// 构建列表项
  Widget _buildListItem(Category category) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: 1,
        child: InkWell(
          onTap: () => _handleCategoryTap(category),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // 分类图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    _getCategoryIcon(category.name),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // 分类信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.productCount} 件商品',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // 箭头图标
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.category_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _searchQuery.isNotEmpty ? '没有找到相关分类' : '暂无分类数据',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '尝试使用其他关键词搜索',
              style: AppTextStyles.body2.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                _searchController.clear();
              },
              child: const Text('清除搜索条件'),
            ),
          ],
        ],
      ),
    );
  }

  /// 根据分类名称获取图标
  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('服装') || name.contains('衣服')) {
      return Icons.checkroom;
    } else if (name.contains('数码') || name.contains('电子')) {
      return Icons.smartphone;
    } else if (name.contains('家居') || name.contains('家具')) {
      return Icons.home;
    } else if (name.contains('美妆') || name.contains('化妆')) {
      return Icons.face_retouching_natural;
    } else if (name.contains('食品') || name.contains('美食')) {
      return Icons.restaurant;
    } else if (name.contains('运动') || name.contains('健身')) {
      return Icons.fitness_center;
    } else if (name.contains('图书') || name.contains('书籍')) {
      return Icons.menu_book;
    } else if (name.contains('母婴') || name.contains('儿童')) {
      return Icons.child_care;
    } else if (name.contains('汽车') || name.contains('车辆')) {
      return Icons.directions_car;
    } else if (name.contains('旅游') || name.contains('旅行')) {
      return Icons.flight;
    } else {
      return Icons.category;
    }
  }

  /// 处理分类点击
  void _handleCategoryTap(Category category) {
    // TODO: 导航到分类商品页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('进入"${category.name}"分类 (${category.productCount}件商品)'),
        action: SnackBarAction(label: '确定', onPressed: () {}),
      ),
    );
  }
}
