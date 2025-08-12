# 会员等级显示调试指南

## 问题描述
登录后会员信息显示默认的"VIP会员"而不是真实的会员等级名称。

## 调试步骤

### 1. 登录过程调试
当你登录时，请观察控制台输出，应该看到以下调试信息序列：

```
🔐 登录对话框收到成功响应: [username]
🔐 登录响应中的会员等级: [memberLevel.displayName或null]
🔐 ProfilePage收到登录成功回调: [username]
🔐 会员等级已保存: [memberLevel.displayName]
🔐 会员等级JSON: {"id":"...","display_name":"青铜会员",...}
🔐 ProfilePage状态已更新: isLoggedIn=true, username=[username]
🔐 会员等级信息: [memberLevel.displayName或"无等级信息"]
```

### 2. 应用重启恢复调试
当应用重启时，应该看到：

```
🔐 会员等级原始JSON: {"id":"...","display_name":"青铜会员",...}
🔐 已恢复会员等级: 青铜会员
🔐 会员等级详情: level=1, color=#CD7F32
🔐 已恢复用户状态: [username]
🔐 已恢复会员等级: 青铜会员
```

### 3. UI 渲染调试
每次页面重建时，会显示：

```
🔐 ProfilePage build - isLoggedIn: true, username: [username]
🔐 ProfilePage build - memberLevel: [MemberLevel对象详情]
🔐 ProfilePage build - memberLevel?.displayName: [真实等级名称]
🔐 UI显示会员文本: [最终显示的文本]
```

## 常见问题排查

### 问题1: 登录响应中会员等级为null
**日志**: `🔐 登录响应中的会员等级: null`
**原因**: API响应中没有memberLevel字段或字段为null
**解决**: 检查API返回数据格式，确保包含memberLevel字段

### 问题2: 会员等级保存失败
**日志**: `🔐 会员等级为null，已清除保存的数据`
**原因**: authResponse.memberLevel为null
**解决**: 确认API响应包含完整的memberLevel数据

### 问题3: 会员等级解析失败
**日志**: `🔐 解析会员等级失败: [错误信息]`
**原因**: 保存的JSON格式不正确或模型解析有问题
**解决**: 检查MemberLevel.fromJson方法和toJson方法

### 问题4: UI显示仍为默认值
**日志**: `🔐 UI显示会员文本: VIP会员`
**原因**: memberLevel?.displayName为null，使用了fallback值
**解决**: 检查memberLevel对象是否正确赋值

## 手动测试流程

1. **清除应用数据** (可选)
2. **启动应用** → 观察初始状态日志
3. **点击登录** → 输入有效凭据
4. **观察登录日志** → 确认会员等级数据
5. **检查UI显示** → 验证是否显示真实等级
6. **杀掉应用进程** → 模拟应用重启
7. **重新启动** → 观察数据恢复日志
8. **验证UI** → 确认会员信息正确显示

## 数据验证

确保API返回的memberLevel包含：
- `id`: 会员等级ID
- `display_name`: 显示名称（如"青铜会员"）
- `level`: 等级数字
- `color`: 等级颜色
- `benefits`: 权益信息

## 下一步调试

如果问题仍然存在，请提供：
1. 完整的登录过程控制台日志
2. API返回的原始JSON数据
3. 应用重启后的恢复日志
4. UI显示的实际文本

这将帮助精确定位问题所在。
