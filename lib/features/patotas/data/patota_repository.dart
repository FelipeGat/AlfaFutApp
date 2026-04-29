import '../../../core/network/api_client.dart';
import 'patota.dart';

class PatotaRepository {
  PatotaRepository(this._api);
  final ApiClient _api;

  Future<List<Patota>> listar() async {
    final r = await _api.dio.get('/patotas');
    final dados = (r.data['data'] as List).cast<Map<String, dynamic>>();
    return dados.map(Patota.fromJson).toList();
  }

  Future<Patota> criar({
    required String nome,
    String? descricao,
    String? cidade,
    String? estado,
    int jogadoresPorTime = 5,
    int quantidadeTimes = 2,
    double valorMensalidade = 0,
    bool publica = false,
    String? brasao,
  }) async {
    final r = await _api.dio.post('/patotas', data: {
      'nome': nome,
      'descricao': descricao,
      'cidade': cidade,
      'estado': estado,
      'jogadores_por_time': jogadoresPorTime,
      'quantidade_times': quantidadeTimes,
      'valor_mensalidade': valorMensalidade,
      'publica': publica,
      if (brasao != null) 'brasao': brasao,
    });
    return Patota.fromJson(r.data as Map<String, dynamic>);
  }

  Future<Patota> entrarPorCodigo(String codigo) async {
    final r = await _api.dio.post('/patotas/entrar', data: {
      'codigo_convite': codigo,
    });
    return Patota.fromJson(r.data['patota'] as Map<String, dynamic>);
  }

  Future<Patota> obter(int id) async {
    final r = await _api.dio.get('/patotas/$id');
    return Patota.fromJson(r.data['data'] as Map<String, dynamic>);
  }
}
