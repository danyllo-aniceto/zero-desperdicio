// lib/src/screens/status/blocked_user_screen.dart
import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/screens/loginAndRegister/login_screen.dart';

class BlockedUserScreen extends StatelessWidget {
  const BlockedUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Sua conta foi bloqueada.\nEntre em contato com o administrador:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text('📞 (11) 99999-9999\n✉️ admin@zerodesperdicio.com',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false);
                },
                child: const Text('Voltar ao login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
