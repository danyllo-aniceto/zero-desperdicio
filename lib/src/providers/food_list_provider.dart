import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/services/mock_service.dart';

class FoodListNotifier extends StateNotifier<List<Doacao>> {
  FoodListNotifier() : super([]);

  Future<void> load() async {
    await Future.delayed(const Duration(milliseconds: 400)); // Simula delay
    state = MockService.doacoes;
  }

  void remove(int doacaoId) {
    state = state.where((d) => d.id != doacaoId).toList();
  }
}

final foodListProvider = StateNotifierProvider<FoodListNotifier, List<Doacao>>(
  (ref) => FoodListNotifier()..load(),
);
