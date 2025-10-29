import 'alimento_model.dart';

class Doacao {
  final int id;
  final int idUsuarioDoa;
  final int idUsuarioRec;
  final Alimento alimento;
  final int quantidade;
  final DateTime dataCadastro;
  final String status;

  const Doacao({
    required this.id,
    required this.idUsuarioDoa,
    required this.idUsuarioRec,
    required this.alimento,
    required this.quantidade,
    required this.dataCadastro,
    required this.status,
  });

  factory Doacao.fromJson(Map<String, dynamic> json) => Doacao(
        id: json['id'],
        idUsuarioDoa: json['idUsuarioDoa'],
        idUsuarioRec: json['idUsuarioRec'],
        alimento: Alimento.fromJson(json['alimento']),
        quantidade: json['quantidade'],
        dataCadastro: DateTime.parse(json['dataCadastro']),
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'idUsuarioDoa': idUsuarioDoa,
        'idUsuarioRec': idUsuarioRec,
        'alimento': alimento.toJson(),
        'quantidade': quantidade,
        'dataCadastro': dataCadastro.toIso8601String(),
        'status': status,
      };

  /// Método copyWith — permite alterar campos específicos
  Doacao copyWith({
    int? id,
    int? idUsuarioDoa,
    int? idUsuarioRec,
    Alimento? alimento,
    int? quantidade,
    DateTime? dataCadastro,
    String? status,
  }) {
    return Doacao(
      id: id ?? this.id,
      idUsuarioDoa: idUsuarioDoa ?? this.idUsuarioDoa,
      idUsuarioRec: idUsuarioRec ?? this.idUsuarioRec,
      alimento: alimento ?? this.alimento,
      quantidade: quantidade ?? this.quantidade,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      status: status ?? this.status,
    );
  }
}
