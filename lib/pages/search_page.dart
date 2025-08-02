import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_home_mall/providers/search_state.dart';

import 'package:flutter_home_mall/widgets/product_card.dart';
import 'package:flutter_home_mall/widgets/search_filter_sheet.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';

import 'package:flutter_home_mall/models/api_models.dart';

/// 搜索页面
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, this.initialQuery}) : super(key: key);
  final String? initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _searchFocusNode = FocusNode();

    // 初始化搜索状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchState = context.read<SearchState>();
      searchState.initializeHotSearches();

      // 如果有初始查询，立即搜索
      if (widget.initialQuery?.isNotEmpty == true) {
        searchState.searchProducts(widget.initialQuery!);
      }
    });

    // 监听搜索框焦点变化
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            _buildSearchBar(),

            // 主体内容
            Expanded(
              child: Consumer<SearchState>(
                builder: (context, searchState, child) {
                  if (_showSuggestions) {
                    return _buildSuggestions(searchState);
                  }

                  if (!searchState.hasSearched) {
                    return _buildInitialState(searchState);
                  }

                  if (searchState.isLoading) {
                    return _buildLoadingState();
                  }

                  if (searchState.error != null) {
                    return _buildErrorState(searchState);
                  }

                  if (!searchState.hasResults) {
                    return _buildNoResultsState(searchState);
                  }

                  return _buildSearchResults(searchState);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),

          const SizedBox(width: 8),

          // 搜索框
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: '搜索商品、品牌、店铺',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchState>().clearSearch();
                            setState(() {
                              _showSuggestions = false;
                            });
                          },
                          icon: Icon(
                            Icons.clear,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {
                    _showSuggestions =
                        value.isNotEmpty && _searchFocusNode.hasFocus;
                  });
                },
                onSubmitted: _performSearch,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 搜索按钮
          Consumer<SearchState>(
            builder: (context, searchState, child) {
              return TextButton(
                onPressed: () => _performSearch(_searchController.text),
                child: const Text(
                  '搜索',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建搜索建议
  Widget _buildSuggestions(SearchState searchState) {
    final suggestions = searchState.getSearchSuggestions(
      _searchController.text,
    );

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            leading: Icon(
              searchState.searchHistory.contains(suggestion)
                  ? Icons.history
                  : Icons.trending_up,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            title: Text(suggestion),
            onTap: () {
              _searchController.text = suggestion;
              _performSearch(suggestion);
            },
          );
        },
      ),
    );
  }

  /// 构建初始状态（搜索历史和热门搜索）
  Widget _buildInitialState(SearchState searchState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索历史
          if (searchState.searchHistory.isNotEmpty) ...[
            _buildSectionHeader(
              '搜索历史',
              onClear: () {
                searchState.clearSearchHistory();
              },
            ),
            const SizedBox(height: 12),
            _buildHistoryTags(searchState),
            const SizedBox(height: 24),
          ],

          // 热门搜索
          _buildSectionHeader('热门搜索'),
          const SizedBox(height: 12),
          _buildHotSearchTags(searchState),
        ],
      ),
    );
  }

  /// 构建区域标题
  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: Text(
              '清空',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建搜索历史标签
  Widget _buildHistoryTags(SearchState searchState) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: searchState.searchHistory.map((query) {
        return _buildTag(
          query,
          onTap: () => _performSearch(query),
          onDelete: () => searchState.removeFromHistory(query),
        );
      }).toList(),
    );
  }

  /// 构建热门搜索标签
  Widget _buildHotSearchTags(SearchState searchState) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: searchState.hotSearches.map((query) {
        return _buildTag(
          query,
          onTap: () => _performSearch(query),
          isHot: true,
        );
      }).toList(),
    );
  }

  /// 构建标签
  Widget _buildTag(
    String text, {
    required VoidCallback onTap,
    VoidCallback? onDelete,
    bool isHot = false,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isHot
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isHot
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHot) ...[
              const Icon(
                Icons.local_fire_department,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: TextStyle(
                color: isHot
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: isHot ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults(SearchState searchState) {
    return Column(
      children: [
        // 结果统计和筛选栏
        _buildResultsHeader(searchState),

        // 商品列表
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: searchState.searchResults.length,
            itemBuilder: (context, index) {
              final product = searchState.searchResults[index];
              return ProductCard(
                product: product,
                onTap: () => _handleProductTap(product),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建结果头部
  Widget _buildResultsHeader(SearchState searchState) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // 结果统计
          Expanded(
            child: Text(
              '找到 ${searchState.searchResults.length} 个商品',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // 筛选按钮
          TextButton.icon(
            onPressed: () => _showFilterSheet(searchState),
            icon: Icon(
              Icons.tune,
              size: 18,
              color: searchState.hasActiveFilters
                  ? AppColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            label: Text(
              '筛选',
              style: TextStyle(
                color: searchState.hasActiveFilters
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在搜索...'),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(SearchState searchState) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('搜索出错了', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              searchState.error ?? '未知错误',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                searchState.clearError();
                _performSearch(_searchController.text);
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建无结果状态
  Widget _buildNoResultsState(SearchState searchState) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到相关商品',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试其他关键词或调整筛选条件',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    searchState.clearSearch();
                    _searchFocusNode.requestFocus();
                  },
                  child: const Text('重新搜索'),
                ),
                const SizedBox(width: 12),
                if (searchState.hasActiveFilters)
                  FilledButton(
                    onPressed: () {
                      searchState.clearFilters();
                    },
                    child: const Text('清除筛选'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 执行搜索
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    _searchController.text = query;
    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });

    context.read<SearchState>().searchProducts(query);
  }

  /// 显示筛选面板
  void _showFilterSheet(SearchState searchState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterSheet(searchState: searchState),
    );
  }

  /// 处理商品点击
  void _handleProductTap(Product product) {
    // TODO: 跳转到商品详情页
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('点击商品: ${product.name}')));
  }
}
