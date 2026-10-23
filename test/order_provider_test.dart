import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/models/order_model.dart';
import 'package:kasi_bites/providers/order_provider.dart';

void main() {
  group('OrderProvider Unit Tests', () {
    late OrderProvider orderProvider;

    setUp(() {
      orderProvider = OrderProvider();
    });

    test('should fetch initial orders from service', () async {
      await orderProvider.fetchOrders();
      expect(orderProvider.orders.isNotEmpty, true);
    });

    test('should update order status from pending to preparing', () async {
      await orderProvider.fetchOrders();
      final orderId = orderProvider.orders.first.id;

      await orderProvider.updateOrderStatus(orderId, OrderStatus.preparing);

      final updatedOrder = orderProvider.orders.firstWhere((o) => o.id == orderId);
      expect(updatedOrder.status, OrderStatus.preparing);
    });

    test('should add a new incoming WhatsApp order', () {
      final initialCount = orderProvider.orders.length;
      final newOrder = MerchantOrder(
        id: 'ORD-999',
        customerName: 'Sipho',
        customerPhone: '+27810001122',
        items: const [
          OrderItem(name: 'Dagwood Burger', quantity: 1),
        ],
        timestamp: DateTime.now(),
      );

      orderProvider.addOrder(newOrder);

      expect(orderProvider.orders.length, initialCount + 1);
      expect(orderProvider.orders.first.id, 'ORD-999');
    });
  });
}