enum OrderStatus {
  pending,
  preparing,
  completed,
}

class OrderItem {
  final String name;
  final int quantity;

  const OrderItem({required this.name, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
      };
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
    this.status = OrderStatus.pending, // Default to pending
    required this.timestamp,
  });

  factory MerchantOrder.fromJson(Map<String, dynamic> json) {
    return MerchantOrder(
      id: json['id'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      items: (json['items'] as List)
          .map((itemJson) => OrderItem.fromJson(itemJson))
          .toList(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['status'] as String).toLowerCase(),
        orElse: () => OrderStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'items': items.map((i) => i.toJson()).toList(),
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
      };
}