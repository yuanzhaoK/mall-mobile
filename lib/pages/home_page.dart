import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/data_source.dart';
import '../models/api_models.dart';
import '../services/graphql_service.dart';
import '../widgets/feature_button.dart';
import '../widgets/selection_row.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/featured_product_card.dart';
import 'debug_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedHouseType = AppStrings.defaultHouseType;
  String selectedPackage = AppStrings.defaultPackage;

  // API数据状态
  AppHomeData? homeData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // 加载首页数据
  Future<void> _loadHomeData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await GraphQLService.getHomeData();

      setState(() {
        homeData = data;
        isLoading = false;
        if (data == null) {
          errorMessage = '加载数据失败，请检查网络连接';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '加载数据时出现错误: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部黄色区域
            Container(
              height: 380,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryGradient1,
                    AppColors.primaryGradient2,
                    AppColors.primaryGradient1,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 品牌信息
                      _buildBrandHeader(),
                      const SizedBox(height: 35),

                      // 功能按钮
                      _buildFeatureButtons(),
                      const SizedBox(height: 35),

                      // 选择区域
                      _buildSelectionArea(),
                    ],
                  ),
                ),
              ),
            ),

            // 底部推荐区域
            _buildRecommendationSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DebugPage()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Z',
              style: TextStyle(
                color: AppColors.background,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appTitle,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              AppStrings.appSlogan,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FeatureButton(
          icon: Icons.card_giftcard,
          label: AppStrings.allPackages,
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('全部礼包功能')));
          },
        ),
        FeatureButton(
          icon: Icons.lightbulb_outline,
          label: AppStrings.designInspiration,
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('装修灵感功能')));
          },
        ),
      ],
    );
  }

  Widget _buildSelectionArea() {
    return Container(
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SelectionRow(label: AppStrings.houseType, value: selectedHouseType),
          const SizedBox(height: 18),
          SelectionRow(
            label: AppStrings.selectedPackage,
            value: selectedPackage,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _showPackageSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 3,
              ),
              child: const Text(
                AppStrings.selectPackage,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '精选推荐',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (errorMessage != null)
                IconButton(
                  onPressed: _loadHomeData,
                  icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (isLoading)
            _buildLoadingState()
          else if (errorMessage != null)
            _buildErrorState()
          else if (homeData?.featuredProducts.isNotEmpty == true)
            _buildFeaturedProducts()
          else
            _buildFallbackRecommendations(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600], size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHomeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('重新加载'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '显示默认推荐:',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        _buildFallbackRecommendations(),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    final products = homeData!.featuredProducts
        .where((p) => p.name.isNotEmpty)
        .take(10)
        .toList();

    return Column(
      children: [
        // 显示分类信息
        if (homeData!.categories.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryGradient1.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '商品分类',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: homeData!.categories
                      .take(6)
                      .map(
                        (category) => Chip(
                          label: Text(
                            category.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: AppColors.primaryGradient1.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

        // 精选产品列表
        ...products.map((product) => FeaturedProductCard(product: product)),

        // 显示产品统计
        if (homeData!.featuredProducts.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${homeData!.featuredProducts.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGradient1,
                      ),
                    ),
                    const Text(
                      '总商品数',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${homeData!.categories.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGradient1,
                      ),
                    ),
                    const Text(
                      '商品分类',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackRecommendations() {
    final suites = DataSource.suites;

    return Column(
      children: suites
          .map(
            (suite) => Column(
              children: [
                RecommendationCard(
                  title: suite.title,
                  description: suite.description,
                  price: suite.price,
                  color: suite.color,
                ),
                if (suite != suites.last) const SizedBox(height: 16),
              ],
            ),
          )
          .toList(),
    );
  }

  void _showPackageSelection() {
    final packages = DataSource.packages;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.selectTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ...packages.map(
                (package) => ListTile(
                  leading: Icon(package.icon, color: package.color),
                  title: Text(
                    package.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(package.price),
                  onTap: () {
                    setState(() {
                      selectedPackage = package.name;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
