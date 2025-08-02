import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_home_mall/providers/order_state.dart';
import 'package:flutter_home_mall/models/api_models.dart';
import 'package:flutter_home_mall/constants/app_colors.dart';
import 'package:flutter_home_mall/pages/order_detail_page.dart';

/// 订单列表页面
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key, this.initialTabIndex = 0});
  final int initialTabIndex;

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = const [
    Tab(text: '全部'),
    Tab(text: '待付款'),
    Tab(text: '待发货'),
    Tab(text: '待收货'),
    Tab(text: '已完成'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // 加载订单列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderState>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('我的订单'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Consumer<OrderState>(
        builder: (context, orderState, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(orderState.orders, orderState), // 全部
              _buildOrderList(orderState.pendingOrders, orderState), // 待付款
              _buildOrderList(orderState.paidOrders, orderState), // 待发货
              _buildOrderList(orderState.shippedOrders, orderState), // 待收货
              _buildOrderList(orderState.completedOrders, orderState), // 已完成
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, OrderState orderState) {
    if (orderState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              orderState.error!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => orderState.loadOrders(refresh: true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => orderState.loadOrders(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderItem(order, orderState);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('暂无订单', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            '快去下单购买心仪的商品吧～',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Order order, OrderState orderState) {
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 订单头部信息
              _buildOrderHeader(order),

              const SizedBox(height: 12),

              // 商品列表
              _buildOrderProducts(order),

              const SizedBox(height: 12),

              // 订单总价
              _buildOrderTotal(order),

              const SizedBox(height: 12),

              // 操作按钮
              _buildOrderActions(order, orderState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '订单号：${order.orderNo}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              order.formattedCreatedAt,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: order.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            order.status.label,
            style: TextStyle(
              fontSize: 12,
              color: order.statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderProducts(Order order) {
    // 只显示主要商品，如果有多个商品则显示数量
    final primaryItem = order.primaryItem;
    if (primaryItem == null) return const SizedBox.shrink();

    return Row(
      children: [
        // 商品图片
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: CachedNetworkImage(
              imageUrl: primaryItem.productImage,
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
                primaryItem.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (primaryItem.attributesText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  primaryItem.attributesText,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    primaryItem.formattedPrice,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  if (order.itemTypeCount > 1)
                    Text(
                      '等${order.itemTypeCount}件商品',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    )
                  else
                    Text(
                      'x${primaryItem.quantity}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTotal(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '共${order.itemCount}件商品',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Row(
          children: [
            Text(
              '实付：',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              order.formattedTotalAmount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderActions(Order order, OrderState orderState) {
    final actions = <Widget>[];

    // 查看物流
    if (order.status == OrderStatus.shipped && order.trackingNumber != null) {
      actions.add(
        OutlinedButton(
          onPressed: () => _showTrackingDialog(order),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            side: BorderSide(color: Colors.grey[400]!),
            minimumSize: const Size(80, 32),
          ),
          child: Text(
            '查看物流',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
      );
    }

    // 取消订单
    if (order.canCancel) {
      actions.add(
        OutlinedButton(
          onPressed: () => _showQuickCancelDialog(order, orderState),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            side: BorderSide(color: Colors.grey[400]!),
            minimumSize: const Size(80, 32),
          ),
          child: Text(
            '取消订单',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
      );
    }

    // 确认收货
    if (order.canConfirmDelivery) {
      actions.add(
        ElevatedButton(
          onPressed: () => _quickConfirmDelivery(order, orderState),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(80, 32),
          ),
          child: const Text('确认收货', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    // 立即付款
    if (order.canPay) {
      actions.add(
        ElevatedButton(
          onPressed: () => _showQuickPaymentDialog(order),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(80, 32),
          ),
          child: const Text('立即付款', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    // 再次购买
    actions.add(
      OutlinedButton(
        onPressed: () => _repurchase(order),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(80, 32),
        ),
        child: const Text(
          '再次购买',
          style: TextStyle(fontSize: 12, color: AppColors.primary),
        ),
      ),
    );

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions
          .expand((widget) => [widget, const SizedBox(width: 8)])
          .take(actions.length * 2 - 1)
          .toList(),
    );
  }

  void _showTrackingDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('物流信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('快递单号：${order.trackingNumber}'),
            const SizedBox(height: 8),
            const Text('物流状态：运输中'),
            const SizedBox(height: 16),
            const Text(
              '详细物流信息请在快递公司官网查询',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showQuickCancelDialog(Order order, OrderState orderState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消订单'),
        content: const Text('确定要取消这个订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await orderState.cancelOrder(order.id, '用户主动取消');
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

  void _quickConfirmDelivery(Order order, OrderState orderState) {
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

  void _showQuickPaymentDialog(Order order) {
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
                _processQuickPayment(order, method);
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

  void _processQuickPayment(Order order, PaymentMethod method) {
    // TODO: 实现支付逻辑
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${method.label}支付功能开发中')));
  }

  void _repurchase(Order order) {
    // TODO: 实现再次购买逻辑
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('再次购买功能开发中')));
  }
}
