// lib/src/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/user.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);

  /// Tenta logar usando o MockRepository — trata exceções e retorna false em erro.
  Future<bool> login({
    required String email,
    required String password,
    required UserType expectedType,
  }) async {
    try {
      await MockRepository.instance.init();

      final Usuario? usuario = await MockRepository.instance.findUserByEmailAndPassword(email, password);
      if (usuario == null) return false;

      // usar usuario.tipo se disponível ('normal' / 'ong')
      final String tipoStr = usuario.tipo.toLowerCase();
      final userType = (tipoStr == 'ong') ? UserType.ong : UserType.normal;

      // se expectedType não bater, falha
      if (userType != expectedType) return false;

      final user = User(
        id: usuario.id.toString(),
        name: usuario.nomeUsuario,
        email: usuario.email,
        password: usuario.senha,
        type: userType,
      );

      currentUser.value = user;
      return true;
    } catch (e, st) {
      // ignore: avoid_print
      print('AuthService.login error: $e\n$st');
      return false;
    }
  }

  void logout() {
    currentUser.value = null;
  }
}
