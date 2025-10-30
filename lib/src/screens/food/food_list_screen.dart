// lib/src/screens/food/food_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/screens/food/food_card.dart';
import 'package:zero_desperdicio/src/screens/food/food_detail_screen.dart';
import '../../providers/food_list_provider.dart';
import '../../services/auth_service.dart';

class FoodListScreen extends ConsumerStatefulWidget {
  const FoodListScreen({super.key});

  @override
  ConsumerState<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends ConsumerState<FoodListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  DateTime? _validityFilter;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(foodListProvider);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!state.loading && state.hasMore) {
        ref.read(foodListProvider.notifier).loadMore();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Filtra a lista:
  /// - if onlyMine == true -> mostra apenas itens onde sou dono **e não estão concluídos**
  /// - if onlyMine == false -> mostra itens onde NÃO sou dono, NÃO estão concluídos e NÃO foram atribuídos (idUsuarioRec == 0)
  List<Doacao> _applyFilters(List<Doacao> list, {required bool onlyMine}) {
    final user = AuthService.instance.currentUser.value;
    return list.where((d) {
      final bool isOwner = user != null && user.id == d.idUsuarioDoa.toString();
      final bool isConcluded = d.status.toLowerCase().contains('conclu');
      final bool isAssigned = d.idUsuarioRec != 0;

      if (onlyMine) {
        if (!isOwner) return false;
        if (isConcluded) return false; // remove concluídas da aba "Minhas doações"
      } else {
        // Disponíveis -> não sou dono, não concluída, não atribuída
        if (isOwner) return false;
        if (isConcluded) return false;
        if (isAssigned) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nome = d.alimento.nome.toLowerCase();
        if (!nome.contains(q)) return false;
      }
      if (_validityFilter != null) {
        final deadline = DateTime(_validityFilter!.year, _validityFilter!.month, _validityFilter!.day, 23, 59, 59);
        if (d.alimento.validade.isAfter(deadline)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickValidityDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validityFilter ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _validityFilter = picked);
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _validityFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginated = ref.watch(foodListProvider);
    final allLoaded = paginated.items;
    final user = AuthService.instance.currentUser.value;
    final pageSize = ref.read(foodListProvider.notifier).pageSize;
    final totalPages = (paginated.totalCount / pageSize).ceil();

    // listas já filtradas para exibição
    final disponiveis = _applyFilters(allLoaded, onlyMine: false);
    final minhas = _applyFilters(allLoaded, onlyMine: true);

    // total realmente disponíveis (considerando apenas os items carregados)
    final totalAvailableLoaded = allLoaded.where((d) {
      final isOwner = user != null && user.id == d.idUsuarioDoa.toString();
      final isConcluded = d.status.toLowerCase().contains('conclu');
      final isAssigned = d.idUsuarioRec != 0;
      return !isOwner && !isConcluded && !isAssigned;
    }).length;
    final filteredAvailable = disponiveis.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Alimentos disponíveis'),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Disponíveis'),
            Tab(text: 'Minhas doações'),
          ],
        ),
      ),
      body: Column(
        children: [
          // filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar por nome do alimento',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    controller: TextEditingController.fromValue(TextEditingValue(text: _searchQuery, selection: TextSelection.collapsed(offset: _searchQuery.length))),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _pickValidityDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(_validityFilter == null ? 'Validade' : '${_validityFilter!.day}/${_validityFilter!.month}/${_validityFilter!.year}', style: const TextStyle(color: Colors.black87)),
                        if (_validityFilter != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(onTap: () => setState(() => _validityFilter = null), child: const Icon(Icons.close, size: 18, color: Colors.black45)),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(tooltip: 'Limpar filtros', icon: const Icon(Icons.filter_alt_off), onPressed: _clearFilters),
              ],
            ),
          ),

          if (_tabController.index == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mostrando $filteredAvailable de $totalAvailableLoaded disponíveis para você receber',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // lista + páginas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(disponiveis, paginated),
                _buildListView(minhas, paginated),
              ],
            ),
          ),

          // BARRA DE PAGINAÇÃO POR BOTÕES (Anterior / Página X / Próximo)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: (paginated.page > 1 && !paginated.loading) ? () => ref.read(foodListProvider.notifier).prevPage() : null,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                  label: const Text('Anterior'),
                ),
                const SizedBox(width: 12),
                Text('Página ${paginated.page == 0 ? 1 : paginated.page} de ${totalPages == 0 ? 1 : totalPages}'),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: (paginated.hasMore && !paginated.loading) ? () => ref.read(foodListProvider.notifier).nextPage() : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  label: const Text('Próximo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Doacao> list, PaginatedDoacoesState paginated) {
    if (list.isEmpty && !paginated.loading) {
      return const Center(child: Text('Nenhum resultado.', style: TextStyle(fontSize: 16, color: Colors.black54)));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(foodListProvider.notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: list.length + (paginated.loading ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= list.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final doacao = list[i];
          return FoodCard(
            item: doacao,
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailScreen(doacao: doacao)));
              // se veio resultado de edição/remocao (opcional) podemos tratar aqui (não obrigatório)
              if (result == 'updated' || result == 'removed') {
                await ref.read(foodListProvider.notifier).loadPage(ref.read(foodListProvider).page == 0 ? 1 : ref.read(foodListProvider).page);
              }
            },
            onDelete: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Remover doação'),
                  content: const Text('Tem certeza que deseja remover esta doação?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remover')),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(foodListProvider.notifier).removeDoacao(doacao.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${doacao.alimento.nome} removido (mock).')));
              }
            },
          );
        },
      ),
    );
  }
}
