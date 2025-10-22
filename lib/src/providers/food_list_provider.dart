// lib/src/providers/food_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/services/mock_service.dart';

class PaginatedDoacoesState {
  final List<Doacao> items;
  final int page;
  final bool loading;
  final bool hasMore;
  final int totalCount;
  const PaginatedDoacoesState({
    required this.items,
    required this.page,
    required this.loading,
    required this.hasMore,
    required this.totalCount,
  });

  PaginatedDoacoesState copyWith({
    List<Doacao>? items,
    int? page,
    bool? loading,
    bool? hasMore,
    int? totalCount,
  }) {
    return PaginatedDoacoesState(
      items: items ?? this.items,
      page: page ?? this.page,
      loading: loading ?? this.loading,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  factory PaginatedDoacoesState.initial() => const PaginatedDoacoesState(items: [], page: 0, loading: false, hasMore: true, totalCount: 0);
}

class FoodListNotifier extends StateNotifier<PaginatedDoacoesState> {
  FoodListNotifier({this.pageSize = 10}) : super(PaginatedDoacoesState.initial());

  final int pageSize;

  Future<void> loadInitial() async => loadPage(1);

  Future<void> loadPage(int page) async {
    if (state.loading) return;
    state = state.copyWith(loading: true);
    final total = await MockService.fetchDoacoesTotalCount();
    final fetched = await MockService.fetchDoacoesPaged(page: page, pageSize: pageSize);
    final hasMore = fetched.length == pageSize;
    state = state.copyWith(items: fetched, page: page, loading: false, hasMore: hasMore, totalCount: total);
  }

  Future<void> nextPage() async {
    if (state.loading || !state.hasMore) return;
    await loadPage(state.page + 1);
  }

  Future<void> prevPage() async {
    if (state.loading || state.page <= 1) return;
    await loadPage(state.page - 1);
  }

  Future<void> loadMore() async {
    // mantém compatibilidade com infinite scroll: appenda resultados
    if (state.loading || !state.hasMore) return;
    state = state.copyWith(loading: true);
    final nextPage = state.page + 1;
    final fetched = await MockService.fetchDoacoesPaged(page: nextPage, pageSize: pageSize);
    final hasMore = fetched.length == pageSize;
    final combined = List<Doacao>.from(state.items)..addAll(fetched);
    final total = await MockService.fetchDoacoesTotalCount();
    state = state.copyWith(items: combined, page: nextPage, loading: false, hasMore: hasMore, totalCount: total);
  }

  Future<void> refresh() async {
    state = state.copyWith(items: [], page: 0, hasMore: true);
    await loadInitial();
  }

  Future<void> removeDoacao(int id) async {
    await MockService.removeDoacaoMock(id);
    // recarrega a página atual mantendo paginação
    final currentPage = state.page <= 0 ? 1 : state.page;
    await loadPage(currentPage);
  }

  Future<void> editDoacao(Doacao updated) async {
    await MockService.updateDoacaoMock(updated);
    final currentPage = state.page <= 0 ? 1 : state.page;
    await loadPage(currentPage);
  }
}

final foodListProvider = StateNotifierProvider<FoodListNotifier, PaginatedDoacoesState>(
  (ref) => FoodListNotifier(pageSize: 10)..loadInitial(),
);
