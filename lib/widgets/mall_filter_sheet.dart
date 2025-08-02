import 'package:flutter/material.dart';
import 'package:flutter_home_mall/providers/mall_state.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';

/// 商场筛选面板
class MallFilterSheet extends StatefulWidget {
  const MallFilterSheet({super.key, required this.mallState});
  final MallState mallState;

  @override
  State<MallFilterSheet> createState() => _MallFilterSheetState();
}

class _MallFilterSheetState extends State<MallFilterSheet> {
  late String _selectedCategoryId;
  late double _minPrice;
  late double _maxPrice;
  late String _sortBy;
  late bool _hasDiscount;

  @override
  void initState() {
    super.initState();
    // 初始化当前筛选条件
    _selectedCategoryId = widget.mallState.selectedCategoryId;
    _minPrice = widget.mallState.minPrice;
    _maxPrice = widget.mallState.maxPrice;
    _sortBy = widget.mallState.sortBy;
    _hasDiscount = widget.mallState.hasDiscount;
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
                  // 商品分类
                  _buildCategorySection(),

                  const SizedBox(height: 24),

                  // 价格范围
                  _buildPriceRangeSection(),

                  const SizedBox(height: 24),

                  // 排序方式
                  _buildSortSection(),

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '筛选',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: Colors.grey[600]),
          ),
        ],
      ),
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
            _buildCategoryChip('全部分类', ''),
            ...widget.mallState.categories.map(
              (category) => _buildCategoryChip(category.name, category.id),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建分类选项
  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategoryId == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('至'),
            ),
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

        // 快捷价格选项
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPriceChip('100以下', 0, 100),
            _buildPriceChip('100-500', 100, 500),
            _buildPriceChip('500-1000', 500, 1000),
            _buildPriceChip('1000-3000', 1000, 3000),
            _buildPriceChip('3000-10000', 3000, 10000),
            _buildPriceChip('10000以上', 10000, 50000),
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

        // 折扣筛选
        Row(
          children: [
            Checkbox(
              value: _hasDiscount,
              onChanged: (value) {
                setState(() {
                  _hasDiscount = value ?? false;
                });
              },
              activeColor: AppColors.primary,
            ),
            const Text('仅显示有折扣商品'),
          ],
        ),
      ],
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // 重置按钮
          Expanded(
            child: OutlinedButton(
              onPressed: _resetFilters,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text(
                '重置',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 确认按钮
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('确认'),
            ),
          ),
        ],
      ),
    );
  }

  /// 重置筛选条件
  void _resetFilters() {
    setState(() {
      _selectedCategoryId = '';
      _minPrice = 0;
      _maxPrice = 10000;
      _sortBy = 'default';
      _hasDiscount = false;
    });
  }

  /// 应用筛选条件
  void _applyFilters() {
    widget.mallState.setFilters(
      categoryId: _selectedCategoryId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sortBy: _sortBy,
      hasDiscount: _hasDiscount,
    );

    Navigator.pop(context);
  }
}
