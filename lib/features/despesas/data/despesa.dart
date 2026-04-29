class Despesa {
  Despesa({
    required this.id,
    required this.patotaId,
    this.partidaId,
    required this.descricao,
    required this.categoria,
    required this.valorTotal,
    required this.dataDespesa,
    required this.rateada,
    required this.status,
    required this.totalPago,
    required this.saldoAberto,
  });

  factory Despesa.fromJson(Map<String, dynamic> j) => Despesa(
        id: j['id'] as int,
        patotaId: j['patota_id'] as int,
        partidaId: j['partida_id'] as int?,
        descricao: j['descricao'] as String,
        categoria: j['categoria'] as String,
        valorTotal: (j['valor_total'] as num).toDouble(),
        dataDespesa: DateTime.parse(j['data_despesa'] as String),
        rateada: j['rateada'] as bool,
        status: j['status'] as String,
        totalPago: (j['total_pago'] as num?)?.toDouble() ?? 0,
        saldoAberto: (j['saldo_aberto'] as num?)?.toDouble() ?? 0,
      );

  final int id;
  final int patotaId;
  final int? partidaId;
  final String descricao;
  final String categoria;
  final double valorTotal;
  final DateTime dataDespesa;
  final bool rateada;
  final String status;
  final double totalPago;
  final double saldoAberto;
}
