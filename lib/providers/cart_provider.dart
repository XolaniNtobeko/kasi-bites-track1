import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class CartItem {
  final FoodItem food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.food.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(FoodItem food) {
    if (_items.containsKey(food.id)) {
      _items.update(
        food.id,
        (existingCartItem) => CartItem(
          food: existingCartItem.food,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        food.id,
        () => CartItem(food: food, quantity: 1),
      );
    }
    notifyListeners();
  }
}