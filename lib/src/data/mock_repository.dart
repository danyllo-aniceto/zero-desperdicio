import 'dart:async';
import '../models/food_item.dart';

class MockRepository {
  final List<FoodItem> _items = [
    FoodItem(
      name: 'Pão integral',
      quantity: 10,
      expiryDate: DateTime.now().add(const Duration(days: 2)),
      type: 'doacao',
      lat: -23.5505, 
      lon: -46.6333,
    ),
    FoodItem(
      name: 'Leite 1L',
      quantity: 6,
      expiryDate: DateTime.now().add(const Duration(days: 4)),
      type: 'troca',
      lat: -23.5505, // São Paulo
      lon: -46.6333,
    ),
    FoodItem(
      name: 'Frutas variadas',
      quantity: 5,
      expiryDate: DateTime.now().add(const Duration(days: 6)),
      type: 'doacao',
      lat: -23.5505, // São Paulo
      lon: -46.6333,
    ),
  ];

  Future<List<FoodItem>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 600)); // simula delay de rede
    _items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return List<FoodItem>.from(_items);
  }

  Future<void> add(FoodItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.add(item);
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _items.removeWhere((it) => it.id == id);
  }
}
