/// 应用路由配置
///
/// 使用GoRouter实现声明式路由管理，支持深度链接、路由守卫等功能
library app_router;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../pages/home_page.dart';
import '../../pages/mall_page.dart';
import '../../pages/profile_page.dart';
import '../../pages/cart_page.dart';
import '../../pages/search_page.dart';
import '../../pages/product_detail_page.dart';
import '../../pages/order_list_page.dart';
import '../../pages/order_detail_page.dart';
import '../../pages/order_confirm_page.dart';
import '../../pages/address_select_page.dart';
import '../../pages/login_test_page.dart';
import '../../pages/debug_page.dart';
import '../../models/cart_models.dart';
import '../utils/logger.dart';

/// 应用路由配置类
class AppRouter {
  /// 路由配置
  static GoRouter get router => _router;

  /// 路由实例
  static final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: _routes,
    redirect: _redirect,
    errorBuilder: (context, state) => _buildErrorPage(context, state),
    observers: [_AppRouteObserver()],
  );

  /// 路由守卫 - 检查登录状态
  static String? _redirect(BuildContext context, GoRouterState state) {
    final appState = context.read<AppState>();
    final isLoggedIn = appState.isLoggedIn;
    final isGoingToLogin = state.matchedLocation == AppRoutes.login;

    // 需要登录的页面
    final protectedRoutes = [
      AppRoutes.orderList,
      AppRoutes.orderDetail,
      AppRoutes.orderConfirm,
    ];

    // 如果访问需要登录的页面但未登录，重定向到登录页面
    if (protectedRoutes.any(
          (route) => state.matchedLocation.startsWith(route),
        ) &&
        !isLoggedIn) {
      return AppRoutes.login;
    }

    // 如果已登录但访问登录页面，重定向到首页
    if (isGoingToLogin && isLoggedIn) {
      return AppRoutes.home;
    }

    return null;
  }

  /// 路由配置列表
  static List<RouteBase> get _routes => [
    // 主页面路由
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: AppRouteNames.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.mall,
          name: AppRouteNames.mall,
          builder: (context, state) => const MallPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: AppRouteNames.profile,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // 购物车页面
    GoRoute(
      path: AppRoutes.cart,
      name: AppRouteNames.cart,
      builder: (context, state) => const CartPage(),
    ),

    // 搜索页面
    GoRoute(
      path: AppRoutes.search,
      name: AppRouteNames.search,
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchPage(initialQuery: query);
      },
    ),

    // 商品详情页面
    GoRoute(
      path: AppRoutes.productDetail,
      name: AppRouteNames.productDetail,
      builder: (context, state) {
        final productId = state.pathParameters['productId']!;
        return ProductDetailPage(productId: productId);
      },
    ),

    // 订单相关页面
    GoRoute(
      path: AppRoutes.orderList,
      name: AppRouteNames.orderList,
      builder: (context, state) => const OrderListPage(),
      routes: [
        GoRoute(
          path: 'detail/:orderId',
          name: AppRouteNames.orderDetail,
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return OrderDetailPage(orderId: orderId);
          },
        ),
      ],
    ),

    // 订单确认页面
    GoRoute(
      path: AppRoutes.orderConfirm,
      name: AppRouteNames.orderConfirm,
      builder: (context, state) {
        final cartItems = state.extra as List<CartItem>?;
        return OrderConfirmPage(items: cartItems ?? []);
      },
    ),

    // 地址选择页面
    GoRoute(
      path: AppRoutes.addressSelect,
      name: AppRouteNames.addressSelect,
      builder: (context, state) => const AddressSelectPage(),
    ),

    // 登录页面
    GoRoute(
      path: AppRoutes.login,
      name: AppRouteNames.login,
      builder: (context, state) => const LoginTestPage(),
    ),

    // 调试页面（仅开发环境）
    GoRoute(
      path: AppRoutes.debug,
      name: AppRouteNames.debug,
      builder: (context, state) => const DebugPage(),
    ),
  ];

  /// 构建错误页面
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面错误')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '页面加载出错',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('错误信息: ${state.error}', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 路由路径常量
class AppRoutes {
  static const String home = '/';
  static const String mall = '/mall';
  static const String profile = '/profile';
  static const String cart = '/cart';
  static const String search = '/search';
  static const String productDetail = '/product/:productId';
  static const String orderList = '/orders';
  static const String orderDetail = '/orders/detail/:orderId';
  static const String orderConfirm = '/order-confirm';
  static const String addressSelect = '/address-select';
  static const String login = '/login';
  static const String debug = '/debug';
}

/// 路由名称常量
class AppRouteNames {
  static const String home = 'home';
  static const String mall = 'mall';
  static const String profile = 'profile';
  static const String cart = 'cart';
  static const String search = 'search';
  static const String productDetail = 'product-detail';
  static const String orderList = 'order-list';
  static const String orderDetail = 'order-detail';
  static const String orderConfirm = 'order-confirm';
  static const String addressSelect = 'address-select';
  static const String login = 'login';
  static const String debug = 'debug';
}

/// 路由扩展方法
extension AppRouterExtension on BuildContext {
  /// 跳转到商品详情页
  void goToProductDetail(String productId) {
    go('/product/$productId');
  }

  /// 跳转到订单详情页
  void goToOrderDetail(String orderId) {
    go('/orders/detail/$orderId');
  }

  /// 跳转到搜索页面
  void goToSearch([String? query]) {
    final path = query != null ? '/search?q=$query' : '/search';
    go(path);
  }

  /// 跳转到订单确认页面
  void goToOrderConfirm(List<String> cartItemIds) {
    go(AppRoutes.orderConfirm, extra: cartItemIds);
  }

  /// 检查是否在指定路由
  bool isCurrentRoute(String routeName) {
    return GoRouterState.of(this).name == routeName;
  }
}

/// 主屏幕包装器
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.child});

  final Widget child;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 根据当前路由更新底部导航栏索引
    final location = GoRouterState.of(context).matchedLocation;
    _updateCurrentIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: '商场'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }

  void _updateCurrentIndex(String location) {
    int newIndex = 0;
    if (location == AppRoutes.mall) {
      newIndex = 1;
    } else if (location == AppRoutes.profile) {
      newIndex = 2;
    }

    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.mall);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
    }
  }
}

/// 路由观察者
class _AppRouteObserver extends NavigatorObserver {
  static final Logger _logger = Logger.forTag('RouteObserver');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logger.info('Push: ${route.settings.name}');

    // 记录页面访问
    if (route.settings.name != null) {
      UserActionLogger.logPageView(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logger.info('Pop: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logger.info(
      'Replace: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _logger.info('Remove: ${route.settings.name}');
  }
}
