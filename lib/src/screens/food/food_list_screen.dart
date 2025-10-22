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
  DateTime? _validityFilter; // se null -> sem filtro

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // rebuild para atualizar o texto de contagem quando trocar de tab
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Aplica filtros locais (search + validade) sobre a lista de doações
  List<Doacao> _applyFilters(List<Doacao> list, {required bool onlyMine}) {
    final user = AuthService.instance.currentUser.value;
    return list.where((d) {
      // isOwner: true se a doação foi criada pelo usuário logado
      final bool isOwner = user != null && user.id == d.idUsuarioDoa.toString();

      // --- filtro por tab ---
      // se estamos na tab "Minhas doações", mostramos somente as doações cujo dono é o usuário
      // se estamos na tab "Disponíveis", mostramos somente doações NÃO do usuário e que não estejam 'Concluída'
      final bool tabMatch = onlyMine ? isOwner : (!isOwner && d.status.toLowerCase() != 'concluída');

      if (!tabMatch) return false;

      // --- filtro por busca no nome do alimento ---
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nome = d.alimento.nome.toLowerCase();
        if (!nome.contains(q)) return false;
      }

      // --- filtro por validade (datepicker) ---
      if (_validityFilter != null) {
        final deadline = DateTime(
          _validityFilter!.year,
          _validityFilter!.month,
          _validityFilter!.day,
          23,
          59,
          59,
        );
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
    final doacoes = ref.watch(foodListProvider);
    final user = AuthService.instance.currentUser.value;

    // listas filtradas
    final disponiveis = _applyFilters(doacoes, onlyMine: false);
    final minhas = _applyFilters(doacoes, onlyMine: true);

    // cálculo para "Mostrando X de Y disponíveis"
    final totalAvailable = doacoes.where((d) {
      final isOwner = user != null && user.id == d.idUsuarioDoa.toString();
      return !isOwner && d.status.toLowerCase() != 'concluída';
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

      // conteúdo com campo de busca e filtro
      body: Column(
        children: [
          // filtros - search + validade + limpar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Search field (expand)
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar por nome do alimento',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: _searchQuery,
                        selection: TextSelection.collapsed(offset: _searchQuery.length),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Validity filter button (usa DatePicker)
                InkWell(
                  onTap: () => _pickValidityDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          _validityFilter == null
                              ? 'Validade'
                              : '${_validityFilter!.day}/${_validityFilter!.month}/${_validityFilter!.year}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        if (_validityFilter != null) ...[
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _validityFilter = null),
                            child: const Icon(Icons.close, size: 18, color: Colors.black45),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Clear all filters
                IconButton(
                  tooltip: 'Limpar filtros',
                  icon: const Icon(Icons.filter_alt_off),
                  onPressed: _clearFilters,
                ),
              ],
            ),
          ),

          // show counts when on Disponíveis tab
          if (_tabController.index == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mostrando $filteredAvailable de $totalAvailable disponíveis',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 0: Disponíveis
                _buildListView(disponiveis),

                // Tab 1: Minhas doações
                _buildListView(minhas),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Doacao> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum resultado.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(foodListProvider.notifier).load();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final doacao = list[i];
          return FoodCard(
            item: doacao,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FoodDetailScreen(doacao: doacao)),
              );
            },
            onDelete: () {
              // confirmação antes de remover
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Remover doação'),
                  content: const Text('Tem certeza que deseja remover esta doação?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                    TextButton(
                      onPressed: () {
                        // remove do provider (mock)
                        ref.read(foodListProvider.notifier).remove(doacao.id);
                        Navigator.pop(context); // fecha dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${doacao.alimento.nome} removido (mock).')),
                        );
                      },
                      child: const Text('Remover'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
