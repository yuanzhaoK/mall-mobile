import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/order_state.dart';
import '../providers/cart_state.dart';
import '../models/api_models.dart';
import '../constants/app_colors.dart';
import '../pages/address_select_page.dart';
import '../pages/order_detail_page.dart';

/// 订单确认页面
class OrderConfirmPage extends StatefulWidget {
  final List<CartItem> items;

  const OrderConfirmPage({super.key, required this.items});

  @override
  State<OrderConfirmPage> createState() => _OrderConfirmPageState();
}

class _OrderConfirmPageState extends State<OrderConfirmPage> {
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 加载地址列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderState>().loadAddresses();
    });
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('确认订单'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<OrderState>(
        builder: (context, orderState, child) {
          return Column(
            children: [
              // 内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 收货地址
                      _buildAddressSection(orderState),

                      const SizedBox(height: 8),

                      // 商品列表
                      _buildProductList(),

                      const SizedBox(height: 8),

                      // 备注信息
                      _buildRemarkSection(),

                      const SizedBox(height: 8),

                      // 优惠券（预留）
                      _buildCouponSection(),

                      const SizedBox(height: 8),

                      // 价格明细
                      _buildPriceDetail(),

                      const SizedBox(height: 100), // 底部按钮空间
                    ],
                  ),
                ),
              ),

              // 底部提交按钮
              _buildBottomBar(orderState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressSection(OrderState orderState) {
    final address = orderState.selectedAddress;

    return Container(
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<ShippingAddress>(
            context,
            MaterialPageRoute(builder: (context) => const AddressSelectPage()),
          );
          if (result != null) {
            orderState.selectAddress(result);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),

              if (address != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '默认',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Text(
                    '请选择收货地址',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ],

              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.store, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '商城自营',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          ...widget.items.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          // 商品图片
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: CachedNetworkImage(
                imageUrl: item.product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 商品信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${item.unitPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '订单备注',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _remarkController,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '选填，请输入您要对商家说的话...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // TODO: 跳转到优惠券选择页面
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('优惠券功能开发中')));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.local_offer, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '优惠券',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '暂无可用',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceDetail() {
    final subtotal = widget.items.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final shippingFee = subtotal >= 99 ? 0.0 : 10.0;
    final discount = subtotal >= 300
        ? 50.0
        : subtotal >= 200
        ? 30.0
        : subtotal >= 100
        ? 15.0
        : 0.0;
    final total = subtotal + shippingFee - discount;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '价格明细',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _buildPriceRow('商品金额', '¥${subtotal.toStringAsFixed(2)}'),
          _buildPriceRow(
            '运费',
            shippingFee == 0 ? '免运费' : '¥${shippingFee.toStringAsFixed(2)}',
          ),
          if (discount > 0)
            _buildPriceRow(
              '优惠',
              '-¥${discount.toStringAsFixed(2)}',
              isDiscount: true,
            ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '实付款',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '¥${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDiscount ? Colors.red : Colors.black87,
              fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(OrderState orderState) {
    final subtotal = widget.items.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
    final shippingFee = subtotal >= 99 ? 0.0 : 10.0;
    final discount = subtotal >= 300
        ? 50.0
        : subtotal >= 200
        ? 30.0
        : subtotal >= 100
        ? 15.0
        : 0.0;
    final total = subtotal + shippingFee - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '实付款',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '¥${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 120,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    orderState.selectedAddress != null &&
                        !orderState.isCreatingOrder
                    ? () => _submitOrder(orderState)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: orderState.isCreatingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        '提交订单',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder(OrderState orderState) async {
    if (orderState.selectedAddress == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择收货地址')));
      return;
    }

    final request = CreateOrderRequest(
      items: widget.items,
      shippingAddress: orderState.selectedAddress!,
      remark: _remarkController.text.trim().isEmpty
          ? null
          : _remarkController.text.trim(),
    );

    final order = await orderState.createOrder(request);

    if (order != null) {
      // 订单创建成功，清空购物车中的对应商品
      final cartState = context.read<CartState>();
      for (final item in widget.items) {
        cartState.removeFromCart(item.id);
      }

      // 跳转到订单详情页面
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderId: order.id),
          ),
        );
      }
    } else {
      // 显示错误信息
      if (mounted && orderState.createOrderError != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(orderState.createOrderError!)));
      }
    }
  }
}
