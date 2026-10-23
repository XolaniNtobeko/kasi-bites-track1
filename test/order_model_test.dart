import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/models/order_model.dart'; // Adjust path if needed

void main() {
  group('MerchantOrder Model Tests', () {
    test('should instantiate MerchantOrder with default pending status', () {
      final order = MerchantOrder(
        id: 'ORD-001',
        customerName: 'Sibo',
        customerPhone: '+27821234567',
        items: const [
          OrderItem(name: 'Classic Kota', quantity: 2),
        ],
        timestamp: DateTime.now(),
      );

      expect(order.id, 'ORD-001');
      expect(order.customerName, 'Sibo');
      expect(order.items.length, 1);
      expect(order.items.first.name, 'Classic Kota');
      expect(order.status, OrderStatus.pending);
    });

    test('should update order status correctly', () {
      final order = MerchantOrder(
        id: 'ORD-002',
        customerName: 'Lindiwe',
        customerPhone: '+27839876543',
        items: const [
          OrderItem(name: 'Full Chicken & Chips', quantity: 1),
        ],
        timestamp: DateTime.now(),
      );

      order.status = OrderStatus.preparing;
      expect(order.status, OrderStatus.preparing);

      order.status = OrderStatus.completed;
      expect(order.status, OrderStatus.completed);
    });
  });
}