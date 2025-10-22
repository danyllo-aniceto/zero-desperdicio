class Usuario {
  final int id;
  final String nomeUsuario;
  final String email;
  final String senha;
  final String tel;

  const Usuario({
    required this.id,
    required this.nomeUsuario,
    required this.email,
    required this.senha,
    required this.tel,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nomeUsuario: json['nome_usuario'],
        email: json['email'],
        senha: json['senha'],
        tel: json['tel'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome_usuario': nomeUsuario,
        'email': email,
        'senha': senha,
        'tel': tel,
      };
}
