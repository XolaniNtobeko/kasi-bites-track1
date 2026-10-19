import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/models/food_item.dart';

void main() {
  test('FoodItem stores name, description, and price correctly', () {
    const item = FoodItem(
      id: 'k1',
      name: 'Classic Kasi Kota',
      description: 'Quarter loaf, chips, polony, cheese.',
      price: 35.00,
    );

    expect(item.id, 'k1');
    expect(item.name, 'Classic Kasi Kota');
    expect(item.description, 'Quarter loaf, chips, polony, cheese.');
    expect(item.price, 35.00);
  });
}