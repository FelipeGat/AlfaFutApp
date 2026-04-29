class Partida {
  Partida({
    required this.id,
    required this.patotaId,
    required this.titulo,
    this.descricao,
    required this.dataHora,
    required this.duracaoMinutos,
    required this.vagasTotal,
    required this.vagasDisponiveis,
    required this.cheia,
    required this.valorIndividual,
    required this.status,
    this.localNome,
    this.localEndereco,
    this.localAcessivel,
    this.minhaConfirmacao,
  });

  factory Partida.fromJson(Map<String, dynamic> j) {
    final local = j['local'] as Map<String, dynamic>?;
    return Partida(
      id: j['id'] as int,
      patotaId: j['patota_id'] as int,
      titulo: j['titulo'] as String,
      descricao: j['descricao'] as String?,
      dataHora: DateTime.parse(j['data_hora'] as String),
      duracaoMinutos: j['duracao_minutos'] as int? ?? 90,
      vagasTotal: j['vagas_total'] as int,
      vagasDisponiveis: j['vagas_disponiveis'] as int? ?? 0,
      cheia: j['cheia'] as bool? ?? false,
      valorIndividual: (j['valor_individual'] as num?)?.toDouble() ?? 0,
      status: j['status'] as String,
      localNome: local?['nome'] as String?,
      localEndereco: local?['endereco'] as String?,
      localAcessivel: local?['acessivel_cadeirante'] as bool?,
      minhaConfirmacao: j['minha_confirmacao'] as Map<String, dynamic>?,
    );
  }

  final int id;
  final int patotaId;
  final String titulo;
  final String? descricao;
  final DateTime dataHora;
  final int duracaoMinutos;
  final int vagasTotal;
  final int vagasDisponiveis;
  final bool cheia;
  final double valorIndividual;
  final String status;
  final String? localNome;
  final String? localEndereco;
  final bool? localAcessivel;
  final Map<String, dynamic>? minhaConfirmacao;

  bool get euConfirmei =>
      minhaConfirmacao != null && minhaConfirmacao!['status'] == 'confirmado';
  bool get euNaListaEspera =>
      minhaConfirmacao != null &&
      (minhaConfirmacao!['em_lista_espera'] as bool? ?? false);
}
