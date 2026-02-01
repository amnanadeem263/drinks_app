class Drink {
  final int id;
  final String name;
  final double price;
  final String image;
  final String category;

  Drink({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });

  // Create a Drink from JSON (from API or local JSON)
  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      category: json['category'] as String,
    );
  }

  // Convert Drink object to Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
    };
  }
}

// Sample data
final List<Map<String, dynamic>> drinksJson = [
  {"id": 1, "name": "Strawberry Lemonade", "price": 3.3, "image": "assets/strawberry.jpg", "category": "Cold drink"},
  {"id": 2, "name": "Mint", "price": 2.4, "image": "assets/mint.jpg", "category": "Cold drink"},
  {"id": 3, "name": "Orange Juice", "price": 2.0, "image": "assets/orange.jpg", "category": "Cold drink"},
  {"id": 4, "name": "Cappuccino", "price": 3.5, "image": "assets/cappicino.jpg", "category": "Hot drink"},
  {"id": 5, "name": "Latte", "price": 3.8, "image": "assets/latte.jpg", "category": "Hot drink"},
  {"id": 6, "name": "Pancake", "price": 4.5, "image": "assets/pancakes.jpg", "category": "Breakfast"},
  {"id": 7, "name": "Chocolate Muffins", "price": 5.5, "image": "assets/chocolatemuffins.jpg", "category": "Muffin"},
  {"id": 8, "name": "Sandwich", "price": 5.3, "image": "assets/sandwich.jpg", "category": "Breakfast"},
  {"id": 9, "name": "Crossaint", "price": 4.3, "image": "assets/crossaint.jpg", "category": "Breakfast"},
  {"id": 10, "name": "French Toast", "price": 4.7, "image": "assets/frenchtoast.jpg", "category": "Breakfast"},
  {"id": 11, "name": "Banana Muffins", "price": 5.7, "image": "assets/banana.jpg", "category": "Muffin"},
  {"id": 12, "name": "Strawberry Muffins", "price": 5.6, "image": "assets/strwaberrymuffin.jpg", "category": "Muffin"},
];

// Convert JSON list to Drink objects
List<Drink> getDrinks() => drinksJson.map((e) => Drink.fromJson(e)).toList();
