import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/core/theme/app_theme.dart';
import 'package:zero_desperdicio/src/screens/loginAndRegister/login_screen.dart';
import 'package:zero_desperdicio/src/screens/home/dashboard_screen.dart';
import 'package:zero_desperdicio/src/screens/admin/admin_dashboard_screen.dart';
import 'package:zero_desperdicio/src/screens/status/waiting_approval_screen.dart';
import 'package:zero_desperdicio/src/screens/status/blocked_user_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'package:zero_desperdicio/src/models/user.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    MockRepository.instance.init();
  }

  Future<String?> _getStatus(String id) async {
    await MockRepository.instance.init();
    final user = MockRepository.instance.allUsuarios().firstWhere(
          (u) => u.id.toString() == id,
          orElse: () => const Usuario(
            id: 0,
            nomeUsuario: '',
            email: '',
            senha: '',
            tel: '',
          ),
        );
    return user.status;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero Desperdício',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ValueListenableBuilder<User?>(
        valueListenable: AuthService.instance.currentUser,
        builder: (context, user, _) {
          if (user == null) {
            return const LoginScreen();
          } else if (user.email == 'danyllo@admin.com' ||
              user.name.toLowerCase() == 'danyllo') {
            return const AdminDashboardScreen();
          } else {
            // Checa status da conta
            return FutureBuilder<String?>(
              future: _getStatus(user.id),
              builder: (context, snapshot) {
                final status = snapshot.data ?? 'ativo';
                if (status == 'pendente') {
                  return const WaitingApprovalScreen();
                } else if (status == 'bloqueado') {
                  return const BlockedUserScreen();
                } else {
                  return const DashboardScreen();
                }
              },
            );
          }
        },
      ),
    );
  }
}
