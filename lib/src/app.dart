import 'package:flutter/material.dart';
import 'package:zero_desperdicio/src/core/theme/app_theme.dart';
import 'package:zero_desperdicio/src/screens/loginAndRegister/login_screen.dart';
import 'package:zero_desperdicio/src/screens/home/dashboard_screen.dart';
import 'package:zero_desperdicio/src/services/auth_service.dart';
import 'package:zero_desperdicio/src/models/user.dart';

class App extends StatelessWidget {
  const App({super.key});

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
          } else {
            return const DashboardScreen();
          }
        },
      ),
    );
  }
}
