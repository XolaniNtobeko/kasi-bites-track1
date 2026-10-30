import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_model.dart';
import '../providers/order_provider.dart';

final OrderProvider orderProvider = OrderProvider();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Request permission for Android 13+ / iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // 2. Get the FCM registration token for your Java backend
    String? token = await messaging.getToken();
    debugPrint('🔥 FCM Token: $token');

    if (token != null) {
      await _sendTokenToBackend(token);
    }

    // 3. Listen for token refreshes (in case FCM rotates the token)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token refreshed: $newToken');
      _sendTokenToBackend(newToken);
    });

    // 4. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Foreground message received: ${message.notification?.title}');
      if (message.notification != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${message.notification?.title}: ${message.notification?.body}'),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    const String backendUrl = 'http://10.0.2.2:8082/api/devices'; 
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fcmToken': token,
          'platform': 'android',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ FCM Token successfully registered with KasiBitesServer');
      } else {
        debugPrint('⚠️ Failed to register token. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error connecting to backend for token registration: $e');
    }
  }

  void _showOrderDetailsBottomSheet(BuildContext context, MerchantOrder order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Order ID: ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('Customer: ${order.customerName}', style: const TextStyle(fontSize: 15)),
              Text('Phone: ${order.customerPhone}', style: const TextStyle(fontSize: 15)),
              Text(
                'Time Received: ${order.timestamp.hour.toString().padLeft(2, '0')}:${order.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                'Items Ordered:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('• ${item.quantity}x ${item.name}', style: const TextStyle(fontSize: 14)),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

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
                _buildOrderList(context, orderProvider.getOrdersByStatus(null)),
                _buildOrderList(context, orderProvider.getOrdersByStatus(OrderStatus.pending)),
                _buildOrderList(context, orderProvider.getOrdersByStatus(OrderStatus.preparing)),
                _buildOrderList(context, orderProvider.getOrdersByStatus(OrderStatus.completed)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<MerchantOrder> orders) {
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
          child: InkWell(
            onTap: () => _showOrderDetailsBottomSheet(context, order),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${order.id} - ${order.customerName}',
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
        color: color.withValues(alpha: 0.2),
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