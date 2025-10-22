class Ong {
  final int id;
  final String nomeUsuario;
  final String email;
  final String senha;
  final bool verificacao;
  final String tel;

  const Ong({
    required this.id,
    required this.nomeUsuario,
    required this.email,
    required this.senha,
    required this.verificacao,
    required this.tel,
  });

  factory Ong.fromJson(Map<String, dynamic> json) => Ong(
        id: json['id'],
        nomeUsuario: json['nome_usuario'],
        email: json['email'],
        senha: json['senha'],
        verificacao: json['verificacao'] ?? false,
        tel: json['tel'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome_usuario': nomeUsuario,
        'email': email,
        'senha': senha,
        'verificacao': verificacao,
        'tel': tel,
      };
}
