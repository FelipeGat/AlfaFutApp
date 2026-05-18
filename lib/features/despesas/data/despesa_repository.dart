import '../../../core/network/api_client.dart';
import 'despesa.dart';

class DespesaRepository {
  DespesaRepository(this._api);
  final ApiClient _api;

  Future<Despesa> criar(
    int patotaId, {
    required String descricao,
    required String categoria,
    required double valorTotal,
    required DateTime dataDespesa,
    int? partidaId,
    bool rateada = true,
  }) async {
    final r = await _api.dio.post('/patotas/$patotaId/despesas', data: {
      'descricao': descricao,
      'categoria': categoria,
      'valor_total': valorTotal,
      'data_despesa': dataDespesa.toIso8601String().substring(0, 10),
      if (partidaId != null) 'partida_id': partidaId,
      'rateada': rateada,
    });
    return Despesa.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<Despesa>> listarPorPatota(int patotaId) async {
    final r = await _api.dio.get('/patotas/$patotaId/despesas');
    return (r.data['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Despesa.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> obter(int despesaId) async {
    final r = await _api.dio.get('/despesas/$despesaId');
    return r.data as Map<String, dynamic>;
  }

  Future<void> quitarPagamento(
    int pagamentoId, {
    required double valorPago,
    required String formaPagamento,
  }) async {
    await _api.dio.post('/pagamentos/$pagamentoId/quitar', data: {
      'valor_pago': valorPago,
      'forma_pagamento': formaPagamento,
    });
  }
}
