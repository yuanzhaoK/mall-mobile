## 项目简介

这是一个基于Flutter和GraphQL开发的现代化商城移动应用，专注于为用户提供优质的产品和完整的购物体验。应用采用现代化的UI设计、GraphQL API集成和响应式状态管理，提供流畅直观的用户体验。

## 项目结构

```
lib/
├── main.dart                        # 应用入口文件
├── config/                          # 配置文件
│   └── api_config.dart             # API配置
├── constants/                       # 常量定义
│   ├── app_colors.dart             # 颜色常量
│   └── app_strings.dart            # 字符串常量
├── core/                           # 核心功能
│   └── themes/
│       └── app_theme.dart          # 应用主题
├── models/                          # 数据模型
│   └── api_models.dart             # GraphQL API数据模型
├── pages/                           # 页面文件
│   ├── home_page.dart              # 首页
│   ├── mall_page.dart              # 商城页面
│   ├── profile_page.dart           # 个人中心
│   ├── product_detail_page.dart    # 商品详情页
│   ├── cart_page.dart              # 购物车页面
│   ├── search_page.dart            # 搜索页面
│   ├── order_list_page.dart        # 订单列表
│   ├── order_detail_page.dart      # 订单详情
│   ├── order_confirm_page.dart     # 订单确认
│   ├── address_select_page.dart    # 地址选择
│   ├── login_test_page.dart        # 登录测试
│   └── debug_page.dart             # 调试页面
├── providers/                       # 状态管理
│   ├── app_state.dart              # 应用全局状态
│   ├── home_state.dart             # 首页状态
│   ├── cart_state.dart             # 购物车状态
│   ├── search_state.dart           # 搜索状态
│   ├── product_detail_state.dart   # 商品详情状态
│   └── order_state.dart            # 订单状态
├── services/                        # 服务层
│   └── graphql_service.dart        # GraphQL服务
├── utils/                           # 工具类
│   ├── connection_tester.dart      # 网络连接测试
│   ├── graphql_diagnostics.dart    # GraphQL诊断工具
│   ├── login_tester.dart           # 登录测试工具
│   ├── network_helper.dart         # 网络辅助工具
│   └── port_scanner.dart           # 端口扫描工具
└── widgets/                         # 可复用组件
    ├── app_bar_custom.dart         # 自定义应用栏
    ├── cart_item_widget.dart       # 购物车项组件
    ├── category_grid.dart          # 分类网格
    ├── feature_button.dart         # 功能按钮组件
    ├── featured_product_card.dart  # 特色商品卡片
    ├── home_banner.dart            # 首页轮播图
    ├── menu_item.dart              # 菜单项组件
    ├── product_card.dart           # 商品卡片组件
    ├── recommendation_card.dart    # 推荐卡片组件
    ├── search_filter_sheet.dart    # 搜索过滤器
    ├── search_suggestion_item.dart # 搜索建议项
    ├── selection_row.dart          # 选择行组件
    ├── simple_app_bar.dart         # 简单应用栏
    └── simple_banner.dart          # 简单轮播图
```

## 功能特点

### 🏠 首页
- **GraphQL数据驱动**：通过GraphQL API获取轮播图、特色商品和分类数据
- **智能加载状态**：优雅的加载动画和错误处理
- **轮播图展示**：支持多种类型的首页轮播内容
- **特色商品推荐**：智能产品推荐和图标匹配
- **快捷功能入口**：搜索、购物车等功能快速访问

### 🛍️ 商城与购物
- **商品展示**：网格布局展示各类家装产品
- **智能搜索**：支持关键词搜索、筛选和排序
- **商品详情**：详细的商品信息、规格、评价和服务
- **购物车管理**：添加、删除、修改数量和规格选择
- **价格计算**：实时计算商品价格、折扣和运费

### 📦 订单管理
- **订单确认**：支持地址选择、配送方式和支付方式
- **订单跟踪**：完整的订单状态跟踪和物流信息
- **订单历史**：查看历史订单和重新购买功能
- **地址管理**：收货地址的增删改查

### 👤 用户中心
- **身份认证**：GraphQL驱动的登录/注册系统
- **Token管理**：安全的用户令牌存储和自动刷新
- **个人资料**：用户信息管理和偏好设置
- **VIP会员**：会员等级和特权展示

### 🔧 开发与调试
- **网络诊断**：完整的网络连接和GraphQL端点测试工具
- **端口扫描**：自动发现可用的GraphQL服务
- **连接测试**：多平台网络连接状态检测
- **API调试**：GraphQL查询和变更的调试界面

## 技术栈

### 核心技术
- **框架**：Flutter 3.8.1+
- **开发语言**：Dart
- **架构模式**：Provider模式状态管理 + 分层架构

### 后端集成
- **API类型**：GraphQL
- **网络请求**：graphql_flutter + http
- **身份认证**：JWT Token + SharedPreferences存储
- **数据缓存**：Hive本地数据库

### UI与交互
- **设计系统**：Material Design 3
- **主题管理**：统一的颜色和样式系统
- **图片处理**：cached_network_image
- **下拉刷新**：pull_to_refresh
- **轮播图**：carousel_slider
- **加载效果**：shimmer动画

### 功能增强
- **路由管理**：go_router
- **徽章显示**：badges
- **国际化**：intl
- **外部链接**：url_launcher

## GraphQL API集成

### 核心查询
```graphql
# 首页数据查询
query GetHomeData {
  banners {
    id
    title
    imageUrl
    linkUrl
    type
    sortOrder
  }
  featuredProducts {
    id
    name
    price
    originalPrice
    imageUrl
    rating
    salesCount
  }
  categories {
    id
    name
    icon
    productCount
  }
}

# 用户认证
mutation Login($input: LoginInput!) {
  login(input: $input) {
    success
    message
    token
    user {
      id
      username
      email
      avatar
      role
    }
  }
}
```

### 数据模型
- **Product**: 商品基础信息模型
- **ProductDetail**: 商品详细信息模型
- **BannerItem**: 轮播图数据模型
- **CartItem**: 购物车项目模型
- **Order**: 订单信息模型
- **User**: 用户信息模型
- **Address**: 地址信息模型

## 状态管理架构

### Provider状态管理
- **AppState**: 应用全局状态（用户信息、主题等）
- **HomeState**: 首页数据状态（轮播图、商品、分类）
- **CartState**: 购物车状态（商品列表、数量、价格计算）
- **SearchState**: 搜索状态（关键词、筛选、结果）
- **ProductDetailState**: 商品详情状态（详细信息、规格选择）
- **OrderState**: 订单状态（订单列表、详情、状态跟踪）

### 数据流向
1. **UI层** → Provider监听状态变化
2. **State层** → 调用GraphQL服务
3. **Service层** → 发送GraphQL请求
4. **API层** → 返回数据更新状态
5. **UI层** → 自动重建界面

## 安装运行

### 环境要求
- Flutter SDK 3.8.1+
- Dart SDK 2.19+
- Android Studio / VS Code
- GraphQL服务端（可选，用于完整功能）

### 安装步骤

1. **克隆项目**
   ```bash
   git clone [项目地址]
   cd flutter_home_mall
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **配置GraphQL端点**
   ```dart
   // lib/services/graphql_service.dart
   static const String _endpoint = 'http://your-graphql-server:8082/graphql';
   ```

4. **运行项目**
   ```bash
   # Android
   flutter run -d android
   
   # iOS  
   flutter run -d ios
   
   # Web
   flutter run -d chrome
   ```

## 核心功能说明

### 网络配置与调试
- **自动平台适配**：Android模拟器、iOS模拟器、真机设备的网络配置
- **连接状态检测**：实时网络连接状态监控
- **GraphQL端点测试**：可视化的API连接测试工具
- **端口扫描**：自动发现本地GraphQL服务

### 用户认证流程
1. 用户点击登录按钮
2. 显示登录模态框
3. GraphQL认证请求
4. Token存储到本地
5. 用户状态更新
6. UI界面响应变化

### 商品购买流程
1. 浏览商品 → 商品详情
2. 选择规格 → 加入购物车
3. 查看购物车 → 确认订单
4. 选择地址 → 选择支付方式
5. 提交订单 → 订单跟踪

## 开发指南

### 添加新页面
1. 在`pages/`目录创建页面文件
2. 在`providers/`目录创建对应状态管理
3. 在`main.dart`中注册Provider
4. 添加路由配置

### 添加新的GraphQL查询
1. 在`services/graphql_service.dart`中添加查询方法
2. 在`models/api_models.dart`中定义数据模型
3. 在对应的State中调用服务方法
4. 在UI中监听状态变化

### 自定义主题
```dart
// lib/core/themes/app_theme.dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    // 其他主题配置
  );
}
```

## 性能优化

- **懒加载**：页面和数据按需加载
- **图片缓存**：网络图片自动缓存
- **状态优化**：避免不必要的Widget重建
- **内存管理**：及时释放资源和监听器
- **网络优化**：GraphQL查询合并和缓存

## 未来规划

- [ ] 添加支付系统集成
- [ ] 实现实时消息推送
- [ ] 添加语音搜索功能
- [ ] 支持多语言国际化
- [ ] 添加AR商品预览
- [ ] 集成地图和配送跟踪
- [ ] 添加社交分享功能
- [ ] 支持暗黑模式主题
- [ ] 添加离线数据同步
- [ ] 实现智能推荐算法

## 许可证

本项目遵循 MIT 许可证。
