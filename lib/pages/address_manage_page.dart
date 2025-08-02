import 'package:flutter/material.dart';

import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/core/themes/app_theme.dart';
import 'package:flutter_home_mall/widgets/simple_app_bar.dart';

/// 地址模型
class Address {
  Address({
    required this.id,
    required this.receiverName,
    required this.receiverPhone,
    required this.province,
    required this.city,
    required this.district,
    required this.detailAddress,
    this.isDefault = false,
  });
  final String id;
  final String receiverName;
  final String receiverPhone;
  final String province;
  final String city;
  final String district;
  final String detailAddress;
  final bool isDefault;

  String get fullAddress => '$province$city$district$detailAddress';
}

/// 收货地址管理页面
class AddressManagePage extends StatefulWidget {
  const AddressManagePage({super.key});

  @override
  State<AddressManagePage> createState() => _AddressManagePageState();
}

class _AddressManagePageState extends State<AddressManagePage> {
  List<Address> addresses = [
    Address(
      id: '1',
      receiverName: '张三',
      receiverPhone: '13800138000',
      province: '广东省',
      city: '深圳市',
      district: '南山区',
      detailAddress: '科技园南区深南大道9999号',
      isDefault: true,
    ),
    Address(
      id: '2',
      receiverName: '李四',
      receiverPhone: '13900139000',
      province: '北京市',
      city: '北京市',
      district: '朝阳区',
      detailAddress: '建国门外大街1号',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: '收货地址', showBackButton: true),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 地址列表
          Expanded(
            child: addresses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      return _buildAddressCard(addresses[index], index);
                    },
                  ),
          ),

          // 添加新地址按钮
          _buildAddButton(),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无收货地址',
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '添加收货地址，享受便捷购物体验',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建地址卡片
  Widget _buildAddressCard(Address address, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 地址信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 收件人信息
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            address.receiverName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            address.receiverPhone,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 默认地址标签
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '默认',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // 详细地址
                Text(
                  address.fullAddress,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // 操作按钮
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // 设为默认
                if (!address.isDefault)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.star_border,
                      label: '设为默认',
                      onTap: () => _setDefaultAddress(index),
                    ),
                  ),

                // 编辑
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit_outlined,
                    label: '编辑',
                    onTap: () => _editAddress(address),
                    showBorder: !address.isDefault,
                  ),
                ),

                // 删除
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete_outline,
                    label: '删除',
                    onTap: () => _deleteAddress(index),
                    textColor: AppColors.error,
                    showBorder: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
    bool showBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  left: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor ?? AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: textColor ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建添加按钮
  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _addNewAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              '添加新地址',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  /// 设置默认地址
  void _setDefaultAddress(int index) {
    setState(() {
      // 清除所有默认状态
      for (var i = 0; i < addresses.length; i++) {
        addresses[i] = Address(
          id: addresses[i].id,
          receiverName: addresses[i].receiverName,
          receiverPhone: addresses[i].receiverPhone,
          province: addresses[i].province,
          city: addresses[i].city,
          district: addresses[i].district,
          detailAddress: addresses[i].detailAddress,
          isDefault: i == index,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已设为默认地址'), backgroundColor: Colors.green),
    );
  }

  /// 编辑地址
  void _editAddress(Address address) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('地址编辑功能即将推出'), backgroundColor: Colors.blue),
    );
  }

  /// 删除地址
  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除地址'),
        content: const Text('确定要删除这个收货地址吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                addresses.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('地址已删除'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  /// 添加新地址
  void _addNewAddress() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加地址功能即将推出'), backgroundColor: Colors.blue),
    );
  }
}
