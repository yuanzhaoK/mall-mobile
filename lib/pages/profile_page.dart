import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/menu_item.dart';
import '../services/graphql_service.dart';
import '../models/api_models.dart';
import '../pages/order_list_page.dart';
import '../pages/profile_edit_page.dart';
import '../pages/address_manage_page.dart';
import '../pages/favorites_page.dart';
import '../pages/settings_page.dart';
import '../pages/help_center_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoggedIn = false;
  String username = AppStrings.username;
  User? currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    setState(() {
      isLoggedIn = GraphQLService.isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tabProfile),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户信息卡片
            _buildUserInfoCard(),
            const SizedBox(height: 20),

            // 功能列表
            _buildMenuItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return GestureDetector(
      onTap: () {
        if (!isLoggedIn) {
          _showLoginBottomSheet();
        } else {
          _navigateToProfileEdit();
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: isLoggedIn
                    ? Text(
                        (currentUser?.username.isNotEmpty == true)
                            ? currentUser!.username[0].toUpperCase()
                            : (username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : 'U'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLoggedIn ? (currentUser?.username ?? username) : '点击登录',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLoggedIn
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isLoggedIn ? AppStrings.vipMember : '未登录用户',
                        style: TextStyle(
                          fontSize: 14,
                          color: isLoggedIn
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isLoggedIn ? Icons.edit : Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        MenuItem(
          icon: Icons.shopping_cart,
          title: AppStrings.myOrders,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderListPage()),
            );
          },
        ),
        MenuItem(
          icon: Icons.favorite,
          title: AppStrings.myFavorites,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            );
          },
        ),
        MenuItem(
          icon: Icons.location_on,
          title: AppStrings.shippingAddress,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddressManagePage(),
              ),
            );
          },
        ),
        MenuItem(
          icon: Icons.support_agent,
          title: AppStrings.customerService,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerServicePage(),
              ),
            );
          },
        ),
        MenuItem(
          icon: Icons.settings,
          title: AppStrings.settings,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        MenuItem(
          icon: Icons.help,
          title: AppStrings.helpCenter,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterPage()),
            );
          },
        ),
        if (isLoggedIn)
          MenuItem(icon: Icons.logout, title: '退出登录', onTap: _logout),
      ],
    );
  }

  void _showLoginBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLoginBottomSheet(),
    );
  }

  Widget _buildLoginBottomSheet() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                    controller: usernameController,
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
                    controller: passwordController,
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
                  const SizedBox(height: 10),

                  // 忘记密码
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // 处理忘记密码
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('忘记密码功能')));
                      },
                      child: const Text('忘记密码?'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _performLogin(
                              usernameController.text,
                              passwordController.text,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickLoginButton(
                        icon: Icons.fingerprint,
                        label: '指纹登录',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('指纹登录功能')),
                          );
                        },
                      ),
                      _buildQuickLoginButton(
                        icon: Icons.face,
                        label: '面容登录',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('面容登录功能')),
                          );
                        },
                      ),
                      _buildQuickLoginButton(
                        icon: Icons.phone_android,
                        label: '短信登录',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('短信登录功能')),
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
                        child: const Text('立即注册'),
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

  Widget _buildQuickLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _performLogin(String identity, String password) async {
    // 输入验证
    if (identity.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入用户名和密码'), backgroundColor: Colors.red),
      );
      return;
    }

    // 显示加载状态
    setState(() {
      isLoading = true;
    });

    try {
      // 调用GraphQL登录API
      final authResponse = await GraphQLService.login(identity, password);

      if (authResponse != null) {
        // 登录成功
        setState(() {
          isLoggedIn = true;
          currentUser = authResponse.user;
          username = authResponse.user.username;
          isLoading = false;
        });

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('欢迎回来，${authResponse.user.username}！'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('登录失败：未知错误');
      }
    } catch (e) {
      // 登录失败
      setState(() {
        isLoading = false;
      });

      String errorMessage = '登录失败';
      if (e.toString().contains('Authentication failed')) {
        errorMessage = '用户名或密码错误，请检查后重试';
      } else if (e.toString().contains('Connection')) {
        errorMessage = '网络连接问题，请检查网络设置';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '无法连接到服务器，请稍后重试';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = '连接超时，请检查网络';
      } else {
        // 显示更详细的错误信息用于调试
        errorMessage = '登录失败: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '重试',
            textColor: Colors.white,
            onPressed: () => _performLogin(identity, password),
          ),
        ),
      );

      // 在开发环境中显示完整错误信息
      debugPrint('🔐 完整错误信息: $e');
    }
  }

  /// 导航到个人信息编辑页面
  void _navigateToProfileEdit() {
    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileEditPage(user: currentUser!),
        ),
      ).then((result) {
        if (result != null && result is User) {
          setState(() {
            currentUser = result;
            username = result.username;
          });
        }
      });
    }
  }

  void _logout() async {
    try {
      // 显示加载状态
      setState(() {
        isLoading = true;
      });

      // 调用GraphQL注销API
      await GraphQLService.logout();

      // 更新本地状态
      setState(() {
        isLoggedIn = false;
        currentUser = null;
        username = AppStrings.username;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已退出登录'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('退出登录失败: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
