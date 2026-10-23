enum OrderStatus { pending, preparing, completed }

class OrderItem {
  final String name;
  final int quantity;

  const OrderItem({required this.name, required this.quantity});
}

class MerchantOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  OrderStatus status;
  final DateTime timestamp;

  MerchantOrder({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    this.status = OrderStatus.pending,
    required this.timestamp,
  });
}