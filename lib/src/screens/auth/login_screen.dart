import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/core/theme/app_theme.dart';
import 'package:zero_desperdicio/src/models/user.dart';
import 'package:zero_desperdicio/src/screens/home/dashboard_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserType _selectedType = UserType.normal;
  bool _loading = false;

  void _tryLogin() async {
    setState(() => _loading = true);
    final ok = await AuthService.instance.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      expectedType: _selectedType,
    );
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciais inválidas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.volunteer_activism, size: 60, color: Colors.green),
              ),

              // CARD DE LOGIN
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _tryLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Entrar', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Cadastrar-se'),
                      ),
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
