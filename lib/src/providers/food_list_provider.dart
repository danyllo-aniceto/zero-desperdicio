import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_repository.dart';
import '../models/food_item.dart';

/// Provider para o repositório simulado
final mockRepoProvider = Provider<MockRepository>((ref) => MockRepository());

/// Provider que mantém a lista de alimentos em memória
final foodListProvider = StateNotifierProvider<FoodListNotifier, List<FoodItem>>(
  (ref) => FoodListNotifier(ref),
);

class FoodListNotifier extends StateNotifier<List<FoodItem>> {
  final Ref ref;
  FoodListNotifier(this.ref) : super([]) {
    load();
  }

  Future<void> load() async {
    final repo = ref.read(mockRepoProvider);
    final items = await repo.fetchAll();
    state = items;
  }

  Future<void> add(FoodItem item) async {
    final repo = ref.read(mockRepoProvider);
    await repo.add(item);
    await load();
  }

  Future<void> remove(String id) async {
    final repo = ref.read(mockRepoProvider);
    await repo.delete(id);
    await load();
  }
}
