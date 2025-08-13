/// 图片资源管理工具
class ImageAssets {
  // 占位图片（使用Data URI方式生成简单的占位图）
  static String placeholder({
    int width = 300,
    int height = 300,
    String color = '6C5CE7',
    String textColor = 'FFFFFF',
    String text = 'Product',
  }) {
    // 使用SVG Data URI生成简单的占位图
    final svgData =
        '''
<svg width="$width" height="$height" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#$color"/>
  <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" 
        fill="#$textColor" font-family="Arial, sans-serif" font-size="24">$text</text>
</svg>
    ''';

    // 转换为Data URI
    final base64Data = Uri.encodeComponent(svgData);
    return 'data:image/svg+xml,$base64Data';
  }

  // 商品类型对应的占位图片
  static Map<String, List<String>> get productImages => {
    'iphone_15': [
      placeholder(color: 'FF6B6B', text: 'iPhone 1'),
      placeholder(color: '4ECDC4', text: 'iPhone 2'),
      placeholder(color: '45B7D1', text: 'iPhone 3'),
      placeholder(color: '96CEB4', text: 'iPhone 4'),
      placeholder(color: 'FFEAA7', textColor: '000000', text: 'iPhone 5'),
    ],

    'macbook_pro': [
      placeholder(color: 'C0C0C0', textColor: '000000', text: 'MacBook 1'),
      placeholder(color: 'E8E8E8', textColor: '000000', text: 'MacBook 2'),
      placeholder(color: 'F5F5F5', textColor: '000000', text: 'MacBook 3'),
      placeholder(color: 'DCDCDC', textColor: '000000', text: 'MacBook 4'),
    ],

    'xiaomi_14': [
      placeholder(color: '333333', text: '小米14 1'),
      placeholder(color: '444444', text: '小米14 2'),
      placeholder(color: '555555', text: '小米14 3'),
      placeholder(color: '666666', text: '小米14 4'),
    ],

    'huawei_mate60': [
      placeholder(color: '2E7D47', text: '华为 1'),
      placeholder(color: '3A8B56', text: '华为 2'),
      placeholder(color: '469964', text: '华为 3'),
      placeholder(color: '52A672', text: '华为 4'),
    ],

    'default': [
      placeholder(color: '6C5CE7', text: '精选 1'),
      placeholder(color: 'A55EEA', text: '精选 2'),
      placeholder(color: 'D63031', text: '精选 3'),
      placeholder(color: 'FD79A8', text: '精选 4'),
    ],
  };

  // 获取产品主图
  static String getProductMainImage(String productId) {
    final images = getProductImages(productId);
    return images.isNotEmpty ? images.first : placeholder();
  }

  // 获取产品图片列表
  static List<String> getProductImages(String productId) {
    // 尝试精确匹配
    if (productImages.containsKey(productId)) {
      return productImages[productId]!;
    }

    // 模糊匹配
    for (String key in productImages.keys) {
      if (productId.toLowerCase().contains(key) ||
          key.contains(productId.toLowerCase())) {
        return productImages[key]!;
      }
    }

    // 返回默认图片
    return productImages['default']!;
  }

  // SKU图片
  static String getSkuImage(String color) {
    switch (color.toLowerCase()) {
      case '深空黑色':
      case '黑色':
        return placeholder(color: '000000', text: 'Black');
      case '银色':
        return placeholder(
          color: 'C0C0C0',
          textColor: '000000',
          text: 'Silver',
        );
      case '金色':
        return placeholder(color: 'FFD700', textColor: '000000', text: 'Gold');
      case '蓝色':
        return placeholder(color: '0000FF', text: 'Blue');
      case '红色':
        return placeholder(color: 'FF0000', text: 'Red');
      default:
        return placeholder(color: '808080', text: color);
    }
  }

  // 用户头像占位图
  static String getUserAvatar(String userName) {
    final colors = ['FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7'];
    final colorIndex = userName.hashCode % colors.length;
    final color = colors[colorIndex];
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return placeholder(width: 50, height: 50, color: color, text: initial);
  }
}
