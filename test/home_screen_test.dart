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
}