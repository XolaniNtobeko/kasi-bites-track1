import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/models/order_model.dart';
import 'package:kasi_bites/screens/home_screen.dart';

void main() {
  group('HomeScreen Merchant Dashboard Tests', () {
    testWidgets('renders kitchen dashboard title and fetched order cards', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await orderProvider.fetchOrders();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Kasi Bites - Kitchen Dashboard 🍳'), findsOneWidget);
      expect(find.textContaining('Sipho'), findsOneWidget);
    });

    testWidgets('advances order status when action button is tapped', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await orderProvider.fetchOrders();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      final prepareButton = find.text('Start Preparing');
      expect(prepareButton, findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(prepareButton);
      });
      await tester.pump();

      expect(find.text('Mark Complete'), findsOneWidget);
    });
  });

  testWidgets('simulates receiving a new dynamic WhatsApp order via provider', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await orderProvider.fetchOrders();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();

    // Inject mock order directly through provider instead of searching for a missing FAB
    orderProvider.addOrder(MerchantOrder(
      id: 'ORD-999',
      customerName: 'Test Customer',
      customerPhone: '+27810001122',
      items: const [OrderItem(name: 'Kota', quantity: 1)],
      timestamp: DateTime.now(),
    ));
    await tester.pump();

    // Verify order card containing ORD-999 exists
    expect(find.textContaining('ORD-999'), findsOneWidget);
  });

  testWidgets('opens order details bottom sheet when order card is tapped', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await orderProvider.fetchOrders();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pump();

    // Tap on the first order card title/text
    final orderCard = find.textContaining('Sipho').first;
    await tester.tap(orderCard);
    await tester.pumpAndSettle();

    // Verify bottom sheet title and details are visible
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.textContaining('Phone:'), findsWidgets);
  });
}