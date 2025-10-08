import 'package:uuid/uuid.dart';

class FoodItem {
  final String id;
  final String name;
  final int quantity;
  final DateTime expiryDate;
  final String type; // exemplo: 'doacao' ou 'troca'
  final String? photo;
  final double? lat; // 👈 adicionados
  final double? lon; // 👈 adicionados

  FoodItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.type,
    this.photo,
    this.lat,
    this.lon,
  }) : id = id ?? const Uuid().v4();

  /// Retorna a diferença em dias até a validade
  int daysToExpiry() {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Cópia imutável do item com valores alterados
  FoodItem copyWith({
    String? id,
    String? name,
    int? quantity,
    DateTime? expiryDate,
    String? type,
    String? photo,
    double? lat,
    double? lon,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      type: type ?? this.type,
      photo: photo ?? this.photo,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }
}
