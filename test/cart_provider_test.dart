import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/models/food_item.dart';
import 'package:kasi_bites/providers/cart_provider.dart';

void main() {
  test('Initial CartProvider should have empty items and zero total amount', () {
    final cartProvider = CartProvider();

    expect(cartProvider.itemCount, 0);
    expect(cartProvider.totalAmount, 0.0);
    expect(cartProvider.items.isEmpty, true);
  });

  test('Adding an item to cart should increase item count and total amount', () {
    final cartProvider = CartProvider();
    const testItem = FoodItem(
      id: 'k1',
      name: 'Classic Kasi Kota',
      description: 'Quarter loaf, chips, polony, cheese.',
      price: 35.00,
    );

    cartProvider.addItem(testItem);

    expect(cartProvider.itemCount, 1);
    expect(cartProvider.totalAmount, 35.00);
    expect(cartProvider.items.containsKey('k1'), true);
    expect(cartProvider.items['k1']?.quantity, 1);
  });

  test('Adding the same item multiple times should increment its quantity', () {
    final cartProvider = CartProvider();
    const testItem = FoodItem(
      id: 'k1',
      name: 'Classic Kasi Kota',
      description: 'Quarter loaf, chips, polony, cheese.',
      price: 35.00,
    );

    cartProvider.addItem(testItem);
    cartProvider.addItem(testItem);

    expect(cartProvider.itemCount, 2);
    expect(cartProvider.totalAmount, 70.00);
    expect(cartProvider.items['k1']?.quantity, 2);
  });

  test('Removing an item from cart should clear it and reset total amount', () {
    final cartProvider = CartProvider();
    const testItem = FoodItem(
      id: 'k1',
      name: 'Classic Kasi Kota',
      description: 'Quarter loaf, chips, polony, cheese.',
      price: 35.00,
    );

    cartProvider.addItem(testItem);
    cartProvider.removeItem('k1');

    expect(cartProvider.itemCount, 0);
    expect(cartProvider.totalAmount, 0.0);
    expect(cartProvider.items.containsKey('k1'), false);
  });

  test('Clearing cart should remove all items and reset total amount', () {
    final cartProvider = CartProvider();
    const item1 = FoodItem(
      id: 'k1',
      name: 'Classic Kasi Kota',
      description: 'Quarter loaf, chips, polony, cheese.',
      price: 35.00,
    );
    const item2 = FoodItem(
      id: 'k2',
      name: 'Gatsby Special',
      description: 'Full loaf, steak, chips, sauces.',
      price: 85.00,
    );

    cartProvider.addItem(item1);
    cartProvider.addItem(item2);

    expect(cartProvider.itemCount, 2);

    cartProvider.clearCart();

    expect(cartProvider.itemCount, 0);
    expect(cartProvider.totalAmount, 0.0);
    expect(cartProvider.items.isEmpty, true);
  });
}