import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink.dart';
import '../providers/cart_provider.dart';

class DrinkCard extends StatelessWidget {
  final Drink drink;
  DrinkCard({required this.drink});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Image.network(
            drink.image,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(drink.name),
        subtitle: Text("\$${drink.price}"),
        trailing: ElevatedButton(
          child: Text("Add"),
          onPressed: () => cart.addToCart(drink),
        ),
      ),
    );
  }
}
