class Patota {
  Patota({
    required this.id,
    required this.nome,
    this.cidade,
    this.descricao,
    required this.jogadoresPorTime,
    required this.quantidadeTimes,
    required this.publica,
    this.codigoConvite,
    this.totalMembros,
    this.brasao,
    this.responsavelId,
    this.criadorId,
  });

  factory Patota.fromJson(Map<String, dynamic> j) => Patota(
        id: j['id'] as int,
        nome: j['nome'] as String,
        cidade: j['cidade'] as String?,
        descricao: j['descricao'] as String?,
        jogadoresPorTime: j['jogadores_por_time'] as int? ?? 5,
        quantidadeTimes: j['quantidade_times'] as int? ?? 2,
        publica: j['publica'] as bool? ?? false,
        codigoConvite: j['codigo_convite'] as String?,
        totalMembros: j['total_membros'] as int?,
        brasao: j['brasao'] as String?,
        responsavelId: j['responsavel_id'] as int?,
        criadorId: j['criador_id'] as int?,
      );

  final int id;
  final String nome;
  final String? cidade;
  final String? descricao;
  final int jogadoresPorTime;
  final int quantidadeTimes;
  final bool publica;
  final String? codigoConvite;
  final int? totalMembros;
  final String? brasao;
  final int? responsavelId;
  final int? criadorId;

  int get vagasPorPartida => jogadoresPorTime * quantidadeTimes;
}
