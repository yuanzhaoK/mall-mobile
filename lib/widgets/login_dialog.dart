import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/services/credentials_storage.dart';
import 'package:flutter_home_mall/services/graphql_service.dart';

/// 登录对话框组件
class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key, required this.onLoginSuccess});

  final Function(AuthResponse) onLoginSuccess;

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 加载保存的凭据
  Future<void> _loadSavedCredentials() async {
    final savedCredentials = await CredentialsStorage.loadCredentials();
    if (savedCredentials != null) {
      setState(() {
        _usernameController.text = savedCredentials.username;
        _passwordController.text = savedCredentials.password;
        _rememberCredentials = savedCredentials.remember;
      });
    }
  }

  /// 执行登录
  Future<void> _performLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 输入验证
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入用户名和密码'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 调用GraphQL登录API
      final authResponse = await GraphQLService.login(username, password);

      if (authResponse != null) {
        // 保存凭据（如果用户选择记住）
        await CredentialsStorage.saveCredentials(
          username: username,
          password: password,
          remember: _rememberCredentials,
        );

        // 登录成功回调
        widget.onLoginSuccess(authResponse);

        // 关闭对话框
        if (mounted) Navigator.pop(context);

        // 显示成功消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('欢迎回来，${authResponse.user.username}！'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('登录失败：未知错误');
      }
    } catch (e) {
      // 登录失败
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖拽指示器
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '用户登录',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // 登录表单
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 用户名输入框
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: '用户名/手机号',
                      hintText: '请输入用户名或手机号',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 密码输入框
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '密码',
                      hintText: '请输入密码',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 记住密码选项
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberCredentials,
                        onChanged: (value) {
                          setState(() {
                            _rememberCredentials = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Text(
                        '记住账号密码',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // 忘记密码
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('忘记密码功能')),
                          );
                        },
                        child: const Text(
                          '忘记密码?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _performLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              '登录',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 快速登录选项
                  const Text(
                    '其他登录方式',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 15),

                  // 其他登录按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialLoginButton(
                        icon: Icons.wechat,
                        label: '微信',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('微信登录功能')),
                          );
                        },
                      ),
                      _buildSocialLoginButton(
                        icon: Icons.phone_android,
                        label: '手机',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('手机验证码登录功能')),
                          );
                        },
                      ),
                      _buildSocialLoginButton(
                        icon: Icons.more_horiz,
                        label: '更多',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('更多登录方式')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 注册提示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '还没有账号？',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(const SnackBar(content: Text('注册功能')));
                        },
                        child: const Text(
                          '立即注册',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
