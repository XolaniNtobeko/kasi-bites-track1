import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('simulates receiving a new dynamic WhatsApp order', (WidgetTester tester) async {
  await tester.runAsync(() async {
    await orderProvider.fetchOrders();
  });

  await tester.pumpWidget(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
  await tester.pump();

  // Tap the dynamic incoming order FAB
  final fab = find.byType(FloatingActionButton);
  expect(fab, findsOneWidget);

  await tester.tap(fab);
  await tester.pump();

  // Verify multiple order cards containing ORD- exist
  expect(find.textContaining('ORD-'), findsAtLeastNWidgets(2));
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

  testWidgets('shows a SnackBar notification when a new WhatsApp order arrives', (WidgetTester tester) async {
  await tester.runAsync(() async {
    await orderProvider.fetchOrders();
  });

  await tester.pumpWidget(
    const MaterialApp(
      home: HomeScreen(),
    ),
  );
  await tester.pump();

  // Tap the dynamic incoming order FAB
  final fab = find.byType(FloatingActionButton);
  await tester.tap(fab);
  await tester.pump(); // Trigger frame for SnackBar entry

  // Verify SnackBar appears with notification text
  expect(find.byType(SnackBar), findsOneWidget);
  expect(find.textContaining('New WhatsApp order received:'), findsOneWidget);
});
}