import 'package:flutter/foundation.dart';
import '../models/api_models.dart';

/// 订单状态管理
class OrderState extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  // 订单创建相关
  bool _isCreatingOrder = false;
  String? _createOrderError;

  // 订单详情
  Order? _currentOrder;
  bool _isLoadingOrderDetail = false;
  String? _orderDetailError;

  // 地址管理
  List<ShippingAddress> _addresses = [];
  ShippingAddress? _selectedAddress;
  bool _isLoadingAddresses = false;
  String? _addressError;

  // Getters
  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _orders.isEmpty;
  bool get isNotEmpty => _orders.isNotEmpty;

  // 订单创建相关getters
  bool get isCreatingOrder => _isCreatingOrder;
  String? get createOrderError => _createOrderError;

  // 订单详情相关getters
  Order? get currentOrder => _currentOrder;
  bool get isLoadingOrderDetail => _isLoadingOrderDetail;
  String? get orderDetailError => _orderDetailError;

  // 地址相关getters
  List<ShippingAddress> get addresses => List.unmodifiable(_addresses);
  ShippingAddress? get selectedAddress => _selectedAddress;
  bool get isLoadingAddresses => _isLoadingAddresses;
  String? get addressError => _addressError;

  // 按状态分组的订单
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // 待付款订单
  List<Order> get pendingOrders => getOrdersByStatus(OrderStatus.pending);

  // 待发货订单
  List<Order> get paidOrders => getOrdersByStatus(OrderStatus.paid);

  // 待收货订单
  List<Order> get shippedOrders => getOrdersByStatus(OrderStatus.shipped);

  // 已完成订单
  List<Order> get completedOrders => getOrdersByStatus(OrderStatus.completed);

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// 设置订单创建状态
  void _setCreatingOrder(bool creating) {
    _isCreatingOrder = creating;
    notifyListeners();
  }

  /// 设置订单创建错误
  void _setCreateOrderError(String? error) {
    _createOrderError = error;
    notifyListeners();
  }

  /// 设置订单详情加载状态
  void _setLoadingOrderDetail(bool loading) {
    _isLoadingOrderDetail = loading;
    notifyListeners();
  }

  /// 设置订单详情错误
  void _setOrderDetailError(String? error) {
    _orderDetailError = error;
    notifyListeners();
  }

  /// 设置地址加载状态
  void _setLoadingAddresses(bool loading) {
    _isLoadingAddresses = loading;
    notifyListeners();
  }

  /// 设置地址错误
  void _setAddressError(String? error) {
    _addressError = error;
    notifyListeners();
  }

  /// 加载订单列表
  Future<void> loadOrders({bool refresh = false}) async {
    try {
      if (refresh || _orders.isEmpty) {
        _setLoading(true);
      }
      _setError(null);

      // 这里应该调用后端API获取订单列表
      // 目前使用模拟数据
      await Future.delayed(const Duration(milliseconds: 1000));

      _orders = _generateMockOrders();
    } catch (e) {
      _setError('加载订单列表失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 加载订单详情
  Future<void> loadOrderDetail(String orderId) async {
    try {
      _setLoadingOrderDetail(true);
      _setOrderDetailError(null);

      // 这里应该调用后端API获取订单详情
      // 目前使用模拟数据
      await Future.delayed(const Duration(milliseconds: 800));

      _currentOrder = _orders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => _generateMockOrderDetail(orderId),
      );
    } catch (e) {
      _setOrderDetailError('加载订单详情失败: $e');
    } finally {
      _setLoadingOrderDetail(false);
    }
  }

  /// 创建订单
  Future<Order?> createOrder(CreateOrderRequest request) async {
    try {
      _setCreatingOrder(true);
      _setCreateOrderError(null);

      // 这里应该调用后端API创建订单
      // 目前使用模拟数据
      await Future.delayed(const Duration(milliseconds: 1500));

      final newOrder = _generateMockOrderFromRequest(request);
      _orders.insert(0, newOrder);

      return newOrder;
    } catch (e) {
      _setCreateOrderError('创建订单失败: $e');
      return null;
    } finally {
      _setCreatingOrder(false);
    }
  }

  /// 取消订单
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      _setError(null);

      // 这里应该调用后端API取消订单
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        final order = _orders[index];
        if (order.canCancel) {
          _orders[index] = Order(
            id: order.id,
            orderNo: order.orderNo,
            userId: order.userId,
            status: OrderStatus.cancelled,
            items: order.items,
            shippingAddress: order.shippingAddress,
            subtotal: order.subtotal,
            shippingFee: order.shippingFee,
            discount: order.discount,
            totalAmount: order.totalAmount,
            paymentMethod: order.paymentMethod,
            createdAt: order.createdAt,
            paidAt: order.paidAt,
            shippedAt: order.shippedAt,
            deliveredAt: order.deliveredAt,
            remark: order.remark,
            trackingNumber: order.trackingNumber,
            cancelReason: reason,
          );
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      _setError('取消订单失败: $e');
      return false;
    }
  }

  /// 确认收货
  Future<bool> confirmDelivery(String orderId) async {
    try {
      _setError(null);

      // 这里应该调用后端API确认收货
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        final order = _orders[index];
        if (order.canConfirmDelivery) {
          _orders[index] = Order(
            id: order.id,
            orderNo: order.orderNo,
            userId: order.userId,
            status: OrderStatus.delivered,
            items: order.items,
            shippingAddress: order.shippingAddress,
            subtotal: order.subtotal,
            shippingFee: order.shippingFee,
            discount: order.discount,
            totalAmount: order.totalAmount,
            paymentMethod: order.paymentMethod,
            createdAt: order.createdAt,
            paidAt: order.paidAt,
            shippedAt: order.shippedAt,
            deliveredAt: DateTime.now(),
            remark: order.remark,
            trackingNumber: order.trackingNumber,
            cancelReason: order.cancelReason,
          );
          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e) {
      _setError('确认收货失败: $e');
      return false;
    }
  }

  /// 加载收货地址列表
  Future<void> loadAddresses() async {
    try {
      _setLoadingAddresses(true);
      _setAddressError(null);

      // 这里应该调用后端API获取地址列表
      await Future.delayed(const Duration(milliseconds: 800));

      _addresses = _generateMockAddresses();

      // 设置默认地址
      if (_addresses.isNotEmpty && _selectedAddress == null) {
        _selectedAddress = _addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => _addresses.first,
        );
      }
    } catch (e) {
      _setAddressError('加载地址列表失败: $e');
    } finally {
      _setLoadingAddresses(false);
    }
  }

  /// 选择收货地址
  void selectAddress(ShippingAddress address) {
    _selectedAddress = address;
    notifyListeners();
  }

  /// 添加收货地址
  Future<bool> addAddress(ShippingAddress address) async {
    try {
      _setAddressError(null);

      // 这里应该调用后端API添加地址
      await Future.delayed(const Duration(milliseconds: 800));

      _addresses.add(address);

      // 如果是默认地址，取消其他地址的默认状态
      if (address.isDefault) {
        for (int i = 0; i < _addresses.length - 1; i++) {
          if (_addresses[i].isDefault) {
            _addresses[i] = ShippingAddress(
              id: _addresses[i].id,
              name: _addresses[i].name,
              phone: _addresses[i].phone,
              province: _addresses[i].province,
              city: _addresses[i].city,
              district: _addresses[i].district,
              address: _addresses[i].address,
              postalCode: _addresses[i].postalCode,
              isDefault: false,
            );
          }
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setAddressError('添加地址失败: $e');
      return false;
    }
  }

  /// 删除收货地址
  Future<bool> deleteAddress(String addressId) async {
    try {
      _setAddressError(null);

      // 这里应该调用后端API删除地址
      await Future.delayed(const Duration(milliseconds: 800));

      _addresses.removeWhere((addr) => addr.id == addressId);

      // 如果删除的是选中的地址，重新选择默认地址
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty
            ? _addresses.firstWhere(
                (addr) => addr.isDefault,
                orElse: () => _addresses.first,
              )
            : null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setAddressError('删除地址失败: $e');
      return false;
    }
  }

  /// 生成模拟订单列表
  List<Order> _generateMockOrders() {
    final now = DateTime.now();
    return [
      Order(
        id: 'order_1',
        orderNo: 'ORD${now.millisecondsSinceEpoch}001',
        userId: 'user_1',
        status: OrderStatus.pending,
        items: [
          OrderItem(
            id: 'item_1',
            productId: 'product_1',
            productName: 'iPhone 15 Pro Max 256GB 深空黑色',
            productImage:
                'https://via.placeholder.com/100x100/FF6B6B/FFFFFF?text=iPhone',
            price: 9999.0,
            originalPrice: 10999.0,
            quantity: 1,
            skuId: 'sku_1',
            skuName: '256GB 深空黑色',
            attributes: {'容量': '256GB', '颜色': '深空黑色'},
          ),
        ],
        shippingAddress: ShippingAddress(
          id: 'addr_1',
          name: '张三',
          phone: '13800138000',
          province: '广东省',
          city: '深圳市',
          district: '南山区',
          address: '科技园南区深南大道1000号',
          isDefault: true,
        ),
        subtotal: 9999.0,
        shippingFee: 0.0,
        discount: 0.0,
        totalAmount: 9999.0,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Order(
        id: 'order_2',
        orderNo: 'ORD${now.millisecondsSinceEpoch}002',
        userId: 'user_1',
        status: OrderStatus.shipped,
        items: [
          OrderItem(
            id: 'item_2',
            productId: 'product_2',
            productName: 'MacBook Pro 14英寸 M3芯片',
            productImage:
                'https://via.placeholder.com/100x100/4ECDC4/FFFFFF?text=MacBook',
            price: 14999.0,
            quantity: 1,
            attributes: {},
          ),
          OrderItem(
            id: 'item_3',
            productId: 'product_3',
            productName: 'AirPods Pro 第三代',
            productImage:
                'https://via.placeholder.com/100x100/45B7D1/FFFFFF?text=AirPods',
            price: 1999.0,
            quantity: 1,
            attributes: {},
          ),
        ],
        shippingAddress: ShippingAddress(
          id: 'addr_1',
          name: '张三',
          phone: '13800138000',
          province: '广东省',
          city: '深圳市',
          district: '南山区',
          address: '科技园南区深南大道1000号',
          isDefault: true,
        ),
        subtotal: 16998.0,
        shippingFee: 0.0,
        discount: 500.0,
        totalAmount: 16498.0,
        paymentMethod: PaymentMethod.alipay,
        createdAt: now.subtract(const Duration(days: 3)),
        paidAt: now.subtract(const Duration(days: 3, hours: 1)),
        shippedAt: now.subtract(const Duration(days: 1)),
        trackingNumber: 'SF1234567890',
      ),
      Order(
        id: 'order_3',
        orderNo: 'ORD${now.millisecondsSinceEpoch}003',
        userId: 'user_1',
        status: OrderStatus.completed,
        items: [
          OrderItem(
            id: 'item_4',
            productId: 'product_4',
            productName: 'iPad Air 第五代 64GB WiFi版',
            productImage:
                'https://via.placeholder.com/100x100/96CEB4/FFFFFF?text=iPad',
            price: 4399.0,
            quantity: 1,
            attributes: {},
          ),
        ],
        shippingAddress: ShippingAddress(
          id: 'addr_1',
          name: '张三',
          phone: '13800138000',
          province: '广东省',
          city: '深圳市',
          district: '南山区',
          address: '科技园南区深南大道1000号',
          isDefault: true,
        ),
        subtotal: 4399.0,
        shippingFee: 0.0,
        discount: 200.0,
        totalAmount: 4199.0,
        paymentMethod: PaymentMethod.wechat,
        createdAt: now.subtract(const Duration(days: 10)),
        paidAt: now.subtract(const Duration(days: 10, hours: 1)),
        shippedAt: now.subtract(const Duration(days: 8)),
        deliveredAt: now.subtract(const Duration(days: 6)),
      ),
    ];
  }

  /// 生成模拟订单详情
  Order _generateMockOrderDetail(String orderId) {
    return _generateMockOrders().first;
  }

  /// 从请求生成模拟订单
  Order _generateMockOrderFromRequest(CreateOrderRequest request) {
    final now = DateTime.now();
    final orderItems = request.items
        .map((item) => OrderItem.fromCartItem(item))
        .toList();
    final subtotal = orderItems.fold(0.0, (sum, item) => sum + item.subtotal);
    final shippingFee = subtotal >= 99 ? 0.0 : 10.0;
    final discount = subtotal >= 300
        ? 50.0
        : subtotal >= 200
        ? 30.0
        : subtotal >= 100
        ? 15.0
        : 0.0;

    return Order(
      id: 'order_${now.millisecondsSinceEpoch}',
      orderNo: 'ORD${now.millisecondsSinceEpoch}',
      userId: 'user_1',
      status: OrderStatus.pending,
      items: orderItems,
      shippingAddress: request.shippingAddress,
      subtotal: subtotal,
      shippingFee: shippingFee,
      discount: discount,
      totalAmount: subtotal + shippingFee - discount,
      createdAt: now,
      remark: request.remark,
    );
  }

  /// 生成模拟地址列表
  List<ShippingAddress> _generateMockAddresses() {
    return [
      ShippingAddress(
        id: 'addr_1',
        name: '张三',
        phone: '13800138000',
        province: '广东省',
        city: '深圳市',
        district: '南山区',
        address: '科技园南区深南大道1000号',
        isDefault: true,
      ),
      ShippingAddress(
        id: 'addr_2',
        name: '李四',
        phone: '13900139000',
        province: '北京市',
        city: '北京市',
        district: '朝阳区',
        address: '三里屯街道工体北路1号',
        isDefault: false,
      ),
      ShippingAddress(
        id: 'addr_3',
        name: '王五',
        phone: '13700137000',
        province: '上海市',
        city: '上海市',
        district: '浦东新区',
        address: '陆家嘴环路1000号',
        isDefault: false,
      ),
    ];
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    _createOrderError = null;
    _orderDetailError = null;
    _addressError = null;
    notifyListeners();
  }

  /// 重置订单详情
  void clearOrderDetail() {
    _currentOrder = null;
    _orderDetailError = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _orders.clear();
    _currentOrder = null;
    _addresses.clear();
    _selectedAddress = null;
    _error = null;
    _createOrderError = null;
    _orderDetailError = null;
    _addressError = null;
    notifyListeners();
  }
}
