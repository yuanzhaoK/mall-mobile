import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/order_state.dart';
import '../models/api_models.dart';
import '../constants/app_colors.dart';

/// 订单详情页面
class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    // 加载订单详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderState>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('订单详情'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<OrderState>(
        builder: (context, orderState, child) {
          if (orderState.isLoadingOrderDetail) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderState.orderDetailError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(orderState.orderDetailError!),
                  ElevatedButton(
                    onPressed: () => orderState.loadOrderDetail(widget.orderId),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          final order = orderState.currentOrder;
          if (order == null) {
            return const Center(child: Text('订单不存在'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildOrderStatus(order),
                      const SizedBox(height: 8),
                      _buildShippingAddress(order),
                      const SizedBox(height: 8),
                      _buildProductList(order),
                      const SizedBox(height: 8),
                      _buildOrderInfo(order),
                      const SizedBox(height: 8),
                      _buildPriceDetail(order),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(order, orderState),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderStatus(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: order.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: order.statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: order.statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(order),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(Order order) {
    final address = order.shippingAddress;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                '收货地址',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
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
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            address.fullAddress,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(Order order) {
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
          ...order.items.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: CachedNetworkImage(
                imageUrl: item.productImage,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.attributesText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.attributesText,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.formattedPrice,
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

  Widget _buildOrderInfo(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '订单信息',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('订单号', order.orderNo, canCopy: true),
          _buildInfoRow('下单时间', order.formattedCreatedAt),
          if (order.paidAt != null)
            _buildInfoRow('付款时间', order.formattedPaidAt!),
          if (order.shippedAt != null)
            _buildInfoRow('发货时间', order.formattedShippedAt!),
          if (order.deliveredAt != null)
            _buildInfoRow('收货时间', order.formattedDeliveredAt!),
          if (order.trackingNumber != null)
            _buildInfoRow('物流单号', order.trackingNumber!, canCopy: true),
          if (order.paymentMethod != null)
            _buildInfoRow('支付方式', order.paymentMethod!.label),
          if (order.remark != null) _buildInfoRow('订单备注', order.remark!),
          if (order.cancelReason != null)
            _buildInfoRow('取消原因', order.cancelReason!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: canCopy ? () => _copyToClipboard(value) : null,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: canCopy ? AppColors.primary : Colors.black87,
                  decoration: canCopy ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetail(Order order) {
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
          _buildPriceRow('商品金额', order.formattedSubtotal),
          _buildPriceRow('运费', order.formattedShippingFee),
          if (order.discount > 0)
            _buildPriceRow(
              '优惠',
              '-${order.formattedDiscount}',
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
                order.formattedTotalAmount,
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

  Widget _buildBottomActions(Order order, OrderState orderState) {
    final actions = <Widget>[];

    if (order.canPay) {
      actions.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showPaymentDialog(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              '立即付款',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    if (order.canConfirmDelivery) {
      actions.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () => _confirmDelivery(order, orderState),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              '确认收货',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    if (order.canCancel) {
      actions.add(
        OutlinedButton(
          onPressed: () => _showCancelDialog(order, orderState),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: Colors.grey[400]!),
          ),
          child: Text(
            '取消订单',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: actions
              .expand((widget) => [widget, const SizedBox(width: 12)])
              .take(actions.length * 2 - 1)
              .toList(),
        ),
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.paid:
      case OrderStatus.processing:
        return Icons.hourglass_empty;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        return Icons.cancel;
    }
  }

  String _getStatusDescription(Order order) {
    switch (order.status) {
      case OrderStatus.pending:
        return '请在24小时内完成付款';
      case OrderStatus.paid:
        return '商家正在准备发货';
      case OrderStatus.processing:
        return '商家正在处理您的订单';
      case OrderStatus.shipped:
        return order.trackingNumber != null
            ? '快递单号：${order.trackingNumber}'
            : '商品正在配送中';
      case OrderStatus.delivered:
        return '商品已送达，请确认收货';
      case OrderStatus.completed:
        return '订单已完成';
      case OrderStatus.cancelled:
        return order.cancelReason ?? '订单已取消';
      case OrderStatus.refunded:
        return '订单已退款';
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
  }

  void _showPaymentDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择支付方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PaymentMethod.values.map((method) {
            return ListTile(
              leading: Icon(_getPaymentIcon(method)),
              title: Text(method.label),
              onTap: () {
                Navigator.pop(context);
                _processPayment(order, method);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.alipay:
        return Icons.account_balance_wallet;
      case PaymentMethod.wechat:
        return Icons.chat;
      case PaymentMethod.bankCard:
        return Icons.credit_card;
      case PaymentMethod.balance:
        return Icons.account_balance;
    }
  }

  void _processPayment(Order order, PaymentMethod method) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${method.label}支付功能开发中')));
  }

  void _confirmDelivery(Order order, OrderState orderState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认收货'),
        content: const Text('确认已收到商品并且商品完好无损？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await orderState.confirmDelivery(order.id);
              if (success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('确认收货成功')));
              }
            },
            child: const Text('确认收货'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Order order, OrderState orderState) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消订单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请选择取消原因：'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: '请输入取消原因',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('请输入取消原因')));
                return;
              }
              Navigator.pop(context);
              final success = await orderState.cancelOrder(order.id, reason);
              if (success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('订单取消成功')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认取消'),
          ),
        ],
      ),
    );
  }
}
