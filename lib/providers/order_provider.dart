import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;

  OrderProvider({OrderService? orderService})
      : _orderService = orderService ?? OrderService();

  final List<MerchantOrder> _orders = [];
  bool _isLoading = false;

  List<MerchantOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;

  // Fetch orders from the Java/Twilio backend via OrderService
  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedOrders = await _orderService.fetchOrders();
      _orders.clear();
      _orders.addAll(fetchedOrders);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String id, OrderStatus newStatus) async {
    final orderIndex = _orders.indexWhere((o) => o.id == id);
    if (orderIndex != -1) {
      // Optimistic UI update locally
      final previousStatus = _orders[orderIndex].status;
      _orders[orderIndex].status = newStatus;
      notifyListeners();

      // Sync status update with backend
      final success = await _orderService.updateOrderStatusOnBackend(id, newStatus);
      if (!success) {
        // Rollback on failure
        _orders[orderIndex].status = previousStatus;
        notifyListeners();
      }
    }
  }

  void addOrder(MerchantOrder order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}