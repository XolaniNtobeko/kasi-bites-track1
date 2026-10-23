import '../models/order_model.dart';

class OrderService {
  // Simulate fetching incoming WhatsApp orders from the Java backend API
  Future<List<MerchantOrder>> fetchOrders() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      MerchantOrder(
        id: 'ORD-101',
        customerName: 'Sipho',
        customerPhone: '+27825556677',
        items: const [
          OrderItem(name: 'Full Chicken Kota', quantity: 1),
        ],
        status: OrderStatus.pending,
        timestamp: DateTime.now(),
      ),
    ];
  }

  // Simulate syncing an order status update back to the Java/Twilio backend
  Future<bool> updateOrderStatusOnBackend(String orderId, OrderStatus status) async {
    // Simulate network round-trip
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Return true on success
    return true;
  }
}