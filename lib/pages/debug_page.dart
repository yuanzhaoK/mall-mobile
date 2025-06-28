import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/graphql_service.dart';
import '../utils/connection_tester.dart';
import '../utils/network_helper.dart';
import '../utils/port_scanner.dart';
import '../utils/graphql_diagnostics.dart';
import '../utils/login_tester.dart';
import '../config/app_config.dart';
import 'login_test_page.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  List<String> logs = [];
  bool isTesting = false;

  void addLog(String message) {
    setState(() {
      logs.add(
        '${DateTime.now().toIso8601String().substring(11, 19)}: $message',
      );
    });
  }

  void showCurrentConfig() {
    setState(() {
      logs.clear();
    });

    addLog('📋 当前配置信息:');
    addLog('🔧 配置来源: ${AppConfig.hasLocalConfig ? "✅ 本地配置" : "⚠️ 默认配置"}');
    addLog('🌍 当前环境: ${AppConfig.environment.name}');

    final config = AppConfig.config;
    addLog('📍 GraphQL端点: ${config.graphqlEndpoint}');
    addLog('🌐 基础URL: ${config.baseUrl}');
    addLog('🔌 WebSocket端点: ${config.websocketEndpoint}');
    addLog('⏱️ 超时时间: ${config.timeout.inSeconds}秒');
    addLog('📝 日志记录: ${config.enableLogging ? "启用" : "禁用"}');

    if (!AppConfig.hasLocalConfig) {
      addLog('');
      addLog('💡 提示: 使用本地配置');
      addLog('1. 复制 lib/config/local_config.dart.template');
      addLog('2. 重命名为 local_config.dart');
      addLog('3. 修改其中的IP地址为你的服务器地址');
      addLog('4. 重新启动应用');
    }

    addLog('');
    addLog('🏁 配置信息显示完成');
  }

  Future<void> testConnections() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🔍 开始网络诊断...');

    // 测试配置的端点
    final confirmedEndpoint = AppConfig.config.graphqlEndpoint;
    addLog('📍 配置的端点: $confirmedEndpoint');
    addLog('🔧 配置来源: ${AppConfig.hasLocalConfig ? "本地配置" : "默认配置"}');

    final isConfirmedWorking = await ConnectionTester.testEndpoint(
      confirmedEndpoint,
    );
    addLog(
      '${isConfirmedWorking ? '✅' : '❌'} 确认端点测试结果: ${isConfirmedWorking ? '成功' : '失败'}',
    );

    // 测试当前配置的端点
    final currentEndpoint = NetworkHelper.getApiEndpoint();
    addLog('📍 当前配置端点: $currentEndpoint');

    final isCurrentWorking = await ConnectionTester.testEndpoint(
      currentEndpoint,
    );
    addLog(
      '${isCurrentWorking ? '✅' : '❌'} 当前端点测试结果: ${isCurrentWorking ? '成功' : '失败'}',
    );

    // 测试所有可能的端点
    final currentHost = Uri.parse(AppConfig.config.baseUrl).host;
    final currentPort = Uri.parse(AppConfig.config.baseUrl).port;
    final testEndpoints = [
      AppConfig.config.graphqlEndpoint, // 当前配置的端点
      'http://$currentHost:$currentPort/graphql',
      'http://10.0.2.2:8082/graphql',
      'http://127.0.0.1:8082/graphql',
      'http://localhost:8082/graphql',
    ];

    addLog('🔄 测试所有可能的端点...');

    for (String endpoint in testEndpoints) {
      addLog('测试: $endpoint');
      final isWorking = await ConnectionTester.testEndpoint(endpoint);
      addLog('${isWorking ? '✅' : '❌'} $endpoint - ${isWorking ? '成功' : '失败'}');
    }

    // 获取网络信息
    addLog('📶 获取网络信息...');
    final networkInfo = await ConnectionTester.getNetworkInfo();
    for (String info in networkInfo) {
      addLog('🌐 $info');
    }

    // 测试GraphQL查询
    addLog('🔗 测试GraphQL查询...');
    try {
      final result = await GraphQLService.getHomeData();
      if (result != null) {
        addLog('✅ GraphQL查询成功！获取到 ${result.featuredProducts.length} 个产品');
      } else {
        addLog('❌ GraphQL查询返回空数据');
      }
    } catch (e) {
      addLog('❌ GraphQL查询失败: $e');
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 诊断完成');
  }

  Future<void> scanPorts() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🔍 开始端口扫描...');

    // 扫描localhost的开放端口
    addLog('📡 扫描localhost开放端口 (8000-9000)...');
    final localOpenPorts = await PortScanner.scanPortRange(
      '127.0.0.1',
      8000,
      9000,
    );
    if (localOpenPorts.isNotEmpty) {
      addLog('✅ localhost开放端口: ${localOpenPorts.join(', ')}');
    } else {
      addLog('❌ localhost没有找到开放端口 (8000-9000)');
    }

    // 扫描配置的主机的开放端口
    final configuredHost = Uri.parse(AppConfig.config.baseUrl).host;
    addLog('📡 扫描 $configuredHost 开放端口 (8000-9000)...');
    final remoteOpenPorts = await PortScanner.scanPortRange(
      configuredHost,
      8000,
      9000,
    );
    if (remoteOpenPorts.isNotEmpty) {
      addLog('✅ $configuredHost开放端口: ${remoteOpenPorts.join(', ')}');
    } else {
      addLog('❌ $configuredHost没有找到开放端口 (8000-9000)');
    }

    // 扫描GraphQL服务
    addLog('🔍 扫描GraphQL服务...');
    final graphqlServices = await PortScanner.scanForGraphQLServices(
      configuredHost,
    );
    if (graphqlServices.isNotEmpty) {
      addLog('✅ 找到GraphQL服务:');
      for (String service in graphqlServices) {
        addLog('   📍 $service');
      }
    } else {
      addLog('❌ 没有找到GraphQL服务');
    }

    // 扫描localhost的GraphQL服务
    addLog('🔍 扫描localhost GraphQL服务...');
    final localGraphqlServices = await PortScanner.scanForGraphQLServices(
      '127.0.0.1',
    );
    if (localGraphqlServices.isNotEmpty) {
      addLog('✅ 找到localhost GraphQL服务:');
      for (String service in localGraphqlServices) {
        addLog('   📍 $service');
      }
    } else {
      addLog('❌ localhost没有找到GraphQL服务');
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 端口扫描完成');
  }

  Future<void> testConfirmedEndpoint() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🎯 测试配置的GraphQL端点...');

    final endpoint = AppConfig.config.graphqlEndpoint;
    addLog('📍 配置的端点: $endpoint');
    addLog('🔧 配置来源: ${AppConfig.hasLocalConfig ? "本地配置" : "默认配置"}');

    // 详细连接测试
    final testResult = await ConnectionTester.testEndpointDetailed(endpoint);
    if (testResult['success']) {
      addLog('✅ 基础连接: 成功');
      addLog('📊 状态码: ${testResult['statusCode']}');
      addLog('📏 响应长度: ${testResult['bodyLength']} 字节');
    } else {
      addLog('❌ 基础连接: 失败');
      addLog('❌ 错误类型: ${testResult['errorType']}');
      addLog('❌ 错误详情: ${testResult['error']}');

      // 分析错误并提供建议
      final error = testResult['error'].toString();
      if (error.contains('SocketException')) {
        addLog('💡 建议: 检查服务器是否运行，或尝试其他地址');
      } else if (error.contains('Connection refused')) {
        addLog('💡 建议: 端口可能被占用或服务器未监听此端口');
      } else if (error.contains('Operation not permitted')) {
        addLog('💡 建议: 可能是网络权限或防火墙问题');
      }
    }

    final isConnectable = testResult['success'];

    if (isConnectable) {
      // 测试实际的GraphQL查询
      addLog('🔗 测试实际GraphQL查询...');
      try {
        final result = await GraphQLService.getHomeData();
        if (result != null) {
          addLog('✅ GraphQL查询成功！');
          addLog('📊 获取到 ${result.featuredProducts.length} 个产品');
          addLog('📊 获取到 ${result.categories.length} 个分类');

          // 显示前几个产品
          if (result.featuredProducts.isNotEmpty) {
            addLog('🛍️ 产品示例:');
            for (int i = 0; i < 3 && i < result.featuredProducts.length; i++) {
              final product = result.featuredProducts[i];
              addLog('   • ${product.name} - ${product.formattedPrice}');
            }
          }
        } else {
          addLog('❌ GraphQL查询返回空数据');
        }
      } catch (e) {
        addLog('❌ GraphQL查询失败: $e');
      }
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 测试完成');
  }

  Future<void> testMultipleEndpoints() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🌐 测试多个端点变体...');

    // 不同的端点组合
    final currentHost = Uri.parse(AppConfig.config.baseUrl).host;
    final currentPort = Uri.parse(AppConfig.config.baseUrl).port;
    final endpoints = [
      AppConfig.config.graphqlEndpoint, // 当前配置地址
      'http://$currentHost:$currentPort/graphql', // 配置的基础地址
      'http://127.0.0.1:8082/graphql', // 本地回环
      'http://localhost:8082/graphql', // localhost
      'http://10.0.2.2:8082/graphql', // Android模拟器地址
      'http://0.0.0.0:8082/graphql', // 所有接口
    ];

    String? workingEndpoint;

    for (String endpoint in endpoints) {
      addLog('🔗 测试: $endpoint');

      final testResult = await ConnectionTester.testEndpointDetailed(endpoint);
      if (testResult['success']) {
        addLog('✅ 连接成功！');
        addLog('📊 状态码: ${testResult['statusCode']}');
        workingEndpoint = endpoint;

        // 找到可用端点
        addLog('💡 可以尝试在GraphQL服务中使用此端点: $endpoint');

        break; // 找到工作的端点就停止
      } else {
        addLog('❌ 连接失败: ${testResult['errorType']}');
      }
    }

    if (workingEndpoint != null) {
      addLog('🎉 找到可用端点: $workingEndpoint');
      addLog('💡 请在GraphQL服务中更新为此端点');
    } else {
      addLog('😔 没有找到可用的端点');
      addLog('💡 建议:');
      addLog('   1. 确认GraphQL服务器正在运行');
      addLog('   2. 检查服务器绑定地址 (应为0.0.0.0:8082)');
      addLog('   3. 检查防火墙设置');
      addLog('   4. 确认设备与服务器在同一网络');
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 多端点测试完成');
  }

  Future<void> testLogin() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🔐 测试GraphQL登录功能...');

    // 测试用的登录凭据
    final testCredentials = [
      {'identity': 'ahukpyu@outlook.com', 'password': 'kpyu1512..@'},
      {'identity': 'admin@example.com', 'password': 'admin123'},
      {'identity': 'user@test.com', 'password': 'test123'},
    ];

    for (final cred in testCredentials) {
      addLog('🔐 测试凭据: ${cred['identity']}');

      try {
        final result = await GraphQLService.login(
          cred['identity']!,
          cred['password']!,
        );

        if (result != null) {
          addLog('✅ 登录成功！');
          addLog('👤 用户: ${result.user.username}');
          addLog('📧 邮箱: ${result.user.email}');
          addLog('🔑 Token: ${result.token.substring(0, 20)}...');

          // 测试注销
          addLog('🔐 测试注销...');
          final logoutResult = await GraphQLService.logout();
          addLog(logoutResult ? '✅ 注销成功' : '❌ 注销失败');

          break; // 找到有效凭据就停止
        } else {
          addLog('❌ 登录返回空结果');
        }
      } catch (e) {
        addLog('❌ 登录失败: $e');

        // 分析错误类型
        if (e.toString().contains('Authentication failed')) {
          addLog('💡 错误分析: 认证失败，可能是用户名或密码错误');
        } else if (e.toString().contains('Connection')) {
          addLog('💡 错误分析: 连接问题');
        } else {
          addLog('💡 错误分析: 未知错误');
        }
      }

      // 等待一下再试下一个
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 登录测试完成');
  }

  Future<void> runFullDiagnostics() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🔍 开始全面GraphQL诊断...');

    final endpoint = AppConfig.config.graphqlEndpoint;
    addLog('📍 诊断端点: $endpoint');
    addLog('🔧 配置来源: ${AppConfig.hasLocalConfig ? "本地配置" : "默认配置"}');

    try {
      final results = await GraphQLDiagnostics.diagnoseConnection(endpoint);
      final report = GraphQLDiagnostics.generateReport(results);

      // 将报告按行分割并添加到日志
      final reportLines = report.split('\n');
      for (String line in reportLines) {
        if (line.trim().isNotEmpty) {
          addLog(line);
        }
      }

      // 分析结果并给出建议
      addLog('\n💡 诊断建议:');

      final graphqlFormat = results['graphqlFormat'] as Map<String, dynamic>;
      final timeoutTest = results['timeoutTest'] as Map<String, dynamic>;

      if (!graphqlFormat['success']) {
        final error = graphqlFormat['error'].toString();
        if (error.contains('TimeoutException')) {
          addLog('⚠️  超时问题: 服务器响应太慢或无响应');
          addLog('💡 建议: 1) 检查服务器是否运行 2) 增加超时时间 3) 检查网络连接');
        } else if (error.contains('SocketException')) {
          addLog('⚠️  连接问题: 无法连接到服务器');
          addLog('💡 建议: 1) 检查服务器是否启动 2) 检查IP地址是否正确 3) 检查防火墙设置');
        } else if (error.contains('Connection refused')) {
          addLog('⚠️  连接被拒绝: 端口可能未开放');
          addLog('💡 建议: 1) 检查服务器是否监听8082端口 2) 确认服务器绑定到0.0.0.0');
        }
      } else {
        addLog('✅ GraphQL连接正常');

        // 检查超时结果
        bool hasTimeoutIssues = true;
        timeoutTest.forEach((key, value) {
          if (key.startsWith('timeout_') && value['success']) {
            hasTimeoutIssues = false;
          }
        });

        if (hasTimeoutIssues) {
          addLog('⚠️  所有超时测试都失败，但基础连接正常');
          addLog('💡 建议: 服务器可能处理GraphQL请求很慢，考虑优化服务器性能');
        } else {
          addLog('✅ 连接和超时测试都正常');
          addLog('💡 如果登录仍然失败，可能是认证或GraphQL schema问题');
        }
      }
    } catch (e) {
      addLog('❌ 诊断过程中出错: $e');
    }

    setState(() {
      isTesting = false;
    });

    addLog('🏁 全面诊断完成');
  }

  Future<void> testSmartLogin() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🧠 开始智能登录测试...');

    // 1. 首先测试不同的mutation格式
    addLog('🔍 第一步：测试不同的mutation格式...');
    try {
      final mutationResults = await LoginTester.testMutationFormats(
        'test@example.com',
        'kpyu1512',
      );

      final mutationReport = LoginTester.generateMutationReport(
        mutationResults,
      );
      final reportLines = mutationReport.split('\n');
      for (String line in reportLines) {
        if (line.trim().isNotEmpty) {
          addLog(line);
        }
      }

      // 检查是否有成功的mutation
      bool foundWorkingMutation = false;
      mutationResults.forEach((key, value) {
        if (value['success'] == true) {
          foundWorkingMutation = true;
          addLog('✅ 找到工作的mutation: $key');
        }
      });

      if (foundWorkingMutation) {
        addLog('🎉 Mutation格式正常，问题可能是凭据！');
      } else {
        addLog('❌ 所有mutation格式都失败');
      }
    } catch (e) {
      addLog('❌ Mutation测试出错: $e');
    }

    // 2. 然后测试不同的登录凭据
    addLog('\n🔍 第二步：测试不同的登录凭据...');
    try {
      final credentialsResults = await LoginTester.testLoginCredentials();

      final credentialsReport = LoginTester.generateLoginReport(
        credentialsResults,
      );
      final reportLines = credentialsReport.split('\n');
      for (String line in reportLines) {
        if (line.trim().isNotEmpty) {
          addLog(line);
        }
      }
    } catch (e) {
      addLog('❌ 凭据测试出错: $e');
    }

    // 3. 分析当前错误
    addLog('\n💡 当前错误分析:');
    addLog('   错误类型: "Cannot return null for non-nullable field"');
    addLog('   含义: GraphQL schema定义登录字段为非空，但服务器返回了null');
    addLog('   可能原因:');
    addLog('   1. 登录凭据不正确（用户名或密码错误）');
    addLog('   2. 数据库中没有匹配的用户');
    addLog('   3. 服务器端登录逻辑有问题');
    addLog('   4. GraphQL schema与实现不匹配');

    addLog('\n🔧 建议解决方案:');
    addLog('   1. 检查服务器端用户数据库是否有测试用户');
    addLog('   2. 查看服务器端登录mutation的实现');
    addLog('   3. 确认GraphQL schema的定义是否正确');
    addLog('   4. 尝试在服务器端直接测试登录功能');

    setState(() {
      isTesting = false;
    });

    addLog('🏁 智能登录测试完成');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络诊断'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: showCurrentConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('📋 显示当前配置'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isTesting ? null : testConnections,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isTesting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('测试中...'),
                          ],
                        )
                      : const Text('🔗 网络诊断'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isTesting ? null : scanPorts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('🔍 端口扫描'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isTesting ? null : testConfirmedEndpoint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('🎯 测试确认端点'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isTesting ? null : testMultipleEndpoints,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('🌐 测试多个端点'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isTesting ? null : testLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('🔐 测试登录'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginTestPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('🧪 登录测试页面'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isTesting ? null : runFullDiagnostics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('🔍 全面诊断 (推荐)'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isTesting ? null : testSmartLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('🧠 智能登录测试'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            logs.clear();
                          });
                        },
                        child: const Text('清空日志'),
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
                                  const SnackBar(content: Text('日志已复制到剪贴板')),
                                );
                              },
                        child: const Text('复制日志'),
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
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.black87,
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
                  } else if (log.contains('🔍') ||
                      log.contains('🔄') ||
                      log.contains('📍')) {
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
