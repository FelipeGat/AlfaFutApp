import '../../../core/network/api_client.dart';
import 'despesa.dart';

class DespesaRepository {
  DespesaRepository(this._api);
  final ApiClient _api;

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
