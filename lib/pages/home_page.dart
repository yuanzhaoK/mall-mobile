import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../constants/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../providers/home_state.dart';
import '../providers/cart_state.dart';
import '../widgets/simple_banner.dart';
import '../widgets/category_grid.dart';
import '../widgets/product_card.dart';
import '../widgets/simple_app_bar.dart';
import '../models/api_models.dart';
import 'debug_page.dart';

/// 商城首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    // 初始化加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeState>().loadHomeData();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SimpleCustomAppBar(
        onSearchTap: _handleSearchTap,
        onNotificationTap: _handleNotificationTap,
        onCartTap: _handleCartTap,
        onUserTap: _handleUserTap,
      ),
      body: Consumer<HomeState>(
        builder: (context, homeState, child) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: _onRefresh,
            header: const WaterDropMaterialHeader(
              backgroundColor: AppColors.primary,
              color: Colors.white,
            ),
            child: _buildBody(homeState),
          );
        },
      ),
      floatingActionButton: _buildDebugButton(),
    );
  }

  /// 构建主体内容
  Widget _buildBody(HomeState homeState) {
    if (homeState.isLoading && !homeState.hasData) {
      return _buildLoadingState();
    }

    if (homeState.error != null && !homeState.hasData) {
      return _buildErrorState(homeState);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),

          // 轮播图
          _buildBannerSection(homeState),

          const SizedBox(height: AppSpacing.lg),

          // 快捷入口
          _buildQuickEntrySection(),

          const SizedBox(height: AppSpacing.lg),

          // 分类导航
          _buildCategorySection(homeState),

          const SizedBox(height: AppSpacing.lg),

          // 营销板块
          _buildMarketingSection(),

          const SizedBox(height: AppSpacing.lg),

          // 推荐商品
          _buildRecommendationSection(homeState),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// 构建轮播图区域
  Widget _buildBannerSection(HomeState homeState) {
    return SimpleBanner(
      banners: homeState.banners,
      onBannerTap: _handleBannerTap,
    );
  }

  /// 构建快捷入口区域
  Widget _buildQuickEntrySection() {
    return QuickEntryGrid(
      entries: QuickEntry.defaultEntries,
      onEntryTap: _handleQuickEntryTap,
    );
  }

  /// 构建分类区域
  Widget _buildCategorySection(HomeState homeState) {
    return CategoryGrid(
      categories: homeState.categories,
      onCategoryTap: _handleCategoryTap,
      onViewAll: _handleViewAllCategories,
    );
  }

  /// 构建营销板块
  Widget _buildMarketingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('营销活动', style: AppTextStyles.headline3),
          const SizedBox(height: AppSpacing.md),

          // 营销卡片
          Row(
            children: [
              Expanded(
                child: _buildMarketingCard(
                  '限时优惠',
                  '低至3折起',
                  AppColors.limitedTime,
                  Icons.flash_on,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMarketingCard(
                  '会员专享',
                  '专属特权',
                  AppColors.vipGold,
                  Icons.diamond,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建营销卡片
  Widget _buildMarketingCard(
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建推荐商品区域
  Widget _buildRecommendationSection(HomeState homeState) {
    return Column(
      children: [
        // 热门商品
        _buildProductSection(
          '热门商品',
          homeState.featuredProducts,
          onViewAll: () => _handleViewAllProducts('featured'),
        ),

        const SizedBox(height: AppSpacing.lg),

        // 猜你喜欢
        _buildProductSection(
          '猜你喜欢',
          homeState.getRecommendationsByType('recommend'),
          onViewAll: () => _handleViewAllProducts('recommend'),
        ),
      ],
    );
  }

  /// 构建商品区域
  Widget _buildProductSection(
    String title,
    List<Product> products, {
    VoidCallback? onViewAll,
  }) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.headline3),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '查看更多',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                        ),
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
          ),

          const SizedBox(height: AppSpacing.md),

          // 商品网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: products.take(4).length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => _handleProductTap(product),
                onAddToCart: () => _handleAddToCart(product),
                onFavorite: () => _handleFavorite(product),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.md),
          Text('正在加载...', style: AppTextStyles.body2),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(HomeState homeState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.textLight),
            const SizedBox(height: AppSpacing.md),
            Text(
              '加载失败',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              homeState.error ?? '未知错误',
              style: AppTextStyles.body2.copyWith(color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => homeState.retry(),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建调试按钮
  Widget _buildDebugButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DebugPage()),
        );
      },
      backgroundColor: AppColors.secondary,
      child: const Icon(Icons.bug_report, color: Colors.white),
    );
  }

  // 事件处理方法

  /// 下拉刷新
  void _onRefresh() async {
    try {
      await context.read<HomeState>().refreshHomeData();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  /// 处理搜索点击
  void _handleSearchTap() {
    // TODO: 跳转到搜索页面
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('搜索功能开发中...')));
  }

  /// 处理通知点击
  void _handleNotificationTap() {
    // TODO: 跳转到通知页面
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('通知功能开发中...')));
  }

  /// 处理购物车点击
  void _handleCartTap() {
    // TODO: 跳转到购物车页面
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('购物车页面开发中...')));
  }

  /// 处理用户头像点击
  void _handleUserTap() {
    // TODO: 跳转到用户中心或登录页面
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('用户中心开发中...')));
  }

  /// 处理轮播图点击
  void _handleBannerTap(BannerItem banner) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('点击轮播图: ${banner.title}')));
  }

  /// 处理快捷入口点击
  void _handleQuickEntryTap(QuickEntry entry) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('点击快捷入口: ${entry.title}')));
  }

  /// 处理分类点击
  void _handleCategoryTap(Category category) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('点击分类: ${category.name}')));
  }

  /// 处理查看全部分类
  void _handleViewAllCategories() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('分类页面开发中...')));
  }

  /// 处理查看全部商品
  void _handleViewAllProducts(String type) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$type商品列表页面开发中...')));
  }

  /// 处理商品点击
  void _handleProductTap(Product product) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('点击商品: ${product.name}')));
  }

  /// 处理加购物车
  void _handleAddToCart(Product product) {
    // ProductCard内部已处理，这里可以添加额外逻辑
  }

  /// 处理收藏
  void _handleFavorite(Product product) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('收藏商品: ${product.name}')));
  }
}
