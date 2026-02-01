import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/drink.dart';

class ApiService {
  Future<List<Drink>> fetchDrinks() async {
    final String response = await rootBundle.loadString('assets/drinks.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Drink.fromJson(json)).toList();
  }
}
