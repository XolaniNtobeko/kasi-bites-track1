import 'package:flutter_test/flutter_test.dart';
import 'package:kasi_bites/providers/cart_provider.dart';

void main() {
  test('Initial CartProvider should have empty items and zero total amount', () {
    final cartProvider = CartProvider();

    expect(cartProvider.itemCount, 0);
    expect(cartProvider.totalAmount, 0.0);
    expect(cartProvider.items.isEmpty, true);
  });
}