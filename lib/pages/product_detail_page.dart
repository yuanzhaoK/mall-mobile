import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/providers/cart_state.dart';
import 'package:flutter_home_mall/providers/product_detail_state.dart';
import 'package:provider/provider.dart';

/// 商品详情页面
class ProductDetailPage extends StatefulWidget {
  // 可选的商品预览数据

  const ProductDetailPage({super.key, required this.productId, this.product});
  final String productId;
  final Product? product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 监听滚动位置
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showButton = _scrollController.offset > 200;
    if (showButton != _showFloatingButton) {
      setState(() {
        _showFloatingButton = showButton;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductDetailState()..loadProductDetail(widget.productId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<ProductDetailState>(
          builder: (context, state, child) {
            if (state.isLoading) {
              return _buildLoadingView();
            }

            if (state.error != null) {
              return _buildErrorView(state.error!);
            }

            if (!state.hasData) {
              return _buildEmptyView();
            }

            return _buildDetailView(state);
          },
        ),
        bottomNavigationBar: Consumer<ProductDetailState>(
          builder: (context, state, child) {
            if (!state.hasData) return const SizedBox.shrink();
            return _buildBottomBar(state);
          },
        ),
        floatingActionButton: _showFloatingButton
            ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.keyboard_arrow_up),
              )
            : null,
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('加载商品详情中...'),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ProductDetailState>().loadProductDetail(
                widget.productId,
              );
            },
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('商品不存在', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDetailView(ProductDetailState state) {
    final detail = state.productDetail!;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 自定义AppBar和图片轮播
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageGallery(detail.images, state),
          ),
          actions: [
            IconButton(
              onPressed: () => _handleShare(state.productDetail!),
              icon: const Icon(Icons.share_outlined),
            ),
            IconButton(
              onPressed: () {
                context.read<ProductDetailState>().toggleWishlist();
              },
              icon: Icon(
                detail.isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: detail.isInWishlist ? Colors.red : null,
              ),
            ),
          ],
        ),

        // 商品信息区域
        SliverToBoxAdapter(child: _buildProductInfo(detail, state)),

        // 服务保障
        SliverToBoxAdapter(child: _buildServiceSection(detail.service)),

        // 店铺信息
        SliverToBoxAdapter(child: _buildShopSection(detail)),

        // 标签页内容
        SliverToBoxAdapter(child: _buildTabSection(detail)),

        // 底部空白区域
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildImageGallery(List<String> images, ProductDetailState state) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            context.read<ProductDetailState>().setCurrentImageIndex(index);
          },
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),

        // 图片指示器
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${state.currentImageIndex + 1}/${images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo(ProductDetail detail, ProductDetailState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价格信息
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${state.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              if (state.hasDiscount) ...[
                const SizedBox(width: 8),
                Text(
                  '¥${state.currentOriginalPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${state.discountPercentage!.toStringAsFixed(0)}%OFF',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // 商品标题
          Text(
            detail.product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // 商品信息行
          Row(
            children: [
              // 评分
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.orange[400]),
                  const SizedBox(width: 4),
                  Text(
                    detail.product.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // 销量
              Text(
                '已售${detail.product.salesCount}件',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

              const Spacer(),

              // 库存状态
              Text(
                detail.stockText,
                style: TextStyle(
                  fontSize: 14,
                  color: detail.hasStock ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 品牌和分类
          Row(
            children: [
              _buildInfoChip('品牌', detail.brand),
              const SizedBox(width: 12),
              _buildInfoChip('分类', detail.category),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$label: $value', style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildServiceSection(ProductService service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '服务保障',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: service.serviceList.map((serviceItem) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      serviceItem,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShopSection(ProductDetail detail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 店铺图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.store, color: AppColors.primary, size: 24),
          ),

          const SizedBox(width: 12),

          // 店铺信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.shopName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.orange[400]),
                    const SizedBox(width: 4),
                    Text(
                      detail.shopRating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '店铺评分',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 进入店铺按钮
          OutlinedButton(
            onPressed: () {
              _handleShopNavigation(detail);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
            child: const Text('进店看看'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(ProductDetail detail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标签页头部
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: '商品详情'),
              Tab(text: '规格参数'),
              Tab(text: '用户评价'),
            ],
          ),

          // 标签页内容
          SizedBox(
            height: 400, // 固定高度
            child: TabBarView(
              controller: _tabController,
              children: [
                // 商品详情
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    detail.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // 规格参数
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: detail.specifications.map((spec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                spec.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                spec.displayValue,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // 用户评价
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 评价统计
                      Row(
                        children: [
                          Text(
                            detail.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < detail.averageRating.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 16,
                                    color: Colors.orange,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '共${detail.reviews.length}条评价',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 评价列表
                      ...detail.reviews.map((review) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 用户信息和评分
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: review.userAvatar != null
                                        ? CachedNetworkImageProvider(
                                            review.userAvatar!,
                                          )
                                        : null,
                                    child: review.userAvatar == null
                                        ? Text(
                                            review.displayUserName[0],
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.displayUserName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            ...List.generate(5, (index) {
                                              return Icon(
                                                index < review.rating.floor()
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 12,
                                                color: Colors.orange,
                                              );
                                            }),
                                            const SizedBox(width: 8),
                                            Text(
                                              review.formattedDate,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // 评价内容
                              Text(
                                review.content,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),

                              // SKU信息
                              if (review.skuInfo != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    review.skuInfo!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],

                              // 评价图片
                              if (review.images.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: review.images.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: review.images[index],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ProductDetailState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 客服按钮
            _buildActionButton(
              icon: Icons.chat_bubble_outline,
              label: '客服',
              onTap: () => _handleCustomerService(),
            ),

            const SizedBox(width: 12),

            // 收藏按钮
            _buildActionButton(
              icon: state.productDetail!.isInWishlist
                  ? Icons.favorite
                  : Icons.favorite_border,
              label: '收藏',
              color: state.productDetail!.isInWishlist ? Colors.red : null,
              onTap: () {
                context.read<ProductDetailState>().toggleWishlist();
              },
            ),

            const SizedBox(width: 16),

            // 加入购物车按钮
            Expanded(
              child: ElevatedButton(
                onPressed: state.canAddToCart
                    ? () => _showSkuSelector(state)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '加入购物车',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 立即购买按钮
            Expanded(
              child: ElevatedButton(
                onPressed: state.canAddToCart
                    ? () => _showSkuSelector(state, isBuyNow: true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '立即购买',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color ?? Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color ?? Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showSkuSelector(ProductDetailState state, {bool isBuyNow = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSkuSelector(state, isBuyNow),
    );
  }

  Widget _buildSkuSelector(ProductDetailState state, bool isBuyNow) {
    final detail = state.productDetail!;
    final availableAttributes = state.getAvailableAttributes();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                // 商品图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl:
                        state.selectedSku?.image ?? detail.product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 12),

                // 价格和库存
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¥${state.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '库存${state.currentStock}件',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (state.selectedSku != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '已选择: ${state.selectedSku!.name}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 关闭按钮
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 属性选择
                  ...availableAttributes.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.value.map((value) {
                            final isSelected =
                                state.selectedAttributes[entry.key] == value;
                            final isAvailable = state
                                .isAttributeCombinationAvailable(
                                  entry.key,
                                  value,
                                );

                            return GestureDetector(
                              onTap: isAvailable
                                  ? () {
                                      context
                                          .read<ProductDetailState>()
                                          .selectAttribute(entry.key, value);
                                    }
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : isAvailable
                                      ? Colors.white
                                      : Colors.grey[100],
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : isAvailable
                                        ? Colors.grey[300]!
                                        : Colors.grey[200]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : isAvailable
                                        ? Colors.black87
                                        : Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  // 数量选择
                  Row(
                    children: [
                      const Text(
                        '数量',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: state.quantity > 1
                                ? () {
                                    context
                                        .read<ProductDetailState>()
                                        .decreaseQuantity();
                                  }
                                : null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: state.quantity > 1
                                    ? Colors.black87
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                            ),
                            child: Text(
                              state.quantity.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          GestureDetector(
                            onTap: state.quantity < state.currentStock
                                ? () {
                                    context
                                        .read<ProductDetailState>()
                                        .increaseQuantity();
                                  }
                                : null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: state.quantity < state.currentStock
                                    ? Colors.black87
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 底部按钮
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.canAddToCart
                      ? () {
                          Navigator.pop(context);
                          if (isBuyNow) {
                            _buyNow(state);
                          } else {
                            _addToCart(state);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBuyNow
                        ? AppColors.primary
                        : AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isBuyNow ? '立即购买' : '确定',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(ProductDetailState state) {
    if (state.selectedSku == null) return;

    // 使用addToCart方法添加商品到购物车
    context.read<CartState>().addToCart(
      state.productDetail!.product,
      quantity: state.quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已添加到购物车'), duration: Duration(seconds: 2)),
    );
  }

  void _buyNow(ProductDetailState state) {
    _handleBuyNow(state);
  }

  /// 处理商品分享
  void _handleShare(ProductDetail detail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShareSheet(detail),
    );
  }

  /// 构建分享面板
  Widget _buildShareSheet(ProductDetail detail) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 商品信息预览
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: detail.images.isNotEmpty
                        ? detail.images.first
                        : '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥${detail.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.price,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // 分享选项
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '分享到',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareOption(
                      icon: Icons.wechat,
                      label: '微信',
                      color: Colors.green,
                      onTap: () => _shareToWeChat(detail),
                    ),
                    _buildShareOption(
                      icon: Icons.chat_bubble,
                      label: '朋友圈',
                      color: Colors.blue,
                      onTap: () => _shareToMoments(detail),
                    ),
                    _buildShareOption(
                      icon: Icons.link,
                      label: '复制链接',
                      color: Colors.orange,
                      onTap: () => _copyLink(detail),
                    ),
                    _buildShareOption(
                      icon: Icons.more_horiz,
                      label: '更多',
                      color: Colors.grey,
                      onTap: () => _shareMore(detail),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建分享选项
  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  /// 分享到微信
  void _shareToWeChat(ProductDetail detail) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('微信分享功能需要集成微信SDK')));
  }

  /// 分享到朋友圈
  void _shareToMoments(ProductDetail detail) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('朋友圈分享功能需要集成微信SDK')));
  }

  /// 复制链接
  void _copyLink(ProductDetail detail) {
    Navigator.pop(context);
    // TODO: 实现复制到剪贴板
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('商品链接已复制到剪贴板')));
  }

  /// 更多分享选项
  void _shareMore(ProductDetail detail) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('更多分享选项')));
  }

  /// 处理客服功能
  void _handleCustomerService() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCustomerServiceSheet(),
    );
  }

  /// 构建客服服务面板
  Widget _buildCustomerServiceSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '联系客服',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          const Divider(),

          // 客服选项
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildServiceOption(
                  icon: Icons.chat,
                  title: '在线客服',
                  subtitle: '工作时间: 9:00-21:00',
                  onTap: () => _openOnlineChat(),
                ),
                const SizedBox(height: 16),
                _buildServiceOption(
                  icon: Icons.phone,
                  title: '客服热线',
                  subtitle: '400-123-4567',
                  onTap: () => _callCustomerService(),
                ),
                const SizedBox(height: 16),
                _buildServiceOption(
                  icon: Icons.help_outline,
                  title: '常见问题',
                  subtitle: '查看帮助文档',
                  onTap: () => _openFAQ(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 构建服务选项
  Widget _buildServiceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// 打开在线客服
  void _openOnlineChat() {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('在线客服功能开发中')));
  }

  /// 拨打客服电话
  void _callCustomerService() {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('拨打客服电话: 400-123-4567')));
  }

  /// 打开常见问题
  void _openFAQ() {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('常见问题页面开发中')));
  }

  /// 处理立即购买
  void _handleBuyNow(ProductDetailState state) {
    if (!state.canAddToCart) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择商品规格')));
      return;
    }

    // 显示购买确认对话框
    showDialog(
      context: context,
      builder: (context) => _buildBuyNowDialog(state),
    );
  }

  /// 构建立即购买对话框
  Widget _buildBuyNowDialog(ProductDetailState state) {
    final detail = state.productDetail!;
    final selectedSku = state.selectedSku;
    final quantity = state.quantity;
    final totalPrice = (selectedSku?.price ?? detail.product.price) * quantity;

    return AlertDialog(
      title: const Text('确认购买'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('商品: ${detail.product.name}'),
          if (selectedSku != null) ...[
            const SizedBox(height: 8),
            Text('规格: ${selectedSku.name}'),
          ],
          const SizedBox(height: 8),
          Text('数量: $quantity'),
          const SizedBox(height: 8),
          Text(
            '总价: ¥${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.price,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => _confirmBuyNow(state),
          child: const Text('确认购买'),
        ),
      ],
    );
  }

  /// 确认立即购买
  void _confirmBuyNow(ProductDetailState state) {
    Navigator.pop(context);

    // TODO: 实现跳转到结算页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在跳转到结算页面...'),
        duration: Duration(seconds: 2),
      ),
    );

    // 模拟跳转到订单确认页面
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => OrderConfirmPage(
    //       products: [/* 商品信息 */],
    //     ),
    //   ),
    // );
  }

  /// 处理店铺导航
  void _handleShopNavigation(ProductDetail detail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShopInfoSheet(detail),
    );
  }

  /// 构建店铺信息面板
  Widget _buildShopInfoSheet(ProductDetail detail) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 店铺信息
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // 店铺头像
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 店铺信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.shopName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${detail.shopRating.toStringAsFixed(1)}分',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 操作按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _followShop(detail),
                        child: const Text('关注店铺'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _enterShop(detail),
                        child: const Text('进入店铺'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 关注店铺
  void _followShop(ProductDetail detail) {
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已关注 ${detail.shopName}')));
  }

  /// 进入店铺
  void _enterShop(ProductDetail detail) {
    Navigator.pop(context);
    // TODO: 导航到店铺页面
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('正在进入 ${detail.shopName}...')));
  }
}
