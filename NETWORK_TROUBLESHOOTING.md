# 网络连接故障排除指南

## 🚨 问题：GraphQL连接失败

如果你看到以下错误：
```
SocketException: Connection failed (OS Error: Operation not permitted, errno = 1)
address = localhost, port = 8082
```

这表示应用无法连接到你的GraphQL服务器。

## 🔧 解决方案

### 方案1：Android模拟器（推荐）

1. **确保你的GraphQL服务运行在**：`http://localhost:8082/graphql`

2. **修改网络配置**：
   在 `lib/utils/network_helper.dart` 中，确保：
   ```dart
   const bool isRealDevice = false; // 模拟器使用false
   ```

3. **重新运行应用**：
   ```bash
   flutter hot restart
   ```

### 方案2：真机测试

1. **获取你的电脑IP地址**：
   - **Windows**: 在cmd中运行 `ipconfig`
   - **macOS/Linux**: 在终端中运行 `ifconfig` 或 `ip addr`
   - 查找类似 `192.168.1.xxx` 或 `10.xxx.xxx.xxx` 的地址

2. **更新网络配置**：
   在 `lib/utils/network_helper.dart` 中：
   ```dart
   const String realDeviceIP = 'YOUR_COMPUTER_IP'; // 替换为你的电脑IP
   const bool isRealDevice = true; // 真机使用true
   ```

3. **确保防火墙允许连接**：
   - 确保你的电脑防火墙允许端口8082的入站连接
   - 确保电脑和手机在同一个WiFi网络中

### 方案3：iOS模拟器

iOS模拟器通常可以直接使用localhost，确保：
```dart
const bool isRealDevice = false; // 模拟器使用false
```

## 🔍 调试步骤

### 1. 检查GraphQL服务器
确保你的GraphQL服务器正在运行：
```bash
curl http://localhost:8082/graphql
```

### 2. 检查网络权限
确认Android Manifest已添加网络权限：
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 3. 查看控制台日志
在Flutter应用中查看调试输出：
```
flutter logs
```

你应该看到类似：
```
Using API endpoint: http://10.0.2.2:8082/graphql
```

### 4. 测试网络连接
在真机上，可以用浏览器访问：
`http://YOUR_COMPUTER_IP:8082/graphql`

## 📱 平台特定配置

### Android
- **模拟器**: 使用 `10.0.2.2` 访问宿主机
- **真机**: 使用电脑的实际IP地址

### iOS
- **模拟器**: 可以直接使用 `localhost`
- **真机**: 使用电脑的实际IP地址

### Web
- 直接使用 `localhost`

## ⚡ 快速修复

如果上述步骤都不行，可以在 `lib/services/graphql_service.dart` 中直接硬编码你的IP：

```dart
static String get _endpoint {
  // 直接返回你的电脑IP
  return 'http://YOUR_COMPUTER_IP:8082/graphql';
}
```

## 🛡️ 安全提示

- 在生产环境中，不要使用localhost或内网IP
- 考虑使用HTTPS而不是HTTP
- 添加适当的认证和授权机制

## 🆘 仍然有问题？

1. 检查你的GraphQL服务器是否绑定到了0.0.0.0而不是127.0.0.1
2. 确认端口8082没有被其他应用占用
3. 尝试重启模拟器/设备和应用
4. 检查网络连接和代理设置 