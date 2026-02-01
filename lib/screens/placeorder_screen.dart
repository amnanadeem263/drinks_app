import 'package:drinks_app/models/drink.dart';
import 'package:drinks_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// OpenStreetMap Packages
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceOrderScreen extends StatelessWidget {
  final String invoiceNumber;
  final String estimatedTime;
  final String address; // Customer address from checkout

  const PlaceOrderScreen({
    Key? key,
    this.invoiceNumber = "12A394",
    this.estimatedTime = "10:32",
    required this.address,
    required double deliveryFee,
    required String paymentMethod,
    required List<Drink> drinks,
    required CartProvider cart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String orderPlacedTime = formatDateTime(now);
    String deliveredTime = formatDateTime(now.add(const Duration(minutes: 30)));

    final LatLng cafeLocation = LatLng(31.5204, 74.3587); // Gulberg Cafe

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Status",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.green.shade100,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Timeline Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "INVOICE : $invoiceNumber",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                _orderTimeline(orderPlacedTime, deliveredTime),
              ],
            ),
          ),
          const Divider(),
          // Map + Delivery Section
          Expanded(
            child: Stack(
              children: [
                // Map showing Gulberg cafe → delivery address
                FutureBuilder<LatLng>(
                  future: _getCustomerLocation(address),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final customerLocation = snapshot.data!;

                    return FutureBuilder<List<LatLng>>(
                      future: _getRoute(cafeLocation, customerLocation),
                      builder: (context, routeSnapshot) {
                        List<LatLng> routePoints = [];
                        if (routeSnapshot.hasData) {
                          routePoints = routeSnapshot.data!;
                        }

                        return FlutterMap(
                          options: MapOptions(
                            center: LatLng(
                              (cafeLocation.latitude + customerLocation.latitude) / 2,
                              (cafeLocation.longitude + customerLocation.longitude) / 2,
                            ),
                            zoom: 13,
                          ),
                          children: [
                            // Map tiles
                            TileLayer(
                              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: 'com.example.drinks_app',
                            ),

                            // Cafe & Customer markers
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: cafeLocation,
                                  width: 50,
                                  height: 50,
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                ),
                                Marker(
                                  point: customerLocation,
                                  width: 50,
                                  height: 50,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 45,
                                  ),
                                ),
                              ],
                            ),

                            // Route polyline (if available)
                            if (routePoints.isNotEmpty)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: routePoints,
                                    strokeWidth: 4,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),

                // Delivery Card with Rider Image
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Your Delivery",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "INVOICE: $invoiceNumber",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        // Rider Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/rider.jpg",
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Format DateTime into readable string
  String formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm a, d MMM yyyy').format(dateTime);
  }

  /// Timeline
  Widget _orderTimeline(String orderPlacedTime, String deliveredTime) {
    return Column(
      children: [
        _timelineTile(title: "Order Placed", time: orderPlacedTime, isActive: true),
        _timelineTile(title: "Delivered", time: deliveredTime, isActive: false),
      ],
    );
  }

  Widget _timelineTile({required String title, required String time, bool isActive = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(Icons.circle, size: 16, color: isActive ? Colors.green : Colors.grey),
            Container(width: 2, height: 40, color: Colors.grey)
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        )
      ],
    );
  }

  /// Convert delivery address to LatLng using Geocoding
  Future<LatLng> _getCustomerLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print("Error in geocoding: $e");
    }
    return LatLng(31.5204, 74.3587);
  }

  /// Get real route from ORS using GeoJSON response
  Future<List<LatLng>> _getRoute(LatLng start, LatLng end) async {
    const apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjY4OTQ1ZWRlZDIwZDRkODg4NGY1NWVhYjRjOTM4MGQ2IiwiaCI6Im11cm11cjY0In0=';
    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'] != null && data['features'].isNotEmpty) {
        final coordinates = data['features'][0]['geometry']['coordinates'] as List<dynamic>;
        final routePoints = coordinates.map((point) {
          final lng = point[0] as double;
          final lat = point[1] as double;
          return LatLng(lat, lng);
        }).toList();

        return routePoints;
      }
    }
    return [start, end];
  }
}
