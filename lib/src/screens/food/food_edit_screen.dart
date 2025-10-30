// lib/src/screens/food/food_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';

class FoodEditScreen extends StatefulWidget {
  final Doacao doacao;
  const FoodEditScreen({super.key, required this.doacao});

  @override
  State<FoodEditScreen> createState() => _FoodEditScreenState();
}

class _FoodEditScreenState extends State<FoodEditScreen> {
  late TextEditingController _nomeCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _imageCtrl;
  late DateTime _validade;
  String _status = 'Disponível';

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.doacao.alimento.nome);
    _descCtrl = TextEditingController(text: widget.doacao.alimento.descricao);
    _qtyCtrl = TextEditingController(text: widget.doacao.quantidade.toString());
    _imageCtrl = TextEditingController(text: widget.doacao.alimento.imageUrl ?? '');
    _validade = widget.doacao.alimento.validade;
    _status = widget.doacao.status;

    _imageCtrl.addListener(() {
      setState(() {}); // atualiza preview dinamicamente
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validade,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _validade = picked);
  }

  /// Abre diálogo de busca/seleção de usuário. Retorna o Usuário selecionado ou null.
  Future<Usuario?> _selectRecipientDialog() async {
    await MockRepository.instance.init();
    final allUsers = MockRepository.instance.allUsuarios();
    List<Usuario> results = List.from(allUsers);
    Usuario? selected;
    String query = '';

    final chosen = await showDialog<Usuario?>(
      context: context,
      barrierDismissible: true,
      builder: (dCtx) {
        return StatefulBuilder(builder: (dCtx, setStateDialog) {
          void doFilter(String q) {
            setStateDialog(() {
              query = q.trim().toLowerCase();
              if (query.isEmpty) {
                results = List.from(allUsers);
              } else {
                results = allUsers.where((u) {
                  final name = u.nomeUsuario.toLowerCase();
                  final email = u.email.toLowerCase();
                  final tel = u.tel.toLowerCase();
                  return name.contains(query) || email.contains(query) || tel.contains(query);
                }).toList();
              }
            });
          }

          return AlertDialog(
            title: const Text('Selecionar quem recebeu'),
            content: SizedBox(
              width: double.maxFinite,
              height: 350,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nome, email ou telefone',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: doFilter,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: results.isEmpty
                        ? const Center(child: Text('Nenhum usuário encontrado'))
                        : ListView.separated(
                            itemCount: results.length,
                            separatorBuilder: (_, __) => const Divider(height: 8),
                            itemBuilder: (ctx, i) {
                              final u = results[i];
                              final isSelected = selected?.id == u.id;
                              return ListTile(
                                leading: CircleAvatar(child: Text(u.nomeUsuario.isNotEmpty ? u.nomeUsuario[0].toUpperCase() : '?')),
                                title: Text(u.nomeUsuario),
                                subtitle: Text('${u.email} • ${u.tel}'),
                                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                                onTap: () {
                                  setStateDialog(() => selected = u);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dCtx).pop(null), child: const Text('Cancelar')),
              TextButton(
                onPressed: selected == null ? null : () => Navigator.of(dCtx).pop(selected),
                child: const Text('Selecionar'),
              ),
            ],
          );
        });
      },
    );

    return chosen;
  }

  void _save() async {
    if (_nomeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nome do alimento é obrigatório')));
      return;
    }

    // Se marcou como concluída, obrigamos seleção de destinatário
    int recipientId = widget.doacao.idUsuarioRec; // mantém valor atual se já tinha
    if (_status.toLowerCase().contains('conclu')) {
      // se ainda não tem destinatário ou se o usuário mudou para 'Concluída' agora, pedir seleção
      if (recipientId == 0) {
        final chosen = await _selectRecipientDialog();
        if (chosen == null) {
          // usuário cancelou seleção -> não salva
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione quem recebeu para marcar como concluída.')));
          return;
        }
        recipientId = chosen.id;
      }
    } else {
      // se voltou a Disponível, limpa recipient (opcional)
      recipientId = 0;
    }

    final updatedAlimento = widget.doacao.alimento.copyWith(
      nome: _nomeCtrl.text.trim(),
      descricao: _descCtrl.text.trim(),
      validade: _validade,
      imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
    );

    final updated = widget.doacao.copyWith(
      alimento: updatedAlimento,
      quantidade: int.tryParse(_qtyCtrl.text) ?? widget.doacao.quantidade,
      status: _status,
      idUsuarioRec: recipientId,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar doação'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nomeCtrl, decoration: const InputDecoration(labelText: 'Nome do alimento')),
            const SizedBox(height: 12),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Descrição')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantidade'))),
                const SizedBox(width: 12),
                ElevatedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today), label: Text('${_validade.day}/${_validade.month}/${_validade.year}')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _imageCtrl, decoration: const InputDecoration(labelText: 'URL da imagem (opcional)')),
            const SizedBox(height: 8),
            if (_imageCtrl.text.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageCtrl.text,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 140, color: Colors.grey[300], alignment: Alignment.center, child: const Text('URL inválida', style: TextStyle(color: Colors.black54))),
                ),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'Disponível', child: Text('Disponível')),
                DropdownMenuItem(value: 'Concluída', child: Text('Concluída')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'Disponível'),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Salvar'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
