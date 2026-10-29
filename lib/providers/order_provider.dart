import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;
  Timer? _pollingTimer;

  OrderProvider({OrderService? orderService})
      : _orderService = orderService ?? OrderService() {
    // Fetch immediately on startup
    fetchOrders();

    // Poll the Java backend every 3 seconds for live WhatsApp orders
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchOrders();
    });
  }

  final List<MerchantOrder> _orders = [];
  bool _isLoading = false;

  List<MerchantOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    try {
      final fetchedOrders = await _orderService.fetchOrders();
      _orders.clear();
      _orders.addAll(fetchedOrders);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    }
  }

  Future<void> updateOrderStatus(String id, OrderStatus newStatus) async {
    final orderIndex = _orders.indexWhere((o) => o.id == id);
    if (orderIndex != -1) {
      final oldOrder = _orders[orderIndex];

      // Immutable update
      _orders[orderIndex] = MerchantOrder(
        id: oldOrder.id,
        customerName: oldOrder.customerName,
        customerPhone: oldOrder.customerPhone,
        items: oldOrder.items,
        status: newStatus,
        timestamp: oldOrder.timestamp,
      );
      notifyListeners();

      try {
        await _orderService.updateOrderStatusOnBackend(id, newStatus);
      } catch (e) {
        // Retain local optimistic state
      }
    }
  }

  void addOrder(MerchantOrder order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  List<MerchantOrder> getOrdersByStatus(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((order) => order.status == status).toList();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); 
    super.dispose();
  }
}