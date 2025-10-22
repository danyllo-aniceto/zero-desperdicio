import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/screens/food/food_edit_screen.dart';
import 'compose_message_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';

class FoodDetailScreen extends StatelessWidget {
  final Doacao doacao;
  const FoodDetailScreen({super.key, required this.doacao});

  void _showMessageOptions(BuildContext context) {
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
              // redireciona para composição via email no ComposeMessageScreen
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
    return user.id == doacao.idUsuarioDoa.toString();
  }

  @override
  Widget build(BuildContext context) {
    final item = doacao.alimento;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(item.nome),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // imagem grande se houver
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(item.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[300])),
            ),
          const SizedBox(height: 16),
          Text(item.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(item.descricao, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Validade: ${item.validade.day}/${item.validade.month}/${item.validade.year}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 8),
          Text('Quantidade: ${doacao.quantidade}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 20),

          // Se NÃO for minha doação, mostro os botões que levam para a tela de composição
          if (!_isOwner) ...[
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ComposeMessageScreen(doacao: doacao, action: 'receber')),
                    );
                  },
                  icon: const Icon(Icons.handshake),
                  label: const Text('Quero receber'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showMessageOptions(context),
                icon: const Icon(Icons.message, color: Colors.green),
              ),
            ]),
          ] else ...[
            // se for minha doação, mostrar só ações relacionadas ao dono (ex: editar, marcar como concluída)
            Row(children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FoodEditScreen(doacao: doacao)),
                  );
                  if (updated != null && updated is Doacao) {
                    // volta para a tela anterior indicando atualização
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
