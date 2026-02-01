import 'package:flutter/material.dart';
import '../models/drink.dart';

class CartProvider with ChangeNotifier {
  // map of drinkId -> qty
  final Map<int, int> _items = {};

  Map<int, int> get items => _items;

  void addToCart(Drink drink) {
    _items[drink.id] = (_items[drink.id] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(Drink drink) {
    if (!_items.containsKey(drink.id)) return;
    final qty = _items[drink.id]!;
    if (qty > 1) {
      _items[drink.id] = qty - 1;
    } else {
      _items.remove(drink.id);
    }
    notifyListeners();
  }

  double total(List<Drink> drinks) {
    double sum = 0;
    _items.forEach((id, qty) {
      final d = drinks.firstWhere((x) => x.id == id, orElse: () => throw Exception("Drink id $id not found"));
      sum += d.price * qty;
    });
    return sum;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
