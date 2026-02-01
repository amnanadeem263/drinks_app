import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';
import '../models/drink.dart';
import 'placeorder_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CartProvider cart;
  final List<Drink> drinks;

  const CheckoutScreen({
    Key? key,
    required this.cart,
    required this.drinks,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController =
  TextEditingController(text: "3233 Parkway Street, Cleveland, CA");

  String _paymentMethod = "Visa **** 8039";
  final List<String> _paymentOptions = [
    "Visa **** 8039",
    "Mastercard **** 6721",
    "Cash on Delivery"
  ];

  static const double deliveryFee = 200.0;

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.cart.total(widget.drinks);
    final grandTotal = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Checkout', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _cardRow(
              Icons.location_on,
              "Deliver to",
              _addressController.text,
              "Change",
                  () => _changeAddress(context),
            ),
            const SizedBox(height: 12),
            _cardRow(
              Icons.credit_card,
              "Payment Method",
              _paymentMethod,
              "Change",
                  () => _changePayment(context),
            ),
            const SizedBox(height: 16),
            _summary(subtotal, deliveryFee, grandTotal),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                // Save order to Firebase first
                final orderId = await _saveOrderToFirebase(
                  address: _addressController.text,
                  paymentMethod: _paymentMethod,
                  drinks: widget.drinks,
                  deliveryFee: deliveryFee,
                );

                // Navigate to PlaceOrderScreen after saving
                if (orderId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceOrderScreen(
                        cart: widget.cart,
                        drinks: widget.drinks,
                        address: _addressController.text,
                        paymentMethod: _paymentMethod,
                        deliveryFee: deliveryFee,
                        invoiceNumber: orderId, // Use Firestore doc ID as invoice
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Place Your Order',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardRow(
      IconData icon, String title, String subtitle, String actionText, VoidCallback onAction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionText, style: const TextStyle(color: Colors.green)),
        ),
      ]),
    );
  }

  Widget _summary(double subtotal, double delivery, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Item total'),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery charges'),
              Text('\$${delivery.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _changeAddress(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Enter new address"),
          content: TextField(
            controller: _addressController,
            decoration: const InputDecoration(hintText: "Enter address"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {}); // update UI
                Navigator.of(ctx).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _changePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Select Payment Method"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _paymentOptions.map((method) {
              return RadioListTile<String>(
                title: Text(method),
                value: method,
                groupValue: _paymentMethod,
                onChanged: (val) {
                  setState(() => _paymentMethod = val!);
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Save order data to Firestore
  Future<String?> _saveOrderToFirebase({
    required String address,
    required String paymentMethod,
    required List<Drink> drinks,
    required double deliveryFee,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final subtotal = drinks.fold(0.0, (sum, d) => sum + d.price);
      final total = subtotal + deliveryFee;

      final docRef = await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'drinks': drinks.map((d) => d.toMap()).toList(), // Ensure Drink has toMap()
        'address': address,
        'paymentMethod': paymentMethod,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return docRef.id; // Return invoice/order ID
    } catch (e) {
      print("Error saving order to Firebase: $e");
      return null;
    }
  }
}
