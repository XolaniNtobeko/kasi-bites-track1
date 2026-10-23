import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<MerchantOrder> _orders = [
    MerchantOrder(
      id: 'ORD-001',
      customerName: 'Thabo',
      customerPhone: '+27821112233',
      items: const [
        OrderItem(name: 'Classic Kota', quantity: 2),
        OrderItem(name: 'Coke 500ml', quantity: 1),
      ],
      status: OrderStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    MerchantOrder(
      id: 'ORD-002',
      customerName: 'Zinhle',
      customerPhone: '+27834445566',
      items: const [
        OrderItem(name: 'Dagwood Burger', quantity: 1),
      ],
      status: OrderStatus.preparing,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
  ];

  List<MerchantOrder> get orders => List.unmodifiable(_orders);

  void updateOrderStatus(String id, OrderStatus newStatus) {
    final orderIndex = _orders.indexWhere((o) => o.id == id);
    if (orderIndex != -1) {
      _orders[orderIndex].status = newStatus;
      notifyListeners();
    }
  }

  void addOrder(MerchantOrder order) {
    _orders.insert(0, order); // Newest incoming orders appear at the top
    notifyListeners();
  }
}