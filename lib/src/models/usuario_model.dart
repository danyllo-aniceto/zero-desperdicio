// lib/src/models/usuario_model.dart
enum UsuarioTipo { normal, ong }

class Usuario {
  final int id;
  final String nomeUsuario;
  final String email;
  final String senha;
  final String tel;
  final String tipo; // "normal" ou "ong"

  const Usuario({
    required this.id,
    required this.nomeUsuario,
    required this.email,
    required this.senha,
    required this.tel,
    this.tipo = 'normal',
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nomeUsuario: json['nome_usuario'] ?? json['nomeUsuario'] ?? '',
        email: json['email'],
        senha: json['senha'],
        tel: json['tel'] ?? '',
        tipo: (json['tipo'] as String?) ?? 'normal',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome_usuario': nomeUsuario,
        'email': email,
        'senha': senha,
        'tel': tel,
        'tipo': tipo,
      };
}
