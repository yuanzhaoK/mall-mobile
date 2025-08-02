import 'package:flutter/material.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/providers/order_state.dart';
import 'package:provider/provider.dart';

/// 地址选择页面
class AddressSelectPage extends StatefulWidget {
  const AddressSelectPage({super.key});

  @override
  State<AddressSelectPage> createState() => _AddressSelectPageState();
}

class _AddressSelectPageState extends State<AddressSelectPage> {
  @override
  void initState() {
    super.initState();
    // 确保地址列表已加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderState = context.read<OrderState>();
      if (orderState.addresses.isEmpty) {
        orderState.loadAddresses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('选择收货地址'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _showAddAddressDialog,
            child: const Text(
              '新增',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<OrderState>(
        builder: (context, orderState, child) {
          if (orderState.isLoadingAddresses) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderState.addressError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    orderState.addressError!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderState.loadAddresses(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (orderState.addresses.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderState.addresses.length,
            itemBuilder: (context, index) {
              final address = orderState.addresses[index];
              final isSelected = orderState.selectedAddress?.id == address.id;

              return _buildAddressItem(address, isSelected, orderState);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无收货地址',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '请添加您的收货地址',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showAddAddressDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('添加地址'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(
    ShippingAddress address,
    bool isSelected,
    OrderState orderState,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          orderState.selectAddress(address);
          Navigator.pop(context, address);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          address.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          address.phone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '默认',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 选中状态
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 24,
                    )
                  else
                    Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                address.fullAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showEditAddressDialog(address);
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: const Text(
                      '编辑',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(60, 32),
                    ),
                  ),

                  const SizedBox(width: 16),

                  TextButton.icon(
                    onPressed: () {
                      _showDeleteConfirmDialog(address, orderState);
                    },
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text(
                      '删除',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(60, 32),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    _showAddressFormDialog(null);
  }

  void _showEditAddressDialog(ShippingAddress address) {
    _showAddressFormDialog(address);
  }

  void _showAddressFormDialog(ShippingAddress? address) {
    final isEdit = address != null;
    final nameController = TextEditingController(text: address?.name ?? '');
    final phoneController = TextEditingController(text: address?.phone ?? '');
    final provinceController = TextEditingController(
      text: address?.province ?? '',
    );
    final cityController = TextEditingController(text: address?.city ?? '');
    final districtController = TextEditingController(
      text: address?.district ?? '',
    );
    final addressController = TextEditingController(
      text: address?.address ?? '',
    );
    var isDefault = address?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? '编辑地址' : '添加地址'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '收货人姓名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '手机号码',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: provinceController,
                        decoration: const InputDecoration(
                          labelText: '省份',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: '城市',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: districtController,
                  decoration: const InputDecoration(
                    labelText: '区县',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '详细地址',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isDefault,
                      onChanged: (value) {
                        setState(() {
                          isDefault = value ?? false;
                        });
                      },
                    ),
                    const Text('设为默认地址'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_validateAddressForm(
                  nameController.text,
                  phoneController.text,
                  provinceController.text,
                  cityController.text,
                  districtController.text,
                  addressController.text,
                )) {
                  _saveAddress(
                    isEdit,
                    address?.id,
                    nameController.text,
                    phoneController.text,
                    provinceController.text,
                    cityController.text,
                    districtController.text,
                    addressController.text,
                    isDefault,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(isEdit ? '保存' : '添加'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateAddressForm(
    String name,
    String phone,
    String province,
    String city,
    String district,
    String address,
  ) {
    if (name.trim().isEmpty) {
      _showErrorSnackBar('请输入收货人姓名');
      return false;
    }
    if (phone.trim().isEmpty) {
      _showErrorSnackBar('请输入手机号码');
      return false;
    }
    if (province.trim().isEmpty) {
      _showErrorSnackBar('请输入省份');
      return false;
    }
    if (city.trim().isEmpty) {
      _showErrorSnackBar('请输入城市');
      return false;
    }
    if (district.trim().isEmpty) {
      _showErrorSnackBar('请输入区县');
      return false;
    }
    if (address.trim().isEmpty) {
      _showErrorSnackBar('请输入详细地址');
      return false;
    }
    return true;
  }

  void _saveAddress(
    bool isEdit,
    String? addressId,
    String name,
    String phone,
    String province,
    String city,
    String district,
    String address,
    bool isDefault,
  ) {
    final newAddress = ShippingAddress(
      id: addressId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      phone: phone.trim(),
      province: province.trim(),
      city: city.trim(),
      district: district.trim(),
      address: address.trim(),
      isDefault: isDefault,
    );

    final orderState = context.read<OrderState>();
    if (isEdit) {
      // TODO: 实现编辑地址功能
      _showErrorSnackBar('编辑地址功能开发中');
    } else {
      orderState.addAddress(newAddress);
    }
  }

  void _showDeleteConfirmDialog(
    ShippingAddress address,
    OrderState orderState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除地址'),
        content: Text('确定要删除"${address.name}"的收货地址吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              orderState.deleteAddress(address.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
