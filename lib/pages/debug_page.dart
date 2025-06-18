import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/graphql_service.dart';
import '../utils/connection_tester.dart';
import '../utils/network_helper.dart';
import '../utils/port_scanner.dart';

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

  Future<void> testConnections() async {
    setState(() {
      isTesting = true;
      logs.clear();
    });

    addLog('🔍 开始网络诊断...');

    // 测试确认的端点
    const confirmedEndpoint = 'http://10.241.25.183:8082/graphql';
    addLog('📍 确认的端点: $confirmedEndpoint');

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
    final testEndpoints = [
      'http://10.241.25.183:8082/graphql',
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

    // 扫描你的IP的开放端口
    addLog('📡 扫描 10.241.25.183 开放端口 (8000-9000)...');
    final remoteOpenPorts = await PortScanner.scanPortRange(
      '10.241.25.183',
      8000,
      9000,
    );
    if (remoteOpenPorts.isNotEmpty) {
      addLog('✅ 10.241.25.183开放端口: ${remoteOpenPorts.join(', ')}');
    } else {
      addLog('❌ 10.241.25.183没有找到开放端口 (8000-9000)');
    }

    // 扫描GraphQL服务
    addLog('🔍 扫描GraphQL服务...');
    final graphqlServices = await PortScanner.scanForGraphQLServices(
      '10.241.25.183',
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

    addLog('🎯 测试确认的GraphQL端点...');

    const endpoint = 'http://10.241.25.183:8082/graphql';
    addLog('📍 端点: $endpoint');

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
    final endpoints = [
      'http://10.241.25.183:8082/graphql', // 原始地址
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
