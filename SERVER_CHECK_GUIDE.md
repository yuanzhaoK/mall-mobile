# GraphQL服务器检查指南

## 🔍 问题诊断

根据网络诊断结果，所有端点都无法连接。这通常意味着：

1. GraphQL服务器没有运行
2. 服务器没有监听在正确的端口(8082)
3. 服务器只监听在localhost而不是所有接口
4. 防火墙阻止了连接

## 🛠️ 检查步骤

### 步骤1: 确认服务器是否运行

在你的电脑上运行以下命令：

```bash
# 检查端口8082是否被使用
lsof -i :8082
# 或者
netstat -an | grep 8082
```

如果没有输出，说明没有程序在监听8082端口。

### 步骤2: 检查GraphQL服务器配置

确保你的GraphQL服务器：

1. **正在运行** - 启动你的GraphQL服务器
2. **监听正确端口** - 确认是8082端口
3. **监听所有接口** - 服务器应该绑定到 `0.0.0.0:8082` 而不是 `127.0.0.1:8082`

### 步骤3: 测试本地连接

在你的电脑上测试：

```bash
# 测试GraphQL服务器是否响应
curl -X POST http://localhost:8082/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __typename }"}'
```

应该返回JSON响应，不是连接错误。

### 步骤4: 测试外部连接

```bash
# 使用你的IP地址测试
curl -X POST http://10.241.25.183:8082/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __typename }"}'
```

### 步骤5: 检查防火墙

**macOS:**
```bash
# 检查是否有防火墙规则阻止8082端口
sudo pfctl -s all | grep 8082
```

**如果你使用的是Node.js GraphQL服务器，请确保：**

```javascript
// 错误的配置（只监听localhost）
app.listen(8082, 'localhost');

// 正确的配置（监听所有接口）
app.listen(8082, '0.0.0.0');
// 或者
app.listen(8082); // 默认监听所有接口
```

## 🚀 常见解决方案

### 解决方案1: 启动GraphQL服务器

确保你的GraphQL服务器正在运行。如果没有，请启动它。

### 解决方案2: 修改服务器绑定地址

如果服务器只绑定到localhost，修改为绑定到所有接口：

```javascript
// Node.js Express 示例
app.listen(8082, '0.0.0.0', () => {
  console.log('GraphQL server running on http://0.0.0.0:8082/graphql');
});
```

### 解决方案3: 检查网络配置

确保电脑和手机/模拟器在同一个网络中。

### 解决方案4: 使用不同端口

如果8082被占用，尝试使用其他端口：

```javascript
// 使用8080端口
app.listen(8080, '0.0.0.0');
```

然后在Flutter应用中相应修改端口。

## 🔧 快速测试脚本

创建一个简单的测试服务器来验证网络连接：

```javascript
// test-server.js
const express = require('express');
const app = express();

app.use(express.json());

app.post('/graphql', (req, res) => {
  res.json({
    data: {
      message: "GraphQL服务器连接成功！",
      timestamp: new Date().toISOString()
    }
  });
});

app.listen(8082, '0.0.0.0', () => {
  console.log('测试服务器运行在 http://0.0.0.0:8082/graphql');
  console.log('本地访问: http://localhost:8082/graphql');
  console.log('外部访问: http://10.241.25.183:8082/graphql');
});
```

运行: `node test-server.js`

## 📋 检查清单

请逐一检查：

- [ ] GraphQL服务器正在运行
- [ ] 服务器监听在8082端口
- [ ] 服务器绑定到0.0.0.0（所有接口）
- [ ] 本地curl测试成功
- [ ] 外部IP curl测试成功
- [ ] 防火墙允许8082端口
- [ ] 电脑和设备在同一网络 