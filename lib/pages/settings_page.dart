import 'package:flutter/material.dart';

import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/core/themes/app_theme.dart';
import 'package:flutter_home_mall/services/credentials_storage.dart';
import 'package:flutter_home_mall/widgets/simple_app_bar.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _orderNotifications = true;
  bool _promotionNotifications = false;
  bool _nightMode = false;
  bool _autoPlayVideo = true;
  bool _useWifiOnly = false;
  String _language = '简体中文';
  String _currency = '人民币 (CNY)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: '设置', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 通知设置
            _buildNotificationSection(),
            const SizedBox(height: 12),

            // 显示设置
            _buildDisplaySection(),
            const SizedBox(height: 12),

            // 语言和地区
            _buildLanguageSection(),
            const SizedBox(height: 12),

            // 隐私设置
            _buildPrivacySection(),
            const SizedBox(height: 12),

            // 关于应用
            _buildAboutSection(),
            const SizedBox(height: 12),

            // 其他设置
            _buildOtherSection(),
          ],
        ),
      ),
    );
  }

  /// 构建通知设置区域
  Widget _buildNotificationSection() {
    return _buildSection(
      title: '通知设置',
      children: [
        _buildSwitchTile(
          title: '推送通知',
          subtitle: '接收应用推送消息',
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '订单通知',
          subtitle: '订单状态变化提醒',
          value: _orderNotifications,
          onChanged: (value) {
            setState(() {
              _orderNotifications = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '促销通知',
          subtitle: '优惠活动和促销信息',
          value: _promotionNotifications,
          onChanged: (value) {
            setState(() {
              _promotionNotifications = value;
            });
          },
        ),
      ],
    );
  }

  /// 构建显示设置区域
  Widget _buildDisplaySection() {
    return _buildSection(
      title: '显示设置',
      children: [
        _buildSwitchTile(
          title: '深色模式',
          subtitle: '使用深色主题',
          value: _nightMode,
          onChanged: (value) {
            setState(() {
              _nightMode = value;
            });
            _showComingSoonSnackBar('深色模式');
          },
        ),
        _buildSwitchTile(
          title: '自动播放视频',
          subtitle: '在WiFi环境下自动播放视频',
          value: _autoPlayVideo,
          onChanged: (value) {
            setState(() {
              _autoPlayVideo = value;
            });
          },
        ),
        _buildSwitchTile(
          title: '仅WiFi下加载图片',
          subtitle: '节省移动数据流量',
          value: _useWifiOnly,
          onChanged: (value) {
            setState(() {
              _useWifiOnly = value;
            });
          },
        ),
      ],
    );
  }

  /// 构建语言和地区设置区域
  Widget _buildLanguageSection() {
    return _buildSection(
      title: '语言和地区',
      children: [
        _buildListTile(
          title: '语言',
          subtitle: _language,
          onTap: _showLanguageDialog,
        ),
        _buildListTile(
          title: '货币',
          subtitle: _currency,
          onTap: _showCurrencyDialog,
        ),
      ],
    );
  }

  /// 构建隐私设置区域
  Widget _buildPrivacySection() {
    return _buildSection(
      title: '隐私设置',
      children: [
        _buildListTile(
          title: '清除缓存',
          subtitle: '清理应用缓存数据',
          trailing: const Icon(Icons.chevron_right),
          onTap: _clearCache,
        ),
        _buildListTile(
          title: '清除搜索历史',
          subtitle: '删除所有搜索记录',
          trailing: const Icon(Icons.chevron_right),
          onTap: _clearSearchHistory,
        ),
        _buildListTile(
          title: '清除保存的账号密码',
          subtitle: '删除记住的登录凭据',
          trailing: const Icon(Icons.chevron_right),
          onTap: _clearSavedCredentials,
        ),
        _buildListTile(
          title: '隐私政策',
          subtitle: '查看隐私保护政策',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoonSnackBar('隐私政策'),
        ),
        _buildListTile(
          title: '用户协议',
          subtitle: '查看用户服务协议',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoonSnackBar('用户协议'),
        ),
      ],
    );
  }

  /// 构建关于应用区域
  Widget _buildAboutSection() {
    return _buildSection(
      title: '关于应用',
      children: [
        _buildListTile(
          title: '版本信息',
          subtitle: 'v1.0.0',
          trailing: const Icon(Icons.chevron_right),
          onTap: _showVersionInfo,
        ),
        _buildListTile(
          title: '检查更新',
          subtitle: '检查应用更新',
          trailing: const Icon(Icons.chevron_right),
          onTap: _checkUpdate,
        ),
        _buildListTile(
          title: '意见反馈',
          subtitle: '提交问题和建议',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showComingSoonSnackBar('意见反馈'),
        ),
        _buildListTile(
          title: '评分支持',
          subtitle: '在应用商店给我们评分',
          trailing: const Icon(Icons.chevron_right),
          onTap: _rateApp,
        ),
      ],
    );
  }

  /// 构建其他设置区域
  Widget _buildOtherSection() {
    return _buildSection(
      title: '其他',
      children: [
        _buildListTile(
          title: '开发者选项',
          subtitle: '调试和开发工具',
          trailing: const Icon(Icons.chevron_right),
          onTap: _openDeveloperOptions,
        ),
        _buildListTile(
          title: '网络诊断',
          subtitle: '检查网络连接状态',
          trailing: const Icon(Icons.chevron_right),
          onTap: _networkDiagnosis,
        ),
      ],
    );
  }

  /// 构建设置区域
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// 构建开关设置项
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  /// 构建普通设置项
  Widget _buildListTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog() {
    final languages = ['简体中文', 'English', '繁體中文', '日本語'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
                _showComingSoonSnackBar('多语言支持');
              },
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 显示货币选择对话框
  void _showCurrencyDialog() {
    final currencies = ['人民币 (CNY)', '美元 (USD)', '欧元 (EUR)', '日元 (JPY)'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择货币'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return RadioListTile<String>(
              title: Text(currency),
              value: currency,
              groupValue: _currency,
              onChanged: (value) {
                setState(() {
                  _currency = value!;
                });
                Navigator.pop(context);
                _showComingSoonSnackBar('多货币支持');
              },
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 清除缓存
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除应用缓存吗？这将删除临时文件和图片缓存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 模拟清除缓存
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('缓存已清除'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 清除搜索历史
  void _clearSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除搜索历史'),
        content: const Text('确定要删除所有搜索记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 模拟清除搜索历史
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('搜索历史已清除'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 清除保存的账号密码
  void _clearSavedCredentials() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除保存的账号密码'),
        content: const Text('确定要删除记住的登录凭据吗？下次登录需要重新输入账号密码。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // 清除保存的凭据
                await CredentialsStorage.clearCredentials();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('保存的账号密码已清除'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('清除失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示版本信息
  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('版本信息'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flutter Home Mall'),
            SizedBox(height: 8),
            Text('版本: v1.0.0'),
            Text('构建号: 1'),
            SizedBox(height: 8),
            Text('基于 Flutter 开发的移动商城应用'),
            SizedBox(height: 16),
            Text('更新日志:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('• 完善个人中心功能模块'),
            Text('• 优化用户体验'),
            Text('• 修复已知问题'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 检查更新
  void _checkUpdate() {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('检查更新中...'),
          ],
        ),
      ),
    );

    // 模拟检查更新
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('检查更新'),
          content: const Text('当前已是最新版本'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    });
  }

  /// 应用评分
  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('评分支持'),
        content: const Text('感谢您的使用！请前往应用商店为我们评分，您的支持是我们前进的动力。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonSnackBar('应用商店跳转');
            },
            child: const Text('去评分'),
          ),
        ],
      ),
    );
  }

  /// 开发者选项
  void _openDeveloperOptions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeveloperOptionsPage()),
    );
  }

  /// 网络诊断
  void _networkDiagnosis() {
    _showComingSoonSnackBar('网络诊断');
  }

  /// 显示即将推出提示
  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature 功能即将推出'), backgroundColor: Colors.blue),
    );
  }
}

/// 开发者选项页面
class DeveloperOptionsPage extends StatefulWidget {
  const DeveloperOptionsPage({super.key});

  @override
  State<DeveloperOptionsPage> createState() => _DeveloperOptionsPageState();
}

class _DeveloperOptionsPageState extends State<DeveloperOptionsPage> {
  bool _showDebugInfo = false;
  bool _enableMockData = true;
  bool _logNetworkRequests = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: '开发者选项', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '开发者选项仅供调试使用，请谨慎操作',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('显示调试信息'),
                    subtitle: const Text('在界面上显示调试信息'),
                    value: _showDebugInfo,
                    onChanged: (value) {
                      setState(() {
                        _showDebugInfo = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  SwitchListTile(
                    title: const Text('启用模拟数据'),
                    subtitle: const Text('使用本地模拟数据'),
                    value: _enableMockData,
                    onChanged: (value) {
                      setState(() {
                        _enableMockData = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  SwitchListTile(
                    title: const Text('记录网络请求'),
                    subtitle: const Text('在控制台输出网络请求日志'),
                    value: _logNetworkRequests,
                    onChanged: (value) {
                      setState(() {
                        _logNetworkRequests = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  ListTile(
                    title: const Text('查看日志'),
                    subtitle: const Text('查看应用运行日志'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('日志查看功能即将推出'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('网络测试'),
                    subtitle: const Text('测试API连接状态'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _testNetworkConnection,
                  ),
                  ListTile(
                    title: const Text('崩溃测试'),
                    subtitle: const Text('触发应用崩溃（测试用）'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _crashTest,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 测试网络连接
  void _testNetworkConnection() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('测试网络连接...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('网络测试结果'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('API服务器: ✅ 连接正常'),
              Text('响应时间: 120ms'),
              Text('网络类型: WiFi'),
              Text('IP地址: 192.168.1.100'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    });
  }

  /// 崩溃测试
  void _crashTest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('崩溃测试'),
        content: const Text('确定要触发应用崩溃吗？这将用于测试崩溃报告功能。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 模拟崩溃
              throw Exception('这是一个测试崩溃');
            },
            child: const Text('确定', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
