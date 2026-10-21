import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasi Bites'),
        backgroundColor: const Color.fromARGB(255, 174, 34, 255),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.fastfood,
              size: 80,
              color: Colors.deepOrange,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Kasi Bites! 🍔',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Fresh meals, right around the corner.'),
          ],
        ),
      ),
    );
  }
}