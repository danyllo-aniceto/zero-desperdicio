import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/models/user.dart';
import 'package:zero_desperdicio/src/screens/admin/admin_dashboard_screen.dart';
import 'package:zero_desperdicio/src/screens/home/dashboard_screen.dart';
import 'package:zero_desperdicio/src/screens/loginAndRegister/register_screen.dart';
import 'package:zero_desperdicio/src/screens/status/blocked_user_screen.dart';
import 'package:zero_desperdicio/src/screens/status/waiting_approval_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';

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
    try {
      final result = await AuthService.instance.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        expectedType: _selectedType,
      );

      if (!mounted) return;

      switch (result) {
        case LoginState.success:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
          break;
        case LoginState.admin:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
          break;
        case LoginState.pending:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
          );
          break;
        case LoginState.blocked:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BlockedUserScreen()),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciais inválidas')),
          );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        "Bem-vindo ao Zero Desperdício!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 26, 49, 27)),
                      ),
                      const SizedBox(height: 16),
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
                              : const Text('Entrar', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                          if (result is Map && result['email'] != null) {
                            _emailCtrl.text = result['email'] as String;
                            if (result['type'] is UserType) {
                              _selectedType = result['type'] as UserType;
                            }
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Conta criada — faça login.')),
                            );
                          }
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
