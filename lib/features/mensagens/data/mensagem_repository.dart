import '../../../core/network/api_client.dart';
import 'mensagem.dart';

class MensagemRepository {
  MensagemRepository(this._api);
  final ApiClient _api;

  Future<List<Mensagem>> listar(int patotaId, {int? partidaId}) async {
    final r = await _api.dio.get('/patotas/$patotaId/mensagens', queryParameters: {
      if (partidaId != null) 'partida_id': partidaId,
    });
    return (r.data['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Mensagem.fromJson)
        .toList();
  }

  Future<Mensagem> publicar(
    int patotaId, {
    required String conteudo,
    int? partidaId,
    String tipo = 'texto',
    bool fixada = false,
  }) async {
    final r = await _api.dio.post('/patotas/$patotaId/mensagens', data: {
      'conteudo': conteudo,
      if (partidaId != null) 'partida_id': partidaId,
      'tipo': tipo,
      'fixada': fixada,
    });
    return Mensagem.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> remover(int mensagemId) async {
    await _api.dio.delete('/mensagens/$mensagemId');
  }
}
