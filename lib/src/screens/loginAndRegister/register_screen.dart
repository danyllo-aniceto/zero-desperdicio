import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'package:zero_desperdicio/src/models/user.dart';
import 'package:zero_desperdicio/src/screens/home/dashboard_screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: { "#": RegExp(r'[0-9]') },
  );

  UserType _selectedType = UserType.normal;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final tel = _telCtrl.text.trim();
    final pass = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, email e senha válidos.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await MockRepository.instance.init();

      final exists = MockRepository.instance
          .allUsuarios()
          .any((u) => u.email.toLowerCase() == email.toLowerCase());
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Já existe uma conta com este email.')),
        );
        return;
      }

      final tipo = _selectedType == UserType.ong ? 'ong' : 'normal';
      await MockRepository.instance.addUsuario(
        Usuario(
          id: 0,
          nomeUsuario: name,
          email: email,
          senha: pass,
          tel: tel,
          tipo: tipo,
          status: tipo == 'ong' ? 'pendente' : 'ativo',
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tipo == 'ong'
              ? 'Conta criada! Aguarde aprovação do administrador.'
              : 'Conta criada com sucesso!'),
        ),
      );
      Navigator.pop(context, {'email': email, 'type': _selectedType});
    } catch (e) {
      print('Erro ao registrar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar:
          AppBar(title: const Text('Cadastrar conta'), backgroundColor: Colors.green),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // LOGO
              Container(
                width: 620,
                height: 120,
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Nome completo',
                              prefixIcon: Icon(Icons.person_outline))),
                      const SizedBox(height: 12),
                      TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _telCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [phoneMask],
                        decoration: const InputDecoration(
                          labelText: 'Telefone (opcional)',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: 'Senha (mín. 4 caracteres)',
                              prefixIcon: Icon(Icons.lock_outline))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<UserType>(
                              value: UserType.normal,
                              groupValue: _selectedType,
                              onChanged: (v) => setState(() => _selectedType = v!),
                              title: const Text('Usuário'),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<UserType>(
                              value: UserType.ong,
                              groupValue: _selectedType,
                              onChanged: (v) => setState(() => _selectedType = v!),
                              title: const Text('ONG'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Cadastrar',
                                  style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Já tem uma conta? Entrar')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
