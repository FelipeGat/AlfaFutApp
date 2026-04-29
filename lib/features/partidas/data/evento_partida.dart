class EventoPartida {
  EventoPartida({
    required this.id,
    required this.tipo,
    required this.minuto,
    this.timeId,
    this.timeNome,
    this.jogadorId,
    this.jogadorNome,
    this.criadoEm,
  });

  factory EventoPartida.fromJson(Map<String, dynamic> j) => EventoPartida(
        id: j['id'] as int,
        tipo: j['tipo'] as String,
        minuto: (j['minuto'] as int?) ?? 0,
        timeId: j['time_id'] as int?,
        timeNome: j['time_nome'] as String?,
        jogadorId: j['jogador_id'] as int?,
        jogadorNome: j['jogador_nome'] as String?,
        criadoEm: j['criado_em'] != null ? DateTime.tryParse(j['criado_em']) : null,
      );

  final int id;
  final String tipo;
  final int minuto;
  final int? timeId;
  final String? timeNome;
  final int? jogadorId;
  final String? jogadorNome;
  final DateTime? criadoEm;

  bool get ehGol => tipo == 'gol' || tipo == 'gol_contra';

  String get icone {
    return switch (tipo) {
      'gol' => '⚽',
      'gol_contra' => '😬',
      'inicio' => '▶️',
      'pausa' => '⏸️',
      'retomada' => '▶️',
      'fim' => '🏁',
      _ => '·',
    };
  }
}
