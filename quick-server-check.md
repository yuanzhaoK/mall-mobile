# 🚀 快速GraphQL服务器检查指令

## 步骤1: 检查端口占用

在你的电脑终端运行：

```bash
# macOS/Linux
lsof -i :8082

# 如果没有输出，说明8082端口没有被使用
```

## 步骤2: 测试localhost连接

```bash
# 测试GraphQL端点是否响应
curl -X POST http://localhost:8082/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ __typename }"}'
```

**期望结果**: 应该返回JSON响应，不是连接错误

## 步骤3: 创建测试服务器

如果没有GraphQL服务器运行，创建一个简单的测试服务器：

```javascript
// test-server.js
const express = require('express');
const app = express();

app.use(express.json());

app.post('/graphql', (req, res) => {
  res.json({
    data: {
      appHomeData: {
        featured_products: [
          { id: "1", name: "测试产品", price: 1000 }
        ],
        categories: [
          { id: "1", name: "测试分类", created: "false", description: "测试描述" }
        ]
      }
    }
  });
});

// 重要：绑定到所有接口，不只是localhost
app.listen(8082, '0.0.0.0', () => {
  console.log('✅ 测试服务器运行在:');
  console.log('   本地: http://localhost:8082/graphql');
  console.log('   外部: http://10.241.25.183:8082/graphql');
});
```

保存为 `test-server.js`，然后运行：

```bash
node test-server.js
```

## 步骤4: 在Flutter应用中测试

1. 运行测试服务器
2. 在Flutter应用中点击🐛调试按钮
3. 点击"🔍 端口扫描"
4. 查看是否找到GraphQL服务

## 🎯 预期结果

如果一切正常，你应该看到：
- ✅ 找到localhost GraphQL服务: http://127.0.0.1:8082/graphql
- ✅ 找到GraphQL服务: http://10.241.25.183:8082/graphql

## 📞 快速解决方案

如果仍然不工作，在 `lib/services/graphql_service.dart` 中直接硬编码：

```dart
static String get _endpoint {
  return 'http://localhost:8082/graphql';  // 或者你知道工作的端点
}
``` 