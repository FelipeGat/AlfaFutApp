import '../../../core/network/api_client.dart';
import '../../auth/data/usuario.dart';
import '../../partidas/data/partida.dart';
import '../../patotas/data/patota.dart';

class ResumoAdmin {
  ResumoAdmin({
    required this.totalUsuarios,
    required this.totalAdmins,
    required this.totalPatotas,
    required this.totalPartidas,
    required this.partidasAgendadas,
    required this.partidasEmAndamento,
    required this.partidasFinalizadas,
    required this.totalDespesas,
    required this.despesasAbertas,
    required this.valorTotalDespesas,
  });

  factory ResumoAdmin.fromJson(Map<String, dynamic> j) => ResumoAdmin(
        totalUsuarios: (j['total_usuarios'] as int?) ?? 0,
        totalAdmins: (j['total_admins'] as int?) ?? 0,
        totalPatotas: (j['total_patotas'] as int?) ?? 0,
        totalPartidas: (j['total_partidas'] as int?) ?? 0,
        partidasAgendadas: (j['partidas_agendadas'] as int?) ?? 0,
        partidasEmAndamento: (j['partidas_em_andamento'] as int?) ?? 0,
        partidasFinalizadas: (j['partidas_finalizadas'] as int?) ?? 0,
        totalDespesas: (j['total_despesas'] as int?) ?? 0,
        despesasAbertas: (j['despesas_abertas'] as int?) ?? 0,
        valorTotalDespesas: (j['valor_total_despesas'] as num?)?.toDouble() ?? 0,
      );

  final int totalUsuarios;
  final int totalAdmins;
  final int totalPatotas;
  final int totalPartidas;
  final int partidasAgendadas;
  final int partidasEmAndamento;
  final int partidasFinalizadas;
  final int totalDespesas;
  final int despesasAbertas;
  final double valorTotalDespesas;
}

class AdminRepository {
  AdminRepository(this._api);
  final ApiClient _api;

  Future<ResumoAdmin> resumo() async {
    final r = await _api.dio.get('/admin/resumo');
    return ResumoAdmin.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<List<Usuario>> usuarios() async {
    final r = await _api.dio.get('/admin/usuarios');
    return (r.data['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Usuario.fromJson)
        .toList();
  }

  Future<List<Patota>> patotas() async {
    final r = await _api.dio.get('/admin/patotas');
    return (r.data['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Patota.fromJson)
        .toList();
  }

  Future<List<Partida>> partidasAtivas() async {
    final r = await _api.dio.get('/admin/partidas-ativas');
    return (r.data['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Partida.fromJson)
        .toList();
  }

  Future<List<Partida>> todasPartidas() async {
    final r = await _api.dio.get('/admin/partidas');
    return (r.data['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(Partida.fromJson)
        .toList();
  }
}
