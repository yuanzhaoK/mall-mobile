import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'pages/home_page.dart';
import 'pages/mall_page.dart';
import 'pages/profile_page.dart';
import 'services/graphql_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化GraphQL服务并加载保存的token
  await GraphQLService.loadToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
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
