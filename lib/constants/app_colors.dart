import 'package:flutter/material.dart';

/// 应用颜色规范 - Material Design 3
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFFFF9800);
  static const Color accent = Color(0xFFE91E63);

  // 背景色
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F7F7);

  // 状态色
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // 文字色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 分割线
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFEEEEEE);

  // 阴影
  static const Color shadow = Color(0x1A000000);

  // 渐变色
  static const Color primaryGradient1 = Color(0xFF42A5F5);
  static const Color primaryGradient2 = Color(0xFF1976D2);

  // 商城特有颜色
  static const Color price = Color(0xFFFF5722);
  static const Color originalPrice = Color(0xFF9E9E9E);
  static const Color discount = Color(0xFFFF5722);
  static const Color rating = Color(0xFFFFC107);
  static const Color cartBadge = Color(0xFFFF5722);

  // 营销色彩
  static const Color vipGold = Color(0xFFFFD700);
  static const Color limitedTime = Color(0xFFFF4081);
  static const Color newProduct = Color(0xFF4CAF50);
  static const Color hotSale = Color(0xFFFF5722);

  // 分类颜色
  static const List<Color> categoryColors = [
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E8),
    Color(0xFFFFF3E0),
    Color(0xFFFFEBEE),
    Color(0xFFF1F8E9),
    Color(0xFFFCE4EC),
    Color(0xFFE0F2F1),
  ];

  // 卡片背景色
  static const Color cardBackground = Color(0xFFFFFFFF);

  // 获取分类颜色
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }
}
