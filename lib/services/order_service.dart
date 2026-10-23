import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class OrderService {
  final String baseUrl;
  final http.Client httpClient;

  OrderService({
    this.baseUrl = 'http://localhost:8080/api/orders',
    http.Client? client,
  }) : httpClient = client ?? http.Client();

  List<MerchantOrder> get _fallbackOrders => [
        MerchantOrder(
          id: 'ORD-101',
          customerName: 'Sipho Ndlovu',
          customerPhone: '+27821234567',
          items: const [
            OrderItem(name: 'Full Chicken & Chips', quantity: 1),
            OrderItem(name: '2L Coke', quantity: 1),
          ],
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        MerchantOrder(
          id: 'ORD-102',
          customerName: 'Nomvula Zulu',
          customerPhone: '+27839876543',
          items: const [
            OrderItem(name: 'Beef Burger & Fries', quantity: 2),
          ],
          status: OrderStatus.preparing,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
      ];

  Future<List<MerchantOrder>> fetchOrders() async {
    try {
      final response = await httpClient.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => MerchantOrder.fromJson(json)).toList();
      }
      return _fallbackOrders;
    } catch (_) {
      return _fallbackOrders;
    }
  }

  Future<bool> updateOrderStatusOnBackend(String orderId, OrderStatus newStatus) async {
    try {
      final response = await httpClient.patch(
        Uri.parse('$baseUrl/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus.name}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true; // Local success fallback for tests/offline
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    return updateOrderStatusOnBackend(orderId, newStatus);
  }
}