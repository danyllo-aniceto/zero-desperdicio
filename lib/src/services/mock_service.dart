import 'package:zero_desperdicio/src/models/alimento_model.dart';
import 'package:zero_desperdicio/src/models/doacao_model.dart';
import 'package:zero_desperdicio/src/models/usuario_model.dart';

class MockService {
  static final List<Usuario> usuarios = [
    Usuario(id: 1, nomeUsuario: 'Danyllo', email: 'dany@teste.com', senha: '1234', tel: '11999999999'),
    Usuario(id: 2, nomeUsuario: 'Maria', email: 'maria@teste.com', senha: '1234', tel: '11988888888'),
  ];

  static final List<Alimento> alimentos = [
    Alimento(
      id: 1,
      nome: 'Arroz',
      descricao: 'Pacote de 5kg',
      validade: DateTime.now().add(const Duration(days: 60)),
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPuNceTyX5TOW-qAbYEX0g0o9eE5cVNwXUTg&s',
    ),
    Alimento(
      id: 2,
      nome: 'Feijão',
      descricao: 'Tipo carioca',
      validade: DateTime.now().add(const Duration(days: 45)),
      imageUrl: 'https://carrefourbrfood.vtexassets.com/arquivos/ids/193717793/feijao-carioca-tipo-1-kicaldo-1kg-2-unidades-1.jpg?v=638872297402300000',
    ),
  ];

  static final List<Doacao> doacoes = [
    Doacao(
      id: 1,
      idUsuarioRec: 0,
      idUsuarioDoa: 1, // doação do usuário com id 1 (Danyllo)
      alimento: alimentos[0],
      quantidade: 3,
      dataCadastro: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Disponível',
    ),
    Doacao(
      id: 2,
      idUsuarioRec: 0,
      idUsuarioDoa: 2, // doação da Maria
      alimento: alimentos[1],
      quantidade: 2,
      dataCadastro: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Disponível',
    ),
  ];
}
