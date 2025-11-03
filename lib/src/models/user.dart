// lib/src/models/user.dart
enum UserType { normal, ong }

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserType type;
  final String phone; // <-- novo campo opcional

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.type,
    this.phone = '',
  });

  /// Cria uma cópia com campos alterados (usado no perfil)
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserType? type,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      type: type ?? this.type,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'type': type.name,
        'phone': phone,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      type: (json['type'] == 'ong') ? UserType.ong : UserType.normal,
      phone: json['phone'] ?? '',
    );
  }
}
