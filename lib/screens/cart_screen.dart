import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final List<Drink> drinks = getDrinks();

  CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Your Cart', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('🛒 Your cart is empty', style: TextStyle(color: Colors.grey)))
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: cart.items.keys.map((id) {
                final drink = drinks.firstWhere((d) => d.id == id);
                final qty = cart.items[id] ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(drink.image, width: 50, height: 50, fit: BoxFit.cover)),
                    title: Text(drink.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Qty: $qty  |  \$${(drink.price * qty).toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove, color: Colors.red), onPressed: () => cart.removeFromCart(drink)),
                        IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: () => cart.addToCart(drink)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('\$${cart.total(drinks).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ]),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    // push CheckoutScreen with named parameters
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CheckoutScreen(cart: cart, drinks: drinks)),
                    );
                  },
                  child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
