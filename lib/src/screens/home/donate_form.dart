import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/providers/food_list_provider.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'package:zero_desperdicio/src/services/mock_service.dart';

class DonateFormScreen extends ConsumerStatefulWidget {
  const DonateFormScreen({super.key});

  @override
  ConsumerState<DonateFormScreen> createState() => _DonateFormScreenState();
}

class _DonateFormScreenState extends ConsumerState<DonateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  DateTime? _validade;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _imageCtrl.addListener(() {
      // Garante que o preview atualize dinamicamente
      setState(() {});
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
      initialDate: _validade ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _validade = picked);
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate() || _validade == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preencha todos os campos e a validade.')),
    );
    return;
  }

  final user = AuthService.instance.currentUser.value;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário não autenticado.')),
    );
    return;
  }

  setState(() => _saving = true);

  try {
    final novaDoacao = await MockService.addDoacaoMock(
      idUsuarioDoa: int.parse(user.id.toString()),
      nomeAlimento: _nomeCtrl.text.trim(),
      descricao: _descCtrl.text.trim(),
      validade: _validade!,
      quantidade: int.tryParse(_qtyCtrl.text) ?? 1,
      imageUrl: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
    );

    // Atualiza a lista global
    ref.read(foodListProvider.notifier).addOrUpdateDoacao(novaDoacao);

    if (mounted) {
      // Mostra snackbar verde de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Doação cadastrada com sucesso!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {}, // apenas fecha
          ),
        ),
      );

      Navigator.pop(context, 'created');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao cadastrar: $e')),
    );
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Doação'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome do alimento'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => v == null || v.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                validator: (v) => v == null || v.isEmpty ? 'Informe a quantidade' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
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
                        child: const Text('URL inválida', style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _validade == null
                          ? 'Validade não selecionada'
                          : 'Validade: ${_validade!.day}/${_validade!.month}/${_validade!.year}',
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Selecionar'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
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
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Cadastrar'),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
