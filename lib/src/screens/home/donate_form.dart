import 'package:flutter/material.dart';

class DonateFormScreen extends StatefulWidget {
  const DonateFormScreen({super.key});

  @override
  State<DonateFormScreen> createState() => _DonateFormScreenState();
}

class _DonateFormScreenState extends State<DonateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de alimento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Nome do alimento'), validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _qtyCtrl, decoration: const InputDecoration(labelText: 'Quantidade/Descrição'), validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Simular salvar e voltar
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doação cadastrada (simulada)')));
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
