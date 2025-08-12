import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/constants/app_strings.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/pages/address_manage_page.dart';
import 'package:flutter_home_mall/pages/favorites_page.dart';
import 'package:flutter_home_mall/pages/help_center_page.dart';
import 'package:flutter_home_mall/pages/order_list_page.dart';
import 'package:flutter_home_mall/pages/profile_edit_page.dart';
import 'package:flutter_home_mall/pages/settings_page.dart';
import 'package:flutter_home_mall/services/credentials_storage.dart';
import 'package:flutter_home_mall/services/graphql_service.dart';
import 'package:flutter_home_mall/widgets/login_dialog.dart';
import 'package:flutter_home_mall/widgets/menu_item.dart';

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

  Future<void> _checkLoginStatus() async {
    setState(() {
      isLoggedIn = GraphQLService.isLoggedIn;
    });

    // 如果已登录，获取用户信息
    if (isLoggedIn) {
      try {
        final user = await GraphQLService.getCurrentUser();
        if (user != null) {
          setState(() {
            currentUser = user;
            username = user.username;
          });
        }
      } catch (e) {
        debugPrint('获取用户信息失败: $e');
      }
    }
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

  Widget _buildUserInfoCard() => GestureDetector(
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
              backgroundImage: isLoggedIn && currentUser?.avatar != null
                  ? NetworkImage(currentUser!.avatar!)
                  : null,
              child: isLoggedIn && currentUser?.avatar == null
                  ? Text(
                      (currentUser?.username.isNotEmpty ?? false)
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
                  : isLoggedIn == false
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
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
      builder: (context) => LoginDialog(
        onLoginSuccess: (authResponse) {
          setState(() {
            isLoggedIn = true;
            currentUser = authResponse.user;
            username = authResponse.user.username;
            isLoading = false;
          });
        },
      ),
    );
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

  Future<void> _logout() async {
    try {
      // 显示加载状态
      setState(() {
        isLoading = true;
      });

      // 调用GraphQL注销API
      await GraphQLService.logout();

      // 清除保存的凭据
      await CredentialsStorage.clearCredentials();

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
