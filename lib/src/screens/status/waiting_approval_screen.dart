// lib/src/screens/status/waiting_approval_screen.dart
import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/screens/loginAndRegister/login_screen.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Sua conta está aguardando aprovação do administrador.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
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
