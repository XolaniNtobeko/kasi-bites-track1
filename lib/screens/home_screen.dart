import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';

final OrderProvider orderProvider = OrderProvider();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kasi Bites - Kitchen Dashboard 🍳'),
          backgroundColor: Colors.deepOrange,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Preparing'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: orderProvider,
          builder: (context, child) {
            return TabBarView(
              children: [
                _buildOrderList(orderProvider.getOrdersByStatus(null)),
                _buildOrderList(orderProvider.getOrdersByStatus(OrderStatus.pending)),
                _buildOrderList(orderProvider.getOrdersByStatus(OrderStatus.preparing)),
                _buildOrderList(orderProvider.getOrdersByStatus(OrderStatus.completed)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<MerchantOrder> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders in this section.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.id} - ${order.customerName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Phone: ${order.customerPhone}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const Divider(),
                ...order.items.map((item) => Text(
                      '• ${item.quantity}x ${item.name}',
                      style: const TextStyle(fontSize: 14),
                    )),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildActionButtons(order),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'PENDING';
        break;
      case OrderStatus.preparing:
        color = Colors.blue;
        text = 'PREPARING';
        break;
      case OrderStatus.completed:
        color = Colors.green;
        text = 'COMPLETED';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  List<Widget> _buildActionButtons(MerchantOrder order) {
    if (order.status == OrderStatus.pending) {
      return [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () {
            orderProvider.updateOrderStatus(order.id, OrderStatus.preparing);
          },
          icon: const Icon(Icons.fireplace, size: 16, color: Colors.white),
          label: const Text('Start Preparing', style: TextStyle(color: Colors.white)),
        ),
      ];
    } else if (order.status == OrderStatus.preparing) {
      return [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            orderProvider.updateOrderStatus(order.id, OrderStatus.completed);
          },
          icon: const Icon(Icons.check, size: 16, color: Colors.white),
          label: const Text('Mark Complete', style: TextStyle(color: Colors.white)),
        ),
      ];
    } else {
      return [
        const Text(
          'Order Fulfilled ✔',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ];
    }
  }
}