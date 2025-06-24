import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/api_models.dart';
import '../constants/app_colors.dart';
import '../core/themes/app_theme.dart';

/// 简化版轮播图组件
class SimpleBanner extends StatefulWidget {
  final List<BannerItem> banners;
  final Duration autoPlayInterval;
  final bool autoPlay;
  final double height;
  final Function(BannerItem)? onBannerTap;

  const SimpleBanner({
    super.key,
    required this.banners,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlay = true,
    this.height = 180,
    this.onBannerTap,
  });

  @override
  State<SimpleBanner> createState() => _SimpleBannerState();
}

class _SimpleBannerState extends State<SimpleBanner> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoPlay && widget.banners.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (mounted && widget.banners.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

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
          _buildPageView(),

          // 指示器
          if (widget.banners.length > 1) _buildIndicators(),
        ],
      ),
    );
  }

  /// 构建PageView
  Widget _buildPageView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.banners.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final banner = widget.banners[index];
          return _buildBannerItem(banner);
        },
      ),
    );
  }

  /// 构建单个轮播项
  Widget _buildBannerItem(BannerItem banner) {
    return GestureDetector(
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
              placeholder: (context, url) => Container(
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceVariant,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
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

            // 渐变遮罩
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
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
                        color: Colors.black.withOpacity(0.5),
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
  }

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
            onTap: () => _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

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
          Icon(Icons.image_outlined, size: 48, color: AppColors.textLight),
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
