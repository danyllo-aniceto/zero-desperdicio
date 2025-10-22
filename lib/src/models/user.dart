enum UserType { normal, ong }

class User {
  final String id;
  final String name;
  final String email;
  final String password; // só para demo; nunca faça isso em produção
  final UserType type;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.type,
  });
}
