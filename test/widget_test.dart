import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/screens/home_screen.dart';

void main() {
  testWidgets('Kasi Bites app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Verify that our dashboard title is present.
    expect(find.text('Kasi Bites - Kitchen Dashboard 🍳'), findsOneWidget);
  });
}