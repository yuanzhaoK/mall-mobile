# 动态配置系统使用说明

这个文档说明如何设置和使用项目的动态配置系统。

## 概述

项目支持基于本地配置文件的动态环境配置，允许不同开发者使用不同的开发环境设置，而不会影响版本控制。

## 快速开始

### 1. 设置本地配置

```bash
# 进入配置目录
cd lib/config

# 复制模板文件
cp local_config.dart.template local_config.dart
```

### 2. 修改本地配置

编辑 `local_config.dart` 文件，根据你的开发环境修改配置：

```dart
class LocalConfig {
  /// 开发环境API配置 - 修改为你的后端地址
  static const String developmentBaseUrl = 'http://你的IP:端口';
  static const String developmentGraphqlEndpoint = 'http://你的IP:端口/graphql';
  static const String developmentWebsocketEndpoint = 'ws://你的IP:端口/graphql';
  
  /// 其他配置...
}
```

### 3. 验证配置

在应用中添加调试代码来验证配置是否正确加载：

```dart
import '../config/app_config.dart';

void main() {
  // 打印配置摘要
  print(AppConfig.getConfigSummary());
  
  runApp(MyApp());
}
```

## 配置文件说明

### local_config.dart.template
- **用途**: 配置模板文件，提供配置项示例
- **版本控制**: ✅ 提交到 Git（供其他开发者参考）
- **修改**: ❌ 不要修改（保持作为模板）

### local_config.dart
- **用途**: 实际的本地配置文件
- **版本控制**: ❌ 不提交到 Git（在 .gitignore 中）
- **修改**: ✅ 根据你的环境随意修改

## 可配置项

### API 端点
```dart
static const String developmentBaseUrl = 'http://localhost:8082';
static const String developmentGraphqlEndpoint = 'http://localhost:8082/graphql';
static const String developmentWebsocketEndpoint = 'ws://localhost:8082/graphql';
```

### 网络配置
```dart
static const int networkTimeout = 30; // 网络超时时间（秒）
static const bool enableNetworkLogs = true; // 是否开启网络日志
```

### 开发功能
```dart
static const bool enableMockData = false; // 是否使用模拟数据
```

## 常见问题

### Q: 应用启动时报错找不到 LocalConfig
**A**: 请确保已经复制了 `local_config.dart.template` 为 `local_config.dart`

### Q: 配置修改后没有生效
**A**: 
1. 检查配置语法是否正确
2. 重新运行应用（热重载可能不会重新加载配置）
3. 检查是否有编译错误

### Q: 团队成员如何设置配置
**A**: 
1. 新成员克隆代码后，复制模板文件
2. 根据团队的开发环境文档修改配置
3. 配置文件不会被提交，每个人都有自己的版本

## 最佳实践

### ✅ 推荐做法
- 复制模板文件后立即修改为正确的配置
- 在团队文档中记录标准的开发环境配置
- 定期更新模板文件中的示例配置

### ❌ 避免做法
- 不要修改模板文件的配置值
- 不要将 `local_config.dart` 提交到版本控制
- 不要在代码中硬编码开发环境地址

## 调试工具

### 配置摘要
使用 `AppConfig.getConfigSummary()` 获取当前配置信息：

```dart
final summary = AppConfig.getConfigSummary();
print('当前配置: $summary');
```

输出示例：
```json
{
  "environment": "Development",
  "hasLocalConfig": true,
  "currentConfig": {
    "baseUrl": "http://10.241.25.183:8082",
    "graphqlEndpoint": "http://10.241.25.183:8082/graphql",
    "timeout": 30
  }
}
```

### 检查本地配置
```dart
if (AppConfig.hasLocalConfig) {
  print('✅ 本地配置已加载');
} else {
  print('⚠️ 使用默认配置');
}
``` 