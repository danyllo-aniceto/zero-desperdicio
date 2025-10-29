// lib/src/screens/food/food_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';

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

    // Atualiza o preview da imagem dinamicamente
    _imageCtrl.addListener(() => setState(() {}));
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

  void _save() {
    if (_nomeCtrl.text.trim().isEmpty) return;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome do alimento'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageCtrl,
              decoration: const InputDecoration(
                labelText: 'URL da imagem (opcional)',
                hintText: 'https://exemplo.com/imagem.jpg',
              ),
            ),
            const SizedBox(height: 12),

            if (_imageCtrl.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _imageCtrl.text,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text(
                        'URL inválida',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_validade.day}/${_validade.month}/${_validade.year}',
                    ),
                  ),
                ),
              ],
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
