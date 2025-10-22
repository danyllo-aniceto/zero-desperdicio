class Alimento {
  final int id;
  final String nome;
  final String descricao;
  final DateTime validade;
  final String? imageUrl; // novo

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
}
