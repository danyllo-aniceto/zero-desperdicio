// lib/src/screens/food/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/screens/food/food_edit_screen.dart';
import 'compose_message_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'package:zero_desperdicio/src/providers/food_list_provider.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';

class FoodDetailScreen extends StatefulWidget {
  final Doacao doacao;
  const FoodDetailScreen({super.key, required this.doacao});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late Future<Usuario?> _creatorFuture;

  @override
  void initState() {
    super.initState();
    _creatorFuture = _loadCreator();
  }

  Future<Usuario?> _loadCreator() async {
    try {
      await MockRepository.instance.init();
    } catch (_) {
      // ignore init error; try to continue with whatever exists
    }
    try {
      final all = MockRepository.instance.allUsuarios();
      return all.firstWhere((u) => u.id == widget.doacao.idUsuarioDoa);
    } catch (_) {
      return null;
    }
  }

  void _showMessageOptions(BuildContext context, Doacao doacao) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.email, color: Colors.green),
            title: const Text('Enviar email'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ComposeMessageScreen(doacao: doacao, action: 'receber')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.abc, color: Colors.green),
            title: const Text('Enviar WhatsApp'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ComposeMessageScreen(doacao: doacao, action: 'receber')));
            },
          ),
        ]),
      ),
    );
  }

  bool get _isOwner {
    final user = AuthService.instance.currentUser.value;
    if (user == null) return false;
    return user.id == widget.doacao.idUsuarioDoa.toString();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.doacao.alimento;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(item.nome),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[300]),
              ),
            ),
          const SizedBox(height: 16),
          Text(item.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(item.descricao, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Validade: ${item.validade.day}/${item.validade.month}/${item.validade.year}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 8),
          Text('Quantidade: ${widget.doacao.quantidade}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 20),

          // --- Criador / Responsável (buscado do mock) ---
          FutureBuilder<Usuario?>(
            future: _creatorFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2.0))),
                );
              }
              final creator = snap.data;
              if (creator == null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 36, color: Colors.black54),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Responsável não disponível', style: TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                );
              }

              final isCurrentUser = AuthService.instance.currentUser.value?.id == creator.id.toString();

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 36, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(creator.nomeUsuario, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(creator.email, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 2),
                          Text(creator.tel, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          if (isCurrentUser) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Você', style: TextStyle(fontSize: 12, color: Colors.green))),
                        ]),
                      ),
                      IconButton(
                        tooltip: 'Enviar mensagem',
                        onPressed: () => _showMessageOptions(context, widget.doacao),
                        icon: const Icon(Icons.message, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Ações: se não for dono, botão "Quero receber"; se for dono, botão Editar
          if (!_isOwner) ...[
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ComposeMessageScreen(doacao: widget.doacao, action: 'receber')));
                  },
                  icon: const Icon(Icons.handshake),
                  label: const Text('Quero receber'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(onPressed: () => _showMessageOptions(context, widget.doacao), icon: const Icon(Icons.message, color: Colors.green)),
            ]),
          ] else ...[
            Row(children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<Doacao>(
                    context,
                    MaterialPageRoute(builder: (_) => FoodEditScreen(doacao: widget.doacao)),
                  );

                  if (updated != null) {
                    // atualiza provider e persiste
                    ProviderScope.containerOf(context, listen: false).read(foodListProvider.notifier).updateDoacao(updated);
                    await ProviderScope.containerOf(context, listen: false).read(foodListProvider.notifier).editDoacao(updated);
                    Navigator.pop(context, 'updated');
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}
