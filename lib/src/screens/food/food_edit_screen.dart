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
  late DateTime _validade;
  String _status = 'Disponível';

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.doacao.alimento.nome);
    _descCtrl = TextEditingController(text: widget.doacao.alimento.descricao);
    _qtyCtrl = TextEditingController(text: widget.doacao.quantidade.toString());
    _validade = widget.doacao.alimento.validade;
    _status = widget.doacao.status;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _qtyCtrl.dispose();
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
    // final updatedAlimento = widget.doacao.alimento.copyWith(
    //   nome: _nomeCtrl.text.trim(),
    //   descricao: _descCtrl.text.trim(),
    //   validade: _validade,
    // );

    // final updated = widget.doacao.copyWith(
    //   alimento: updatedAlimento,
    //   quantidade: int.tryParse(_qtyCtrl.text) ?? widget.doacao.quantidade,
    //   status: _status,
    // );

    // Navigator.pop(context, updated);
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
