// lib/src/services/mock_service.dart
import 'package:zero_desperdicio/src/models/alimento_model.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';

class MockService {
  static final List<Usuario> usuarios = [
    Usuario(id: 1, nomeUsuario: 'Danyllo', email: 'dany@teste.com', senha: '1234', tel: '5511999999999'),
    Usuario(id: 2, nomeUsuario: 'Maria', email: 'maria@teste.com', senha: '1234', tel: '5511988888888'),
    Usuario(id: 3, nomeUsuario: 'ONG Verde', email: 'contato@ongverde.org', senha: '1234', tel: '5511977777777'),
  ];

  static final List<Alimento> alimentos = List.generate(20, (i) {
    final names = [
      'Arroz', 'Feijão', 'Macarrão', 'Açúcar', 'Farinha', 'Leite em pó', 'Óleo', 'Biscoito',
      'Azeite', 'Café', 'Aveia', 'Milho', 'Molho de tomate', 'Cereal', 'Ervilha',
      'Sardinha', 'Atum', 'Frutas sortidas', 'Legumes sortidos', 'Pães'
    ];
    final imgs = [
      'https://images.unsplash.com/photo-1604908177522-21f08a2b5b7f?auto=format&fit=crop&w=800&q=60',
      'https://images.unsplash.com/photo-1589307000046-7a4f5a9ce7d3?auto=format&fit=crop&w=800&q=60',
      'https://images.unsplash.com/photo-1564767609342-620cb19b2357?auto=format&fit=crop&w=800&q=60',
      'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=60',
      'https://images.unsplash.com/photo-1502741126161-b048400d3d1e?auto=format&fit=crop&w=800&q=60'
    ];
    final name = names[i % names.length] + (i >= names.length ? ' ${i ~/ names.length + 1}' : '');
    return Alimento(
      id: i + 1,
      nome: name,
      descricao: 'Pacote/quantidade para doação — item #${i + 1}',
      validade: DateTime.now().add(Duration(days: (10 + (i % 60)))),
      imageUrl: imgs[i % imgs.length],
    );
  });

  static final List<Doacao> doacoes = List.generate(60, (i) {
    final donorId = (i % 3) + 1; // 1,2,3 repetindo
    final alimento = alimentos[i % alimentos.length];
    return Doacao(
      id: i + 1,
      idUsuarioRec: 0,
      idUsuarioDoa: donorId,
      alimento: alimento,
      quantidade: (1 + (i % 5)),
      dataCadastro: DateTime.now().subtract(Duration(days: i % 30)),
      status: (i % 7 == 0) ? 'Concluída' : 'Disponível',
    );
  });

  /// Simula chamada paginada (backend). Ordena por dataCadastro desc antes de paginação.
  static Future<List<Doacao>> fetchDoacoesPaged({required int page, required int pageSize}) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final sorted = List<Doacao>.from(doacoes)
      ..sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));
    final start = (page - 1) * pageSize;
    if (start >= sorted.length) return [];
    final end = (start + pageSize) > sorted.length ? sorted.length : (start + pageSize);
    return sorted.sublist(start, end);
  }

  /// Retorna total de doações (simula endpoint que retorna totalCount)
  static Future<int> fetchDoacoesTotalCount() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return doacoes.length;
  }

  /// Remove doação do mock (simula delete no backend)
  static Future<void> removeDoacaoMock(int id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    doacoes.removeWhere((d) => d.id == id);
  }

  /// Atualiza (substitui) uma doação no mock (simula PUT)
  static Future<void> updateDoacaoMock(Doacao updated) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = doacoes.indexWhere((d) => d.id == updated.id);
    if (idx != -1) doacoes[idx] = updated;
  }
}
