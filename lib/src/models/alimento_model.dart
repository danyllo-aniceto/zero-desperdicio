class Alimento {
  final int id;
  final String nome;
  final String descricao;
  final DateTime validade;
  final String? imageUrl;

  const Alimento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.validade,
    this.imageUrl,
  });

  factory Alimento.fromJson(Map<String, dynamic> json) => Alimento(
        id: json['id'],
        nome: json['nome'],
        descricao: json['descricao'],
        validade: DateTime.parse(json['validade']),
        imageUrl: json['imageUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'validade': validade.toIso8601String(),
        'imageUrl': imageUrl,
      };

  /// Permite criar uma cópia alterando apenas campos específicos
  Alimento copyWith({
    int? id,
    String? nome,
    String? descricao,
    DateTime? validade,
    String? imageUrl,
  }) {
    return Alimento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      validade: validade ?? this.validade,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
