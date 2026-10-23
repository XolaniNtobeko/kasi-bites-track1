import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/screens/home_screen.dart';

void main() {
  group('HomeScreen Merchant Dashboard Tests', () {
    testWidgets('renders kitchen dashboard title and initial order cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify AppBar title
      expect(find.text('Kasi Bites - Kitchen Dashboard 🍳'), findsOneWidget);

      // Verify mock orders present in state
      expect(find.textContaining('Thabo'), findsOneWidget);
      expect(find.textContaining('Zinhle'), findsOneWidget);
    });

    testWidgets('advances order status when action button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Find 'Start Preparing' button for the pending order
      final prepareButton = find.text('Start Preparing');
      expect(prepareButton, findsOneWidget);

      // Tap to update status
      await tester.tap(prepareButton);
      await tester.pump();

      // Verify button changes to 'Mark Complete'
      expect(find.text('Mark Complete'), findsNWidgets(2));
    });
  });
}