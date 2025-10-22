import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_item.dart';
import '../../providers/food_list_provider.dart';

class FoodFormScreen extends ConsumerStatefulWidget {
  const FoodFormScreen({super.key});

  @override
  ConsumerState<FoodFormScreen> createState() => _FoodFormScreenState();
}

class _FoodFormScreenState extends ConsumerState<FoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  DateTime? _expiryDate;
  String _type = 'doacao';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Alimento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // nome do alimento
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do alimento',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),

              // quantidade
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe a quantidade';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Quantidade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // validade
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _expiryDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de validade',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _expiryDate != null
                        ? '${_expiryDate!.day.toString().padLeft(2, '0')}/${_expiryDate!.month.toString().padLeft(2, '0')}/${_expiryDate!.year}'
                        : 'Selecionar data',
                    style: TextStyle(
                      color: _expiryDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // tipo (doação ou troca)
              const Text('Tipo de item', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Doação'),
                      value: 'doacao',
                      groupValue: _type,
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Troca'),
                      value: 'troca',
                      groupValue: _type,
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // botão salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Salvar alimento'),
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma data de validade')),
      );
      return;
    }

    final item = FoodItem(
      name: _nameController.text.trim(),
      quantity: int.parse(_quantityController.text),
      expiryDate: _expiryDate!,
      type: _type,
    );

    //await ref.read(foodListProvider.notifier).add(item);

    if (mounted) {
      Navigator.pop(context, 'added');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alimento adicionado com sucesso!')),
      );
    }
  }
}
