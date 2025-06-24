import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/api_models.dart';

class FeaturedProductCard extends StatelessWidget {
  final Product product;

  const FeaturedProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 产品图标或占位符
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryGradient1.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getProductIcon(),
              color: AppColors.primaryGradient1,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),

          // 产品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.isEmpty ? '未命名产品' : product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.formattedPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGradient1,
                  ),
                ),
              ],
            ),
          ),

          // 购买按钮
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGradient1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '查看',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 根据产品名称返回相应图标
  IconData _getProductIcon() {
    final name = product.name.toLowerCase();

    if (name.contains('手机') || name.contains('iphone') || name.contains('小米')) {
      return Icons.phone_android;
    } else if (name.contains('电脑') ||
        name.contains('macbook') ||
        name.contains('笔记本')) {
      return Icons.laptop;
    } else if (name.contains('耳机') || name.contains('airpods')) {
      return Icons.headphones;
    } else if (name.contains('书') || name.contains('图书')) {
      return Icons.book;
    } else if (name.contains('咖啡') || name.contains('星巴克')) {
      return Icons.local_cafe;
    } else if (name.contains('化妆') ||
        name.contains('护肤') ||
        name.contains('兰蔻') ||
        name.contains('sk-ii')) {
      return Icons.face_retouching_natural;
    } else if (name.contains('鞋') ||
        name.contains('nike') ||
        name.contains('adidas')) {
      return Icons.directions_run;
    } else if (name.contains('服装') ||
        name.contains('衣服') ||
        name.contains('uniqlo')) {
      return Icons.checkroom;
    } else if (name.contains('家具') ||
        name.contains('沙发') ||
        name.contains('冰箱') ||
        name.contains('宜家')) {
      return Icons.home;
    } else if (name.contains('食品') ||
        name.contains('零食') ||
        name.contains('松鼠')) {
      return Icons.restaurant;
    } else if (name.contains('饮料') ||
        name.contains('水') ||
        name.contains('元气森林')) {
      return Icons.local_drink;
    } else if (name.contains('汽车') || name.contains('tesla')) {
      return Icons.directions_car;
    } else {
      return Icons.shopping_bag;
    }
  }
}
