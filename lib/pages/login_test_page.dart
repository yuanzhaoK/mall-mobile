import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/graphql_service.dart';
import '../constants/app_colors.dart';

class LoginTestPage extends StatefulWidget {
  const LoginTestPage({super.key});

  @override
  State<LoginTestPage> createState() => _LoginTestPageState();
}

class _LoginTestPageState extends State<LoginTestPage> {
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<String> logs = [];
  bool isTesting = false;

  void addLog(String message) {
    setState(() {
      logs.add(
        '${DateTime.now().toIso8601String().substring(11, 19)}: $message',
      );
    });
  }

  Future<void> testLogin() async {
    if (_identityController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入用户名和密码')));
      return;
    }

    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🔐 开始登录测试...');
    addLog('用户名: ${_identityController.text}');
    addLog('密码长度: ${_passwordController.text.length}');

    try {
      final result = await GraphQLService.login(
        _identityController.text,
        _passwordController.text,
      );

      if (result != null) {
        addLog('✅ 登录成功！');
        addLog('👤 用户ID: ${result.user.id}');
        addLog('👤 用户名: ${result.user.name}');
        addLog('📧 邮箱: ${result.user.email}');
        addLog('👤 角色: ${result.user.role}');
        addLog('🔑 Token: ${result.token.substring(0, 30)}...');
        addLog('✅ 已保存到本地存储');

        // 测试注销
        addLog('🔐 测试注销功能...');
        final logoutResult = await GraphQLService.logout();
        addLog(logoutResult ? '✅ 注销成功' : '❌ 注销失败');
      } else {
        addLog('❌ 登录返回空结果');
      }
    } catch (e) {
      addLog('❌ 登录失败');
      addLog('错误详情: ${e.toString()}');

      // 详细错误分析
      final errorStr = e.toString();
      if (errorStr.contains('Authentication failed')) {
        addLog('💡 分析: 认证失败 - 用户名或密码错误');
        addLog('建议: 检查用户名和密码是否正确');
      } else if (errorStr.contains('SocketException')) {
        addLog('💡 分析: 网络连接问题');
        addLog('建议: 检查服务器是否运行，网络是否畅通');
      } else if (errorStr.contains('FormatException')) {
        addLog('💡 分析: 数据格式错误');
        addLog('建议: 检查GraphQL schema是否匹配');
      } else {
        addLog('💡 分析: 未知错误');
        addLog('建议: 检查服务器日志');
      }
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 登录测试完成');
  }

  Future<void> testPredefinedCredentials() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🔐 测试预定义凭据...');

    // 常见的测试凭据
    final testCredentials = [
      {'identity': 'admin', 'password': 'admin'},
      {'identity': 'test', 'password': 'test'},
      {'identity': 'user', 'password': 'password'},
      {'identity': 'admin@test.com', 'password': 'admin123'},
      {'identity': 'test@example.com', 'password': 'test123'},
    ];

    for (final cred in testCredentials) {
      addLog('🔐 测试: ${cred['identity']}');

      try {
        final result = await GraphQLService.login(
          cred['identity']!,
          cred['password']!,
        );

        if (result != null) {
          addLog('✅ 成功！用户: ${result.user.name}');
          await GraphQLService.logout();
          break; // 找到有效凭据就停止
        }
      } catch (e) {
        addLog('❌ 失败: ${e.toString().split(':').first}');
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 预定义凭据测试完成');
  }

  Future<void> testGraphQLConnection() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🔗 测试GraphQL连接...');

    try {
      final result = await GraphQLService.getHomeData();
      if (result != null) {
        addLog('✅ GraphQL连接正常');
        addLog('📊 获取到 ${result.featuredProducts.length} 个产品');
        addLog('📊 获取到 ${result.categories.length} 个分类');
      } else {
        addLog('❌ GraphQL查询返回空数据');
      }
    } catch (e) {
      addLog('❌ GraphQL连接失败: $e');
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 GraphQL连接测试完成');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录测试'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 输入框
                TextField(
                  controller: _identityController,
                  decoration: const InputDecoration(
                    labelText: '用户名/邮箱',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // 测试按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isTesting ? null : testLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('🔐 测试登录'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isTesting ? null : testPredefinedCredentials,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('🧪 测试预设'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isTesting ? null : testGraphQLConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('🔗 测试连接'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: logs.isEmpty
                            ? null
                            : () {
                                final logText = logs.join('\n');
                                Clipboard.setData(ClipboardData(text: logText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('日志已复制')),
                                );
                              },
                        child: const Text('📋 复制日志'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  Color textColor = Colors.white;

                  if (log.contains('✅')) {
                    textColor = Colors.green;
                  } else if (log.contains('❌')) {
                    textColor = Colors.red;
                  } else if (log.contains('💡')) {
                    textColor = Colors.yellow;
                  } else if (log.contains('🔐') || log.contains('🔗')) {
                    textColor = Colors.blue;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      log,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
