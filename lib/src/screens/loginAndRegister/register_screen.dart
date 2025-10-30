// lib/src/screens/loginAndRegister/register_screen.dart
import 'package:flutter/material.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha nome, email e senha (mínimo 4 caracteres).')));
      return;
    }

    setState(() => _loading = true);
    try {
      await MockRepository.instance.init();

      final exists = MockRepository.instance.allUsuarios().any((u) => u.email.toLowerCase() == email.toLowerCase());
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Já existe uma conta com este email.')));
        return;
      }

      final tipo = _selectedType == UserType.ong ? 'ong' : 'normal';
      final created = await MockRepository.instance.addUsuario(Usuario(id: 0, nomeUsuario: name, email: email, senha: pass, tel: tel, tipo: tipo));

      // tenta auto-login com o tipo selecionado
      final logged = await AuthService.instance.login(email: email, password: pass, expectedType: _selectedType);

      if (logged) {
        // navega direto para dashboard
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const DashboardScreen()), (_) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta criada. Faça login manualmente.')));
        if (mounted) Navigator.pop(context, {'email': email, 'type': _selectedType});
      }
    } catch (e) {
      // ignore: avoid_print
      print('Register error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar usuário: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(title: const Text('Cadastrar conta'), backgroundColor: Colors.green),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.person_outline))),
                  const SizedBox(height: 12),
                  TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 12),
                  TextField(controller: _telCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone (opcional)', prefixIcon: Icon(Icons.phone))),
                  const SizedBox(height: 12),
                  TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Senha (mín. 4 caracteres)', prefixIcon: Icon(Icons.lock_outline))),
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Já tem uma conta? Entrar')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
