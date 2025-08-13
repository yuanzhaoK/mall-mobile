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
import 'package:flutter_home_mall/services/graphql_service.dart';
import 'package:flutter_home_mall/services/user_storage.dart';
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
  MemberLevel? memberLevel;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // 首先检查本地存储的用户数据
      final userData = await UserStorage.getUserData();
      final hasToken = GraphQLService.isLoggedIn;

      if (userData != null && hasToken) {
        // 有本地数据且有token，恢复用户状态
        setState(() {
          isLoggedIn = true;
          currentUser = userData.user;
          username = userData.user.username;
          memberLevel = userData.memberLevel;
        });
        debugPrint('🔐 已恢复用户状态: ${userData.user.username}');
        debugPrint('🔐 已恢复会员等级: ${userData.memberLevel?.displayName ?? "无"}');
      } else if (hasToken) {
        // 有token但无本地数据，尝试从服务器获取
        setState(() {
          isLoggedIn = true;
        });

        try {
          final user = await GraphQLService.getCurrentUser();
          if (user != null) {
            setState(() {
              currentUser = user;
              username = user.username;
            });
            // 保存到本地存储
            await UserStorage.saveUserData(user: user);
          }
        } catch (e) {
          debugPrint('从服务器获取用户信息失败: $e');
          // 如果获取失败，清除token和本地数据
          await GraphQLService.logout();
          await UserStorage.clearUserData();
          setState(() {
            isLoggedIn = false;
            currentUser = null;
            memberLevel = null;
            username = AppStrings.username;
          });
        }
      } else {
        // 无token，确保清除本地数据
        await UserStorage.clearUserData();
        setState(() {
          isLoggedIn = false;
          currentUser = null;
          memberLevel = null;
          username = AppStrings.username;
        });
      }
    } catch (e) {
      debugPrint('检查登录状态失败: $e');
      setState(() {
        isLoggedIn = false;
        currentUser = null;
        memberLevel = null;
        username = AppStrings.username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🔐 ProfilePage build - isLoggedIn: $isLoggedIn, username: $username',
    );
    debugPrint('🔐 ProfilePage build - memberLevel: $memberLevel');
    debugPrint(
      '🔐 ProfilePage build - memberLevel?.displayName: ${memberLevel?.displayName}',
    );
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
            const SizedBox(height: 16),

            // 会员详情卡片
            if (isLoggedIn && memberLevel != null) _buildMemberInfoCard(),
            if (isLoggedIn && memberLevel != null) const SizedBox(height: 16),

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
                    child: Builder(
                      builder: (context) {
                        final memberText = isLoggedIn
                            ? (memberLevel?.displayName ?? AppStrings.vipMember)
                            : '未登录用户';
                        debugPrint('🔐 UI显示会员文本: $memberText');
                        return Text(
                          memberText,
                          style: TextStyle(
                            fontSize: 14,
                            color: isLoggedIn
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
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

  /// 构建会员详情卡片
  Widget _buildMemberInfoCard() {
    if (memberLevel == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _getMemberColor(memberLevel!.color),
              _getMemberColor(memberLevel!.color).withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 会员等级标题
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    memberLevel!.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Lv.${memberLevel!.level}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (memberLevel!.slogan != null) ...[
                const SizedBox(height: 8),
                Text(
                  memberLevel!.slogan!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // 会员权益
              if (memberLevel!.benefits != null) _buildMemberBenefits(),

              // 会员信息
              const SizedBox(height: 16),
              _buildMemberStats(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建会员权益
  Widget _buildMemberBenefits() {
    final benefits = memberLevel!.benefits!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '会员权益',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            // 折扣权益
            ...?benefits.discounts?.map(_buildBenefitChip),
            // 特权
            ...?benefits.privileges?.map(_buildBenefitChip),
            // 服务
            ...?benefits.services?.map(_buildBenefitChip),
          ],
        ),
      ],
    );
  }

  /// 构建权益标签
  Widget _buildBenefitChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 构建会员统计信息
  Widget _buildMemberStats() {
    return Row(
      children: [
        if (memberLevel!.discountRate != null)
          Expanded(
            child: _buildStatItem(
              '折扣率',
              '${((1 - memberLevel!.discountRate!) * 100).toStringAsFixed(1)}折',
            ),
          ),
        if (memberLevel!.pointsRate != null)
          Expanded(
            child: _buildStatItem(
              '积分倍率',
              '${memberLevel!.pointsRate!.toStringAsFixed(1)}x',
            ),
          ),
        if (currentUser?.points != null)
          Expanded(child: _buildStatItem('当前积分', '${currentUser!.points}')),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// 获取会员等级颜色
  Color _getMemberColor(String? color) {
    if (color == null) return AppColors.primary;

    try {
      // 处理十六进制颜色值
      if (color.startsWith('#')) {
        return Color(int.parse(color.replaceFirst('#', '0xFF')));
      }
      return AppColors.primary;
    } catch (e) {
      return AppColors.primary;
    }
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
      builder: (context) => LoginDialog(
        onLoginSuccess: (authResponse) async {
          debugPrint('🔐 ProfilePage收到登录成功回调: ${authResponse.user.username}');

          // 保存用户数据到本地存储
          await UserStorage.saveUserData(
            user: authResponse.user,
            memberLevel: authResponse.memberLevel,
          );

          setState(() {
            isLoggedIn = true;
            currentUser = authResponse.user;
            username = authResponse.user.username;
            memberLevel = authResponse.memberLevel;
            isLoading = false;
          });
          debugPrint(
            '🔐 ProfilePage状态已更新: isLoggedIn=$isLoggedIn, username=$username',
          );
          debugPrint('🔐 会员等级信息: ${memberLevel?.displayName ?? "无等级信息"}');
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

      // 清除用户数据（保留记住的账号密码）
      await UserStorage.clearUserData();
      debugPrint('🔐 退出登录：已清除用户数据，保留记住的账号密码');

      // 更新本地状态
      setState(() {
        isLoggedIn = false;
        currentUser = null;
        memberLevel = null;
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
