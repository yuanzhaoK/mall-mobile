import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/providers/search_state.dart';

/// 搜索筛选面板
class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({super.key, required this.searchState});
  final SearchState searchState;

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late String _selectedCategory;
  late double _minPrice;
  late double _maxPrice;
  late String _sortBy;
  late bool _hasDiscount;

  @override
  void initState() {
    super.initState();
    // 初始化当前筛选条件
    _selectedCategory = widget.searchState.selectedCategory;
    _minPrice = widget.searchState.minPrice;
    _maxPrice = widget.searchState.maxPrice;
    _sortBy = widget.searchState.sortBy;
    _hasDiscount = widget.searchState.hasDiscount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildHeader(),

          // 筛选内容
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 价格范围
                  _buildPriceRangeSection(),

                  const SizedBox(height: 24),

                  // 排序方式
                  _buildSortSection(),

                  const SizedBox(height: 24),

                  // 分类筛选
                  _buildCategorySection(),

                  const SizedBox(height: 24),

                  // 其他筛选
                  _buildOtherFiltersSection(),

                  const SizedBox(height: 80), // 为底部按钮留空间
                ],
              ),
            ),
          ),

          // 底部按钮
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '筛选',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  /// 构建价格范围区域
  Widget _buildPriceRangeSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '价格范围',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // 价格输入框
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                label: '最低价',
                value: _minPrice,
                onChanged: (value) {
                  setState(() {
                    _minPrice = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '至',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPriceInput(
                label: '最高价',
                value: _maxPrice,
                onChanged: (value) {
                  setState(() {
                    _maxPrice = value;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 价格范围滑块
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            '¥${_minPrice.toStringAsFixed(0)}',
            '¥${_maxPrice.toStringAsFixed(0)}',
          ),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),

        const SizedBox(height: 8),

        // 快捷价格选项
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPriceChip('100以下', 0, 100),
            _buildPriceChip('100-500', 100, 500),
            _buildPriceChip('500-1000', 500, 1000),
            _buildPriceChip('1000-3000', 1000, 3000),
            _buildPriceChip('3000以上', 3000, 10000),
          ],
        ),
      ],
    );
  }

  /// 构建价格输入框
  Widget _buildPriceInput({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return TextField(
      controller: TextEditingController(
        text: value == 0 ? '' : value.toStringAsFixed(0),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '¥',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onChanged: (text) {
        final price = double.tryParse(text) ?? 0;
        onChanged(price);
      },
    );
  }

  /// 构建价格快捷选项
  Widget _buildPriceChip(String label, double min, double max) {
    final isSelected = _minPrice == min && _maxPrice == max;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _minPrice = min;
          _maxPrice = max;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  /// 构建排序区域
  Widget _buildSortSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '排序方式',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSortChip('综合排序', 'default'),
            _buildSortChip('价格从低到高', 'price_asc'),
            _buildSortChip('价格从高到低', 'price_desc'),
            _buildSortChip('销量优先', 'sales'),
            _buildSortChip('评分优先', 'rating'),
          ],
        ),
      ],
    );
  }

  /// 构建排序选项
  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  /// 构建分类区域
  Widget _buildCategorySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品分类',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip('全部', ''),
            _buildCategoryChip('手机数码', 'phone'),
            _buildCategoryChip('电脑办公', 'computer'),
            _buildCategoryChip('家用电器', 'appliance'),
            _buildCategoryChip('服饰内衣', 'clothing'),
            _buildCategoryChip('家居家装', 'home'),
            _buildCategoryChip('母婴', 'baby'),
            _buildCategoryChip('美妆', 'beauty'),
            _buildCategoryChip('个护健康', 'health'),
            _buildCategoryChip('食品饮料', 'food'),
            _buildCategoryChip('酒类', 'wine'),
            _buildCategoryChip('生鲜', 'fresh'),
          ],
        ),
      ],
    );
  }

  /// 构建分类选项
  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategory = value;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  /// 构建其他筛选区域
  Widget _buildOtherFiltersSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '其他筛选',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // 仅显示有折扣的商品
        SwitchListTile(
          title: const Text('仅显示有折扣的商品'),
          subtitle: const Text('筛选有优惠活动的商品'),
          value: _hasDiscount,
          onChanged: (value) {
            setState(() {
              _hasDiscount = value;
            });
          },
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButtons() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 重置按钮
            Expanded(
              child: OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('重置'),
              ),
            ),

            const SizedBox(width: 16),

            // 确认按钮
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _applyFilters,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('确认'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 重置筛选条件
  void _resetFilters() {
    setState(() {
      _selectedCategory = '';
      _minPrice = 0;
      _maxPrice = 10000;
      _sortBy = 'default';
      _hasDiscount = false;
    });
  }

  /// 应用筛选条件
  void _applyFilters() {
    widget.searchState.setFilters(
      category: _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sortBy: _sortBy,
      hasDiscount: _hasDiscount,
    );

    Navigator.of(context).pop();
  }
}
