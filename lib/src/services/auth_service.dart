import 'package:flutter/foundation.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/user.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';

enum LoginState { success, pending, blocked, admin, error }

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  Future<LoginState> login({
    required String email,
    required String password,
    required UserType expectedType,
  }) async {
    try {
      await MockRepository.instance.init();

      final usuario = await MockRepository.instance
          .findUserByEmailAndPassword(email, password);

      if (usuario == null) return LoginState.error;

      // --- ADMIN: usa a flag isAdmin no modelo Usuario ---
      if (usuario.isAdmin == true) {
        final user = User(
          id: usuario.id.toString(),
          name: usuario.nomeUsuario,
          email: usuario.email,
          password: usuario.senha,
          type: UserType.normal, // admin treated as 'normal' in User model
        );
        currentUser.value = user;
        return LoginState.admin;
      }

      // --- ONG pendente ---
      if (usuario.tipo == 'ong' && usuario.status == 'pendente') {
        return LoginState.pending;
      }

      // --- Usuário bloqueado ---
      if (usuario.status == 'bloqueado') {
        return LoginState.blocked;
      }

      // --- Usuário comum ou ONG aprovada ---
      final tipoStr = usuario.tipo.toLowerCase();
      final userType = (tipoStr == 'ong') ? UserType.ong : UserType.normal;

      final user = User(
        id: usuario.id.toString(),
        name: usuario.nomeUsuario,
        email: usuario.email,
        password: usuario.senha,
        type: userType,
      );

      currentUser.value = user;
      return LoginState.success;
    } catch (e, st) {
      print('AuthService.login error: $e\n$st');
      return LoginState.error;
    }
  }

  void logout() {
    currentUser.value = null;
  }
}
