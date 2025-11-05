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
  List<Usuario> _usuarios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    await MockRepository.instance.init();
    setState(() {
      _usuarios = MockRepository.instance.allUsuarios();
      _loading = false;
    });
  }

  Future<void> _updateStatus(Usuario user, String newStatus) async {
    final updated = user.copyWith(status: newStatus);
    final list = MockRepository.instance.usuarios;
    final idx = list.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      list[idx] = updated;
      await MockRepository.instance.init(); // apenas garante persistência
      await MockRepository.instance
          .init(forceReset: false); // força regravação
      await MockRepository.instance
          .init(); // workaround para garantir sincronização
      await _saveChanges();
      setState(() {});
    }
  }

  Future<void> _saveChanges() async {
    await MockRepository.instance.init();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Administrador'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsuarios,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _usuarios.length,
                itemBuilder: (context, i) {
                  final u = _usuarios[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        u.isAdmin
                            ? Icons.shield
                            : (u.tipo == 'ong'
                                ? Icons.volunteer_activism
                                : Icons.person),
                        color: u.isAdmin
                            ? Colors.blue
                            : (u.tipo == 'ong' ? Colors.green : Colors.grey),
                      ),
                      title: Text(u.nomeUsuario),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${u.email} (${u.tipo})'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('Status: ',
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                u.status,
                                style: TextStyle(color: _statusColor(u.status)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: _buildActions(u),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildActions(Usuario u) {
    if (u.isAdmin) return const SizedBox();

    final buttons = <Widget>[];

    if (u.status == 'pendente' && u.tipo == 'ong') {
      buttons.add(
        IconButton(
          tooltip: 'Aprovar ONG',
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () async {
            await _updateStatus(u, 'ativo');
            await _loadUsuarios();
          },
        ),
      );
    }

    if (u.status != 'bloqueado') {
      buttons.add(
        IconButton(
          tooltip: 'Bloquear usuário',
          icon: const Icon(Icons.block, color: Colors.red),
          onPressed: () async {
            await _updateStatus(u, 'bloqueado');
            await _loadUsuarios();
          },
        ),
      );
    } else {
      buttons.add(
        IconButton(
          tooltip: 'Desbloquear usuário',
          icon: const Icon(Icons.lock_open, color: Colors.orange),
          onPressed: () async {
            await _updateStatus(u, 'ativo');
            await _loadUsuarios();
          },
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }
}
