// lib/src/services/mock_service.dart
import 'package:zero_desperdicio/src/data/mock_repository.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';

class MockService {
  static Future<List<Doacao>> fetchDoacoesPaged({required int page, required int pageSize}) =>
      MockRepository.instance.fetchDoacoesPaged(page: page, pageSize: pageSize);

  static Future<int> fetchDoacoesTotalCount() => MockRepository.instance.fetchDoacoesTotalCount();

  static Future<void> removeDoacaoMock(int id) => MockRepository.instance.removeDoacao(id);

  static Future<void> updateDoacaoMock(Doacao d) => MockRepository.instance.updateDoacao(d);

  static Future<Doacao> addDoacaoMock({
    required int idUsuarioDoa,
    required String nomeAlimento,
    required String descricao,
    required DateTime validade,
    required int quantidade,
    String? imageUrl,
    String status = 'Disponível',
  }) =>
      MockRepository.instance.addDoacao(
        idUsuarioDoa: idUsuarioDoa,
        nomeAlimento: nomeAlimento,
        descricao: descricao,
        validade: validade,
        quantidade: quantidade,
        imageUrl: imageUrl,
        status: status,
      );
}
