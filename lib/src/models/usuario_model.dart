enum UsuarioTipo { normal, ong }

class Usuario {
  final int id;
  final String nomeUsuario;
  final String email;
  final String senha;
  final String tel;
  final String tipo; // "normal" ou "ong"
  final String status; // "ativo", "pendente", "bloqueado"
  final bool isAdmin;

  const Usuario({
    required this.id,
    required this.nomeUsuario,
    required this.email,
    required this.senha,
    required this.tel,
    this.tipo = 'normal',
    this.status = 'ativo',
    this.isAdmin = false,
  });

  Usuario copyWith({
    int? id,
    String? nomeUsuario,
    String? email,
    String? senha,
    String? tel,
    String? tipo,
    String? status,
    bool? isAdmin,
  }) {
    return Usuario(
      id: id ?? this.id,
      nomeUsuario: nomeUsuario ?? this.nomeUsuario,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      tel: tel ?? this.tel,
      tipo: tipo ?? this.tipo,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        nomeUsuario: json['nome_usuario'] ?? json['nomeUsuario'] ?? '',
        email: json['email'],
        senha: json['senha'],
        tel: json['tel'] ?? '',
        tipo: (json['tipo'] as String?) ?? 'normal',
        status: json['status'] ?? 'ativo',
        isAdmin: json['isAdmin'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome_usuario': nomeUsuario,
        'email': email,
        'senha': senha,
        'tel': tel,
        'tipo': tipo,
        'status': status,
        'isAdmin': isAdmin,
      };
}
