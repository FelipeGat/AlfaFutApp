import '../../../core/network/api_client.dart';
import 'partida.dart';

class PartidaRepository {
  PartidaRepository(this._api);
  final ApiClient _api;

  Future<List<Partida>> listarPorPatota(int patotaId, {String filtro = 'proximas'}) async {
    final r = await _api.dio.get('/patotas/$patotaId/partidas', queryParameters: {
      'filtro': filtro,
    });
    return (r.data['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Partida.fromJson)
        .toList();
  }

  Future<Partida> obter(int partidaId) async {
    final r = await _api.dio.get('/partidas/$partidaId');
    return Partida.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<void> confirmar(int partidaId, {String? observacao}) async {
    await _api.dio.post('/partidas/$partidaId/confirmar', data: {
      if (observacao != null) 'observacao': observacao,
    });
  }

  Future<void> recusar(int partidaId) async {
    await _api.dio.post('/partidas/$partidaId/recusar');
  }

  Future<void> cancelarConfirmacao(int partidaId) async {
    await _api.dio.delete('/partidas/$partidaId/confirmacao');
  }
}
