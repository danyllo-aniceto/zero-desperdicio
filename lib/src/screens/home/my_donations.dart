// lib/src/screens/home/my_donations_screen.dart
import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Doacao> _mine = [];
  List<Doacao> _received = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await MockRepository.instance.init();
    final user = AuthService.instance.currentUser.value;
    if (user == null) {
      setState(() {
        _mine = [];
        _received = [];
        _loading = false;
      });
      return;
    }
    final myId = int.tryParse(user.id) ?? -1;
    final all = MockRepository.instance.allDoacoes();

    // Todos os itens do usuário (Minhas) — somente os CONCLUÍDOS (histórico)
    final mine = all
        .where((d) =>
            d.idUsuarioDoa == myId &&
            d.status.toLowerCase().contains('conclu')) // filtra concluídas (tolerante)
        .toList()
      ..sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));

    // Recebidas: somente as concluídas onde eu sou recebedor
    final received = all
        .where((d) =>
            d.idUsuarioRec == myId &&
            d.status.toLowerCase().contains('conclu'))
        .toList()
      ..sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));

    setState(() {
      _mine = mine;
      _received = received;
      _loading = false;
    });
  }

  Future<void> _refresh() async => _loadAll();

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  Widget _buildList(List<Doacao> items) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [
          SizedBox(height: 120),
          Center(child: Text('Nenhum registro.', style: TextStyle(fontSize: 16, color: Colors.black54))),
        ]),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final d = items[i];
          final food = d.alimento;
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: (food.imageUrl != null && food.imageUrl!.isNotEmpty)
                          ? Image.network(food.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]))
                          : Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 36, color: Colors.black38)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(food.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(food.descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text('Qtd: ${d.quantidade}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(width: 12),
                        Text('Validade: ${food.validade.day}/${food.validade.month}/${food.validade.year}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ]),
                      const SizedBox(height: 6),
                      Text('Cadastrado: ${_formatDate(d.dataCadastro)}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ]),
                  ),
                  Column(children: [
                    Text(d.status, style: TextStyle(color: d.status.toLowerCase().contains('dispon') ? Colors.green : Colors.grey[700], fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    // Histórico: somente visualização — sem editar/remover
                    IconButton(icon: const Icon(Icons.remove_red_eye, color: Colors.grey), onPressed: () {
                      // opcional: abrir detalhe se quiser — por enquanto só visualização inativa
                    }, tooltip: 'Visualizar'),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas doações / recebimentos'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Minhas doações'),
            Tab(text: 'Recebidas'),
          ],
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Minhas doações (apenas concluídas, leitura)
          _buildList(_mine),
          // Recebidas / histórico (apenas concluídas, leitura)
          _buildList(_received),
        ],
      ),
      // histórico não permite criar nem editar — sem FAB
    );
  }
}
