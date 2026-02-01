import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Drink> drinks = getDrinks();
  String selectedCategory = "All"; // 🔹 Default

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // 🔹 Apply filter
    final filteredDrinks = selectedCategory == "All"
        ? drinks
        : drinks.where((d) => d.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Good Afternoon, Ghazaleh",
                style: TextStyle(color: Colors.black, fontSize: 16)),
            Text("It's time for coffee break",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartScreen()),
                ),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.items.length.toString(),
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Buy 2\nGet a Free Cookie!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("Order Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 15),

            // Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCategory(Icons.all_inclusive, "All"),
                _buildCategory(Icons.local_cafe, "Hot drink"),
                _buildCategory(Icons.icecream, "Cold drink"),
                _buildCategory(Icons.breakfast_dining, "Breakfast"),
                _buildCategory(Icons.cake, "Muffin"),
                 // 🔹 Added All
              ],
            ),
            SizedBox(height: 20),

            // Products Grid
            Expanded(
              child: filteredDrinks.isEmpty
                  ? Center(child: Text("No products found"))
                  : GridView.builder(
                itemCount: filteredDrinks.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // two products per row
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final drink = filteredDrinks[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              drink.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(drink.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Text("\$${drink.price}",
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () {
                            cart.addToCart(drink);
                          },
                          child: Icon(Icons.add, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(IconData icon, String title) {
    final isSelected = selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title; // 🔹 Update selected category
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor:
            isSelected ? Colors.green : Colors.green.shade100,
            child: Icon(icon, color: isSelected ? Colors.white : Colors.green),
          ),
          SizedBox(height: 5),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
