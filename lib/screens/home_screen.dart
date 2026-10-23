import 'package:flutter/material.dart';
import '../models/food_item.dart';
// Note: Make sure to import your cart provider path correctly based on your folder structure
import '../providers/cart_provider.dart'; 

// Sample mock data for testing
final List<FoodItem> sampleMenu = [
  const FoodItem(id: '1', name: 'Classic Kota', description: 'Chips, polony, cheese & special sauce', price: 35.0),
  const FoodItem(id: '2', name: 'Dagwood Burger', description: 'Beef patty, egg, cheese & chips', price: 65.0),
  const FoodItem(id: '3', name: 'Full Chicken & Chips', description: 'Flame-grilled with Kasi spices', price: 110.0),
];

// Global instance for testing this step
final cartProvider = CartProvider();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasi Bites Menu'),
        backgroundColor: const Color.fromARGB(255, 174, 34, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // We will build the Cart Screen next!
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart screen coming up next!')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sampleMenu.length,
        itemBuilder: (context, index) {
          final food = sampleMenu[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.description),
                  const SizedBox(height: 4),
                  Text('R ${food.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 174, 34, 255)),
                onPressed: () {
                  cartProvider.addItem(food);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${food.name} to cart! Total items: ${cartProvider.itemCount}')),
                  );
                },
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}