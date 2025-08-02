import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/core/themes/app_theme.dart';
import 'package:flutter_home_mall/models/api_models.dart';

/// 首页轮播图组件
class HomeBanner extends StatefulWidget {
  const HomeBanner({
    super.key,
    required this.banners,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlay = true,
    this.height = 180,
    this.onBannerTap,
  });
  final List<BannerItem> banners;
  final Duration autoPlayInterval;
  final bool autoPlay;
  final double height;
  final Function(BannerItem)? onBannerTap;

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _currentIndex = 0;
  final carousel.CarouselController _carouselController =
      carousel.CarouselController();

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Stack(
        children: [
          // 轮播图主体
          _buildCarousel(),

          // 指示器
          if (widget.banners.length > 1) _buildIndicators(),

          // 左右切换按钮（可选）
          if (widget.banners.length > 1) _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// 构建轮播图主体
  Widget _buildCarousel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: carousel.CarouselSlider.builder(
        carouselController: _carouselController,
        itemCount: widget.banners.length,
        itemBuilder: (context, index, realIndex) {
          final banner = widget.banners[index];
          return _buildBannerItem(banner);
        },
        options: carousel.CarouselOptions(
          height: widget.height,
          viewportFraction: 1,
          autoPlay: widget.autoPlay && widget.banners.length > 1,
          autoPlayInterval: widget.autoPlayInterval,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  /// 构建单个轮播项
  Widget _buildBannerItem(BannerItem banner) => GestureDetector(
    onTap: () => widget.onBannerTap?.call(banner),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景图片
          CachedNetworkImage(
            imageUrl: banner.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const ColoredBox(
              color: AppColors.surfaceVariant,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => ColoredBox(
              color: AppColors.surfaceVariant,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '图片加载失败',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 渐变遮罩（增强文字可读性）
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),

          // 标题文字
          if (banner.title.isNotEmpty)
            Positioned(
              bottom: AppSpacing.lg,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Text(
                banner.title,
                style: AppTextStyles.headline3.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // 类型标签
          if (banner.type.isNotEmpty)
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getTypeColor(banner.type),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  _getTypeLabel(banner.type),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  /// 构建指示器
  Widget _buildIndicators() {
    return Positioned(
      bottom: AppSpacing.md,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.banners.asMap().entries.map((entry) {
          final index = entry.key;
          final isSelected = index == _currentIndex;

          return GestureDetector(
            onTap: () => _carouselController.animateToPage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建导航按钮
  Widget _buildNavigationButtons() => Positioned.fill(
    child: Row(
      children: [
        // 左箭头
        Expanded(
          child: GestureDetector(
            onTap: _carouselController.previousPage,
            child: const ColoredBox(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),

        // 右箭头
        Expanded(
          child: GestureDetector(
            onTap: _carouselController.nextPage,
            child: const ColoredBox(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '暂无轮播图',
            style: AppTextStyles.body2.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }

  /// 获取类型颜色
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'promotion':
      case '促销':
        return AppColors.hotSale;
      case 'new':
      case '新品':
        return AppColors.newProduct;
      case 'vip':
      case '会员':
        return AppColors.vipGold;
      case 'limited':
      case '限时':
        return AppColors.limitedTime;
      default:
        return AppColors.primary;
    }
  }

  /// 获取类型标签
  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'promotion':
        return '促销';
      case 'new':
        return '新品';
      case 'vip':
        return '会员';
      case 'limited':
        return '限时';
      default:
        return type;
    }
  }
}
