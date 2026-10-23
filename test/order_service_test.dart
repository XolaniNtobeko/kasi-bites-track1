import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/models/order_model.dart';
import 'package:kasi_bites/services/order_service.dart';

void main() {
  group('OrderService Mock Tests', () {
    test('should fetch orders successfully from mock Java backend', () async {
      final orderService = OrderService();
      final orders = await orderService.fetchOrders();

      expect(orders, isNotEmpty);
      expect(orders.first, isA<MerchantOrder>());
    });

    test('should return true when syncing order status update to Java backend', () async {
      final orderService = OrderService();
      final success = await orderService.updateOrderStatusOnBackend('ORD-001', OrderStatus.preparing);

      expect(success, true);
    });
  });
}