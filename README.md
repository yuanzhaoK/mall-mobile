# Flutter Mall - 移动购物商城
<div align="center">

![Flutter Version](https://img.shields.io/badge/Flutter-3.8.1+-blue.svg)
![Dart Version](https://img.shields.io/badge/Dart-3.8.1+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)

一个基于Flutter开发的现代化移动购物商城应用，采用Material Design 3设计语言，提供完整的电商购物体验。

</div>



## 🚀 快速开始

### 环境要求

- **Flutter SDK**: 3.8.1 或更高版本
- **Dart SDK**: 3.8.1 或更高版本
- **IDE**: VS Code 或 Android Studio
- **操作系统**: macOS, Windows, 或 Linux

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-repo/flutter_home_mall.git
   cd flutter_home_mall
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **代码生成**（如果需要）
   ```bash
   flutter packages pub run build_runner build
   ```

4. **运行应用**
   ```bash
   # iOS模拟器
   flutter run -d ios
   
   # Android模拟器
   flutter run -d android
   
   # 指定设备
   flutter run -d [device_id]
   ```

### 环境配置

1. **后端服务**
   - 确保GraphQL服务器运行在 `http://10.241.25.183:8082/graphql`
   - 或修改 `lib/config/app_config.dart` 中的端点配置

2. **调试工具**
   - 访问应用内调试页面查看网络状态
   - 使用Flutter Inspector调试UI

## 🏗️ 技术架构

### 项目结构

```
lib/
├── config/           # 应用配置
│   └── app_config.dart
├── constants/        # 常量定义
│   ├── app_colors.dart
│   └── app_strings.dart
├── core/            # 核心模块
│   ├── exceptions/   # 异常处理
│   ├── router/      # 路由配置
│   ├── themes/      # 主题配置
│   └── utils/       # 工具类
├── models/          # 数据模型
├── pages/           # 页面组件
├── providers/       # 状态管理
├── services/        # 业务服务
├── utils/           # 实用工具
├── widgets/         # 通用组件
└── main.dart        # 应用入口
```

### 技术栈

| 类别 | 技术选型 | 版本 | 用途 |
|------|----------|------|------|
| **UI框架** | Flutter | 3.8.1+ | 跨平台UI开发 |
| **状态管理** | Provider | ^6.1.1 | 应用状态管理 |
| **网络请求** | GraphQL Flutter | ^5.1.2 | API数据获取 |
| **路由管理** | GoRouter | ^12.1.3 | 声明式路由 |
| **本地存储** | SharedPreferences<br>Hive | ^2.2.2<br>^2.2.3 | 数据持久化 |
| **图片缓存** | CachedNetworkImage | ^3.3.0 | 网络图片处理 |
| **UI组件** | PullToRefresh<br>Shimmer<br>CarouselSlider | ^2.0.0<br>^3.0.0<br>^4.2.1 | 交互组件 |

### 架构模式

- **MVVM模式** - Model-View-ViewModel分离
- **Repository模式** - 数据访问层抽象
- **Provider模式** - 响应式状态管理
- **依赖注入** - 服务解耦和测试友好

## 👨‍💻 开发指南

### 代码规范

项目采用严格的代码质量标准，配置了完整的Lint规则：

- **命名规范**: 遵循Dart官方命名约定
- **代码格式**: 使用`dart format`自动格式化
- **静态分析**: 运行`flutter analyze`检查代码质量


### 开发流程

1. **功能开发**
   ```bash
   # 创建功能分支
   git checkout -b feature/your-feature-name
   
   # 开发过程中定期提交
   git add .
   git commit -m "feat: add your feature description"
   ```

2. **代码检查**
   ```bash
   # 代码分析
   flutter analyze
   
   # 代码格式化
   dart format lib/ test/
   
   # 运行测试
   flutter test
   ```

3. **提交代码**
   ```bash
   # 推送分支
   git push origin feature/your-feature-name
   
   # 创建Pull Request
   ```

### 新功能开发

1. **创建模型** - 在`lib/models/`中定义数据模型
2. **创建服务** - 在`lib/services/`中实现业务逻辑
3. **创建Provider** - 在`lib/providers/`中管理状态
4. **创建页面** - 在`lib/pages/`中实现UI
5. **更新路由** - 在`lib/core/router/`中配置路由
6. **编写测试** - 在`test/`中添加单元测试

### 调试工具

- **Debug页面** - 应用内调试工具，可检查网络连接、API状态等
- **Logger系统** - 分级日志记录，便于问题定位
- **异常处理** - 完整的异常捕获和用户友好提示

## 📋 API文档

### GraphQL端点

- **开发环境**: `http://localhost:8082/graphql`

### 主要查询

#### 首页数据
```graphql
query AppHomeData {
  appHomeData {
    banners { id title image_url link_url type sort_order }
    featured_products { id name price original_price image_url rating sales_count }
    categories { id name icon_url product_count }
  }
}
```

#### 用户认证
```graphql
mutation mobileLogin($input: LoginInput!) {
  mobileLogin(input: $input) {
    token
    record { id email identity avatar }
  }
}
```


## 🧪 测试

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/models/product_test.dart

# 生成测试覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```



## 📦 构建部署

### 构建Release版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 环境配置

不同环境的配置在`lib/config/app_config.dart`中管理：



### 提交规范

使用[Conventional Commits](https://conventionalcommits.org/)规范：

- `feat:` 新功能
- `fix:` 错误修复
- `docs:` 文档更新
- `style:` 代码格式调整
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建/工具相关

## 📝 更新日志

#### 新增
- 初始项目架构
- 首页和商品浏览功能
- 用户认证系统
- 购物车基础功能
- GraphQL API集成



## 📄 许可证

本项目采用MIT许可证 - 详见[LICENSE](LICENSE)文件。

## 🙏 致谢

感谢以下开源项目：

- [Flutter](https://flutter.dev/) - Google出品的UI工具包
- [Provider](https://pub.dev/packages/provider) - Flutter状态管理
- [GraphQL Flutter](https://pub.dev/packages/graphql_flutter) - GraphQL客户端
- [GoRouter](https://pub.dev/packages/go_router) - 声明式路由


<div align="center">

**[⬆ 回到顶部](#flutter-mall---移动购物商城)**

Made with ❤️ using Flutter

</div>
