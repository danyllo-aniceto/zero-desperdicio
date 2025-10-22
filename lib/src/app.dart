// lib/src/app.dart
import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/core/theme/app_theme.dart';
import 'package:zero_desperdicio/src/screens/auth/login_screen.dart';
import 'package:zero_desperdicio/src/screens/home/dashboard_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero Desperdício',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Mostra Login se não houver usuário; caso contrário, Dashboard.
      home: ValueListenableBuilder(
        valueListenable: AuthService.instance.currentUser,
        builder: (context, dynamic user, _) {
          if (user == null) {
            return const LoginScreen();
          } else {
            return const DashboardScreen();
          }
        },
      ),
    );
  }
}
