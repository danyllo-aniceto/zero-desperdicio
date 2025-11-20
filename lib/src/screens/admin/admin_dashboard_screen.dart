import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';
import 'package:zero_desperdicio/src/screens/loginAndRegister/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Usuario> _allUsers = [];
  bool _loading = true;

  // filtros & paginação
  String _search = '';
  String? _statusFilter; // 'ativo' | 'pendente' | 'bloqueado' | null
  String? _tipoFilter; // 'normal' | 'ong' | null
  int _page = 1;
  final int _pageSize = 8;

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    setState(() => _loading = true);
    await MockRepository.instance.init();
    setState(() {
      _allUsers = MockRepository.instance.allUsuarios();
      _loading = false;
      _page = 1;
    });
  }

  List<Usuario> get _filtered {
    var list = _allUsers.where((u) {
      // filtro tipo
      if (_tipoFilter != null && u.tipo != _tipoFilter) return false;
      // filtro status
      if (_statusFilter != null && u.status != _statusFilter) return false;
      // busca por nome/email
      final q = _search.trim().toLowerCase();
      if (q.isEmpty) return true;
      return u.nomeUsuario.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => a.nomeUsuario.toLowerCase().compareTo(b.nomeUsuario.toLowerCase()));
    return list;
  }

  List<Usuario> get _pageItems {
    final f = _filtered;
    final start = (_page - 1) * _pageSize;
    if (start >= f.length) return [];
    final end = (start + _pageSize) > f.length ? f.length : (start + _pageSize);
    return f.sublist(start, end);
  }

  Future<void> _updateStatusWithConfirm(Usuario user, String newStatus) async {
    // não permitir ações em admin
    if (user.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ação não permitida em administrador.')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(newStatus == 'ativo'
            ? 'Aprovar usuário'
            : (newStatus == 'bloqueado' ? 'Bloquear usuário' : 'Confirmar')),
        content: Text('Tem certeza que deseja alterar o status de "${user.nomeUsuario}" para "$newStatus"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar', style: TextStyle(color: Colors.white),)),
        ],
      ),
    );

    if (confirmed != true) return;

    await _updateStatus(user, newStatus);
  }

  Future<void> _updateStatus(Usuario user, String newStatus) async {
    final updated = user.copyWith(status: newStatus);
    await MockRepository.instance.updateUsuario(updated);
    await _loadUsuarios();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status de ${user.nomeUsuario} definido para "$newStatus".')));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ativo':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'bloqueado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Pesquisar por nome ou email',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() {
                _search = v;
                _page = 1;
              }),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String?>(
            value: _tipoFilter,
            hint: const Text('Tipo'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: 'normal', child: Text('Usuário')),
              DropdownMenuItem(value: 'ong', child: Text('ONG')),
            ],
            onChanged: (v) => setState(() {
              _tipoFilter = v;
              _page = 1;
            }),
          ),
          const SizedBox(width: 8),
          DropdownButton<String?>(
            value: _statusFilter,
            hint: const Text('Status'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
              DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
              DropdownMenuItem(value: 'bloqueado', child: Text('Bloqueado')),
            ],
            onChanged: (v) => setState(() {
              _statusFilter = v;
              _page = 1;
            }),
          ),
        ]),
      ]),
    );
  }

  Widget _buildUserTile(Usuario u) {
    final tipoLabel = u.isAdmin ? 'admin' : u.tipo;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          u.isAdmin ? Icons.shield : (u.tipo == 'ong' ? Icons.volunteer_activism : Icons.person),
          color: u.isAdmin ? Colors.blue : (u.tipo == 'ong' ? Colors.green : Colors.grey),
        ),
        title: Text(u.nomeUsuario),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${u.email} — ${tipoLabel}'),
          const SizedBox(height: 6),
          Row(children: [
            const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(u.status, style: TextStyle(color: _statusColor(u.status))),
          ]),
        ]),
        trailing: _actionsFor(u),
      ),
    );
  }

  Widget _actionsFor(Usuario u) {
    // nada para admin
    if (u.isAdmin) return const SizedBox.shrink();

    final List<Widget> actions = [];

    // If pending + ONG -> show approve
    if (u.status == 'pendente' && u.tipo == 'ong') {
      actions.add(IconButton(
        tooltip: 'Aprovar ONG',
        icon: const Icon(Icons.check_circle, color: Colors.green),
        onPressed: () => _updateStatusWithConfirm(u, 'ativo'),
      ));
    }

    if (u.status != 'bloqueado') {
      actions.add(IconButton(
        tooltip: 'Bloquear usuário',
        icon: const Icon(Icons.block, color: Colors.red),
        onPressed: () => _updateStatusWithConfirm(u, 'bloqueado'),
      ));
    } else {
      actions.add(IconButton(
        tooltip: 'Desbloquear usuário',
        icon: const Icon(Icons.lock_open, color: Colors.orange),
        onPressed: () => _updateStatusWithConfirm(u, 'ativo'),
      ));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  @override
  Widget build(BuildContext context) {
    final totalFiltered = _filtered.length;
    final totalPages = (totalFiltered / _pageSize).ceil().clamp(1, 9999);
    final pageItems = _pageItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsuarios),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Mostrando ${pageItems.length} de $totalFiltered usuário(s) — página $_page / $totalPages', style: const TextStyle(color: Colors.black54))),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadUsuarios,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pageItems.length,
                      itemBuilder: (context, i) => _buildUserTile(pageItems[i]),
                    ),
                  ),
                ),
                // Paginação
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.grey.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _page > 1 ? () => setState(() => _page = _page - 1) : null,
                        icon: const Icon(Icons.arrow_back_ios_new, size: 14),
                        label: const Text('Anterior'),
                      ),
                      const SizedBox(width: 12),
                      Text('Página $_page de $totalPages'),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _page < totalPages ? () => setState(() => _page = _page + 1) : null,
                        icon: const Icon(Icons.arrow_forward_ios, size: 14),
                        label: const Text('Próximo'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
