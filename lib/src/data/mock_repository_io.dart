// lib/src/data/mock_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';
import 'package:zero_desperdicio/src/models/alimento_model.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';

class MockRepository {
  MockRepository._internal();
  static final MockRepository instance = MockRepository._internal();

  late final File _file;
  bool _initialized = false;

  final List<Usuario> usuarios = [];
  final List<Alimento> alimentos = [];
  final List<Doacao> doacoes = [];

  static const _fileName = 'mock_data.json';

  Future<void> init({bool forceReset = false}) async {
    if (_initialized && !forceReset) return;

    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/$_fileName');

    if (await _file.exists() && !forceReset) {
      try {
        final s = await _file.readAsString();
        final Map<String, dynamic> json = jsonDecode(s);

        usuarios.clear();
        alimentos.clear();
        doacoes.clear();

        if (json['usuarios'] is List) {
          for (final e in (json['usuarios'] as List)) {
            usuarios.add(Usuario.fromJson(Map<String, dynamic>.from(e)));
          }
        }

        if (json['alimentos'] is List) {
          for (final e in (json['alimentos'] as List)) {
            alimentos.add(Alimento.fromJson(Map<String, dynamic>.from(e)));
          }
        }

        if (json['doacoes'] is List) {
          for (final e in (json['doacoes'] as List)) {
            doacoes.add(Doacao.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      } catch (err) {
        await _seedAndSave();
      }
    } else {
      await _seedAndSave();
    }

    _initialized = true;
  }

  Future<void> _seedAndSave() async {
    usuarios.clear();
    alimentos.clear();
    doacoes.clear();

    usuarios.addAll([
      Usuario(id: 1, nomeUsuario: 'Danyllo', email: 'dany@teste.com', senha: '1234', tel: '5511999999999', tipo: 'normal'),
      Usuario(id: 2, nomeUsuario: 'Maria', email: 'maria@teste.com', senha: '1234', tel: '5511988888888', tipo: 'normal'),
      Usuario(id: 3, nomeUsuario: 'ONG Verde', email: 'contato@ongverde.org', senha: '1234', tel: '5511977777777', tipo: 'ong'),
    ]);

    alimentos.addAll([
      Alimento(
        id: 1,
        nome: 'Arroz',
        descricao: 'Pacote de 5kg',
        validade: DateTime.now().add(const Duration(days: 60)),
        imageUrl: 'https://images.unsplash.com/photo-1604908177522-21f08a2b5b7f?auto=format&fit=crop&w=800&q=60',
      ),
      Alimento(
        id: 2,
        nome: 'Feijão',
        descricao: 'Tipo carioca',
        validade: DateTime.now().add(const Duration(days: 45)),
        imageUrl: 'https://images.unsplash.com/photo-1589307000046-7a4f5a9ce7d3?auto=format&fit=crop&w=800&q=60',
      ),
    ]);

    doacoes.addAll([
      Doacao(id: 1, idUsuarioRec: 0, idUsuarioDoa: 1, alimento: alimentos[0], quantidade: 3, dataCadastro: DateTime.now().subtract(const Duration(days: 1)), status: 'Disponível'),
      Doacao(id: 2, idUsuarioRec: 1, idUsuarioDoa: 2, alimento: alimentos[1], quantidade: 2, dataCadastro: DateTime.now().subtract(const Duration(days: 3)), status: 'Concluída'), // exemplo: recebida por Danyllo (idUsuarioRec = 1)
    ]);

    await _saveToDisk();
  }

  Future<void> _saveToDisk() async {
    final Map<String, dynamic> out = {
      'usuarios': usuarios.map((u) => u.toJson()).toList(),
      'alimentos': alimentos.map((a) => a.toJson()).toList(),
      'doacoes': doacoes.map((d) => d.toJson()).toList(),
    };
    final encoded = const JsonEncoder.withIndent('  ').convert(out);
    await _file.writeAsString(encoded);
  }

  // Usuários
  Future<Usuario?> findUserByEmailAndPassword(String email, String password) async {
    await init();
    try {
      return usuarios.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase() && u.senha == password);
    } catch (_) {
      return null;
    }
  }

  Future<Usuario> addUsuario(Usuario u) async {
    await init();
    final newId = (usuarios.isEmpty) ? 1 : (usuarios.map((x) => x.id).reduce((a, b) => a > b ? a : b) + 1);
    final novo = Usuario(
      id: newId,
      nomeUsuario: u.nomeUsuario,
      email: u.email,
      senha: u.senha,
      tel: u.tel,
      tipo: u.tipo,
    );
    usuarios.add(novo);
    await _saveToDisk();
    return novo;
  }

  // Alimentos & Doações
  Future<List<Doacao>> fetchDoacoesPaged({required int page, required int pageSize}) async {
    await init();
    final sorted = List<Doacao>.from(doacoes)..sort((a, b) => b.dataCadastro.compareTo(a.dataCadastro));
    final start = (page - 1) * pageSize;
    if (start >= sorted.length) return [];
    final end = (start + pageSize) > sorted.length ? sorted.length : (start + pageSize);
    await Future.delayed(const Duration(milliseconds: 350));
    return sorted.sublist(start, end);
  }

  Future<int> fetchDoacoesTotalCount() async {
    await init();
    await Future.delayed(const Duration(milliseconds: 100));
    return doacoes.length;
  }

  Future<Doacao> addDoacao({
    required int idUsuarioDoa,
    required String nomeAlimento,
    required String descricao,
    required DateTime validade,
    required int quantidade,
    String? imageUrl,
    String status = 'Disponível',
  }) async {
    await init();
    final newAlimentoId = (alimentos.isEmpty) ? 1 : (alimentos.map((a) => a.id).reduce((a, b) => a > b ? a : b) + 1);
    final novoAlimento = Alimento(id: newAlimentoId, nome: nomeAlimento, descricao: descricao, validade: validade, imageUrl: imageUrl);
    alimentos.add(novoAlimento);
    final newDoacaoId = (doacoes.isEmpty) ? 1 : (doacoes.map((d) => d.id).reduce((a, b) => a > b ? a : b) + 1);
    final novaDoacao = Doacao(id: newDoacaoId, idUsuarioRec: 0, idUsuarioDoa: idUsuarioDoa, alimento: novoAlimento, quantidade: quantidade, dataCadastro: DateTime.now(), status: status);
    doacoes.add(novaDoacao);
    await _saveToDisk();
    return novaDoacao;
  }

  Future<void> updateDoacao(Doacao updated) async {
    await init();
    final idx = doacoes.indexWhere((d) => d.id == updated.id);
    if (idx != -1) {
      final alimentoIdx = alimentos.indexWhere((a) => a.id == updated.alimento.id);
      if (alimentoIdx != -1) {
        alimentos[alimentoIdx] = updated.alimento;
      } else {
        alimentos.add(updated.alimento);
      }
      doacoes[idx] = updated;
      await _saveToDisk();
    } else {
      throw Exception('Doação não encontrada');
    }
  }

  Future<void> removeDoacao(int id) async {
    await init();
    doacoes.removeWhere((d) => d.id == id);
    final referencedAlimentoIds = doacoes.map((d) => d.alimento.id).toSet();
    alimentos.removeWhere((a) => !referencedAlimentoIds.contains(a.id));
    await _saveToDisk();
  }

  List<Doacao> allDoacoes() => List<Doacao>.from(doacoes);
  List<Usuario> allUsuarios() => List<Usuario>.from(usuarios);
  List<Alimento> allAlimentos() => List<Alimento>.from(alimentos);
}
