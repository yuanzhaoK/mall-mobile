import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/core/themes/app_theme.dart';
import 'package:flutter_home_mall/models/product_models.dart';
import 'package:flutter_home_mall/widgets/simple_app_bar.dart';
import 'package:flutter_home_mall/pages/product_detail_page.dart';

/// 我的收藏页面
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditMode = false;
  final Set<String> _selectedItems = {};

  // 模拟收藏数据
  final List<Product> _favoriteProducts = [
    Product(
      id: '1',
      name: 'iPhone 15 Pro Max',
      price: 9999,
      originalPrice: 10999,
      imageUrl: 'https://example.com/iphone.jpg',
      rating: 4.8,
      salesCount: 500,
    ),
    Product(
      id: '2',
      name: 'MacBook Pro 16英寸',
      price: 19999,
      originalPrice: 21999,
      imageUrl: 'https://example.com/macbook.jpg',
      rating: 4.9,
      salesCount: 200,
    ),
  ];

  final List<String> _favoriteStores = ['Apple官方旗舰店', '小米官方旗舰店', '华为官方旗舰店'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(
        title: '我的收藏',
        showBackButton: true,
        actions: [
          if (_tabController.index == 0)
            TextButton(
              onPressed: _toggleEditMode,
              child: Text(
                _isEditMode ? '完成' : '编辑',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Tab标签栏
          _buildTabBar(),

          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildProductsTab(), _buildStoresTab()],
            ),
          ),

          // 底部操作栏（编辑模式下显示）
          if (_isEditMode && _tabController.index == 0) _buildBottomActionBar(),
        ],
      ),
    );
  }

  /// 构建Tab标签栏
  Widget _buildTabBar() {
    return ColoredBox(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        onTap: (index) {
          if (_isEditMode) {
            _toggleEditMode();
          }
        },
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('商品'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_favoriteProducts.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('店铺'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_favoriteStores.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建商品收藏Tab
  Widget _buildProductsTab() {
    if (_favoriteProducts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: '还没有收藏的商品',
        subtitle: '快去收藏心仪的商品吧',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        return _buildProductCard(product, index);
      },
    );
  }

  /// 构建店铺收藏Tab
  Widget _buildStoresTab() {
    if (_favoriteStores.isEmpty) {
      return _buildEmptyState(
        icon: Icons.store_outlined,
        title: '还没有收藏的店铺',
        subtitle: '收藏优质店铺，及时获取优惠信息',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteStores.length,
      itemBuilder: (context, index) {
        final storeName = _favoriteStores[index];
        return _buildStoreCard(storeName, index);
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // 跳转到商城页面
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            child: const Text('去逛逛'),
          ),
        ],
      ),
    );
  }

  /// 构建商品卡片
  Widget _buildProductCard(Product product, int index) {
    final isSelected = _selectedItems.contains(product.id);

    return GestureDetector(
      onTap: _isEditMode
          ? () => _toggleSelection(product.id)
          : () => _navigateToProductDetail(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: _isEditMode && isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 选择框（编辑模式）
              if (_isEditMode) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleSelection(product.id),
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
              ],

              // 商品图片
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image_not_supported),
                  ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '精选商品，品质保证',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '¥${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.originalPrice != null &&
                            product.originalPrice! > product.price)
                          Text(
                            '¥${product.originalPrice!.toStringAsFixed(0)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // 操作按钮
              if (!_isEditMode)
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _removeFromFavorites(index),
                      icon: const Icon(
                        Icons.favorite,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 60,
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () => _addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: const Text('加购', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建店铺卡片
  Widget _buildStoreCard(String storeName, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 店铺头像
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.store,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // 店铺信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '粉丝 12.8万',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 操作按钮
            Row(
              children: [
                IconButton(
                  onPressed: () => _removeStoreFromFavorites(index),
                  icon: const Icon(
                    Icons.favorite,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () => _visitStore(storeName),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      '进店',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
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

  /// 构建底部操作栏
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 全选
            Row(
              children: [
                Checkbox(
                  value: _selectedItems.length == _favoriteProducts.length,
                  onChanged: _toggleSelectAll,
                  activeColor: AppColors.primary,
                ),
                const Text('全选'),
              ],
            ),
            const Spacer(),

            // 删除按钮
            ElevatedButton(
              onPressed: _selectedItems.isEmpty ? null : _deleteSelected,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('删除 (${_selectedItems.length})'),
            ),
          ],
        ),
      ),
    );
  }

  /// 切换编辑模式
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        _selectedItems.clear();
      }
    });
  }

  /// 切换选择状态
  void _toggleSelection(String productId) {
    setState(() {
      if (_selectedItems.contains(productId)) {
        _selectedItems.remove(productId);
      } else {
        _selectedItems.add(productId);
      }
    });
  }

  /// 全选/取消全选
  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedItems.addAll(_favoriteProducts.map((p) => p.id));
      } else {
        _selectedItems.clear();
      }
    });
  }

  /// 删除选中的商品
  void _deleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除收藏'),
        content: Text('确定要删除选中的 ${_selectedItems.length} 个商品吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _favoriteProducts.removeWhere(
                  (product) => _selectedItems.contains(product.id),
                );
                _selectedItems.clear();
                _isEditMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已删除选中的商品'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  /// 移除单个商品收藏
  void _removeFromFavorites(int index) {
    setState(() {
      _favoriteProducts.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已取消收藏'), backgroundColor: Colors.orange),
    );
  }

  /// 移除店铺收藏
  void _removeStoreFromFavorites(int index) {
    setState(() {
      _favoriteStores.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已取消关注'), backgroundColor: Colors.orange),
    );
  }

  /// 添加到购物车
  void _addToCart(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} 已加入购物车'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 跳转到商品详情
  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  /// 访问店铺
  void _visitStore(String storeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('进入 $storeName'), backgroundColor: Colors.blue),
    );
  }
}
