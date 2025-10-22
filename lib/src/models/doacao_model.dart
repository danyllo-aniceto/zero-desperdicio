import 'alimento_model.dart';

class Doacao {
  final int id;
  final int idUsuarioRec;
  final int idUsuarioDoa;
  final Alimento alimento;
  final int quantidade;
  final DateTime dataCadastro;
  final String status;

  const Doacao({
    required this.id,
    required this.idUsuarioRec,
    required this.idUsuarioDoa,
    required this.alimento,
    required this.quantidade,
    required this.dataCadastro,
    required this.status,
  });

  factory Doacao.fromJson(Map<String, dynamic> json) => Doacao(
        id: json['id'],
        idUsuarioRec: json['id_usuarioRec'],
        idUsuarioDoa: json['id_usuarioDoa'],
        alimento: Alimento.fromJson(json['alimento']),
        quantidade: json['quantidade'],
        dataCadastro: DateTime.parse(json['data_cadastro']),
        status: json['status'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'id_usuarioRec': idUsuarioRec,
        'id_usuarioDoa': idUsuarioDoa,
        'alimento': alimento.toJson(),
        'quantidade': quantidade,
        'data_cadastro': dataCadastro.toIso8601String(),
        'status': status,
      };
}
