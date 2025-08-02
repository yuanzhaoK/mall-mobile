import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_home_mall/config/app_config.dart';
import 'package:flutter_home_mall/constants/app_strings.dart';
import 'package:flutter_home_mall/core/themes/app_theme.dart';
import 'package:flutter_home_mall/pages/cart_page.dart';
import 'package:flutter_home_mall/pages/home_page.dart';
import 'package:flutter_home_mall/pages/mall_page.dart';
import 'package:flutter_home_mall/pages/profile_page.dart';
import 'package:flutter_home_mall/pages/search_page.dart';
import 'package:flutter_home_mall/providers/app_state.dart';
import 'package:flutter_home_mall/providers/cart_state.dart';
import 'package:flutter_home_mall/providers/home_state.dart';
import 'package:flutter_home_mall/providers/mall_state.dart';
import 'package:flutter_home_mall/providers/order_state.dart';
import 'package:flutter_home_mall/providers/product_detail_state.dart';
import 'package:flutter_home_mall/providers/search_state.dart';
import 'package:flutter_home_mall/services/graphql_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 在开发模式下打印配置信息
  if (kDebugMode) {
    debugPrint('🚀 应用启动中...');
    debugPrint('📋 配置摘要: ${AppConfig.getConfigSummary()}');

    if (AppConfig.hasLocalConfig) {
      debugPrint('✅ 本地配置已加载');
    } else {
      debugPrint('⚠️ 未找到本地配置，使用默认配置');
      debugPrint(
        '💡 提示：复制 lib/config/local_config.dart.template 为 local_config.dart',
      );
    }
  }

  // 初始化GraphQL服务并加载保存的token
  await GraphQLService.loadToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => HomeState()),
        ChangeNotifierProvider(create: (_) => MallState()),
        ChangeNotifierProvider(create: (_) => CartState()),
        ChangeNotifierProvider(create: (_) => SearchState()),
        ChangeNotifierProvider(create: (_) => ProductDetailState()),
        ChangeNotifierProvider(create: (_) => OrderState()),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/cart': (context) => const CartPage(),
          '/search': (context) => const SearchPage(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MallPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化应用状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.tabHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: AppStrings.tabMall,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }
}
