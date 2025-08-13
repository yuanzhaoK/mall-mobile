import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/constants/app_strings.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/pages/product_detail_page.dart';
import 'package:flutter_home_mall/providers/cart_state.dart';
import 'package:flutter_home_mall/providers/mall_state.dart';
import 'package:flutter_home_mall/services/analytics_service.dart';
import 'package:flutter_home_mall/widgets/mall_filter_sheet.dart';
import 'package:flutter_home_mall/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 商场页面
class MallPage extends StatefulWidget {
  const MallPage({super.key});

  @override
  State<MallPage> createState() => _MallPageState();
}

class _MallPageState extends State<MallPage> {
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MallState>().initialize();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<MallState>(
        builder: (context, mallState, child) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullUp: mallState.hasMore,
            onRefresh: () => _onRefresh(mallState),
            onLoading: () => _onLoading(mallState),
            child: _buildBody(mallState),
          );
        },
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(AppStrings.tabMall),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: _buildSearchBar(),
        ),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: '搜索商品',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onSubmitted: _performSearch,
      ),
    );
  }

  /// 构建主体内容
  Widget _buildBody(MallState mallState) {
    if (mallState.isLoading && !mallState.hasData) {
      return _buildLoadingState();
    }

    if (mallState.error != null && !mallState.hasData) {
      return _buildErrorState(mallState);
    }

    return Column(
      children: [
        // 筛选和排序栏
        _buildFilterBar(mallState),

        // 商品列表
        Expanded(
          child: mallState.isEmpty
              ? _buildEmptyState()
              : _buildProductList(mallState),
        ),
      ],
    );
  }

  /// 构建筛选栏
  Widget _buildFilterBar(MallState mallState) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 筛选条件显示
          Expanded(
            child: mallState.hasActiveFilters
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mallState.filtersDescription,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    '共${mallState.products.length}件商品',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
          ),

          // 筛选按钮
          GestureDetector(
            onTap: () => _showFilterSheet(mallState),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: mallState.hasActiveFilters
                        ? AppColors.primary
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '筛选',
                    style: TextStyle(
                      fontSize: 12,
                      color: mallState.hasActiveFilters
                          ? AppColors.primary
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 视图切换按钮
          GestureDetector(
            onTap: () => mallState.toggleViewMode(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                mallState.isGridView ? Icons.view_list : Icons.grid_view,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建商品列表
  Widget _buildProductList(MallState mallState) {
    if (mallState.isGridView) {
      return _buildGridView(mallState);
    } else {
      return _buildListView(mallState);
    }
  }

  /// 构建网格视图
  Widget _buildGridView(MallState mallState) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: mallState.products.length + (mallState.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= mallState.products.length) {
          return _buildLoadingItem();
        }

        final product = mallState.products[index];
        return ProductCard(
          product: product,
          onTap: () => _handleProductTap(product),
          onAddToCart: () => _handleAddToCart(product),
          onFavorite: () => _handleFavorite(product),
        );
      },
    );
  }

  /// 构建列表视图
  Widget _buildListView(MallState mallState) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mallState.products.length + (mallState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= mallState.products.length) {
          return _buildLoadingItem();
        }

        final product = mallState.products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildListProductCard(product),
        );
      },
    );
  }

  /// 构建列表样式的商品卡片
  Widget _buildListProductCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),

          const SizedBox(width: 12),

          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // 价格和评分
                Row(
                  children: [
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        product.formattedOriginalPrice,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < product.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          size: 12,
                          color: Colors.amber,
                        );
                      }),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '已售${product.salesCount}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 操作按钮
          Column(
            children: [
              IconButton(
                onPressed: () => _handleFavorite(product),
                icon: const Icon(Icons.favorite_border, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: () => _handleAddToCart(product),
                icon: const Icon(
                  Icons.add_shopping_cart,
                  size: 20,
                  color: AppColors.primary,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建加载项
  Widget _buildLoadingItem() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  /// 构建错误状态
  Widget _buildErrorState(MallState mallState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            mallState.error ?? '加载失败',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => mallState.refresh(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('暂无商品', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '试试调整筛选条件',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// 下拉刷新
  Future<void> _onRefresh(MallState mallState) async {
    await mallState.refresh();
    _refreshController.refreshCompleted();
  }

  /// 上拉加载
  Future<void> _onLoading(MallState mallState) async {
    await mallState.loadMore();
    if (mallState.hasMore) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  /// 执行搜索
  void _performSearch(String query) {
    final mallState = context.read<MallState>()
      ..setFilters(searchKeyword: query.trim());
    debugPrint(mallState.filtersDescription);
  }

  /// 显示筛选面板
  void _showFilterSheet(MallState mallState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MallFilterSheet(mallState: mallState),
    );
  }

  /// 处理商品点击
  void _handleProductTap(Product product) {
    // 跟踪商品点击事件
    AnalyticsService.trackProductTap(
      product: product,
      source: 'mall',
      extra: {
        'category': context.read<MallState>().selectedCategory,
        'sort_type': context.read<MallState>().sortBy,
        'view_type': context.read<MallState>().isGridView ? 'grid' : 'list',
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  /// 处理加购物车
  void _handleAddToCart(Product product) {
    final cartState = context.read<CartState>()..addToCart(product);
    debugPrint(cartState.discountText);
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

  /// 处理收藏
  void _handleFavorite(Product product) {
    // TODO: 实现收藏功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已收藏 ${product.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
