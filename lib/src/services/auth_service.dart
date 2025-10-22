import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  // Usuários hardcoded para testes
  final List<User> _users = [
    User(
      id: '1',
      name: 'Usuário Teste',
      email: 'user@user.com',
      password: '1234',
      type: UserType.normal,
    ),
    User(
      id: '2',
      name: 'ONG Teste',
      email: 'ong@ong.com',
      password: '1234',
      type: UserType.ong,
    ),
  ];

  /// Tenta logar. Retorna true se OK.
  Future<bool> login({
    required String email,
    required String password,
    required UserType expectedType,
  }) async {
    // simula chamada assíncrona
    await Future.delayed(const Duration(milliseconds: 400));
    final match = _users.firstWhere(
      (u) =>
          u.email.toLowerCase() == email.toLowerCase() &&
          u.password == password &&
          u.type == expectedType,
      orElse: () => null as User,
    );
    if (match != null) {
      currentUser.value = match;
      return true;
    } else {
      return false;
    }
  }

  void logout() {
    currentUser.value = null;
  }
}
