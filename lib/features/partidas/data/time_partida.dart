class TimePartida {
  TimePartida({
    required this.id,
    required this.nome,
    this.cor,
    required this.gols,
    this.brasao,
    this.jogadores = const [],
  });

  factory TimePartida.fromJson(Map<String, dynamic> j) => TimePartida(
        id: j['id'] as int,
        nome: j['nome'] as String,
        cor: j['cor'] as String?,
        gols: (j['gols'] as int?) ?? 0,
        brasao: j['brasao'] as String?,
        jogadores: ((j['jogadores'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(JogadorTime.fromJson)
            .toList(),
      );

  final int id;
  final String nome;
  final String? cor;
  final int gols;
  final String? brasao;
  final List<JogadorTime> jogadores;
}

class JogadorTime {
  JogadorTime({
    required this.id,
    required this.nome,
    this.posicao,
    required this.gols,
  });

  factory JogadorTime.fromJson(Map<String, dynamic> j) => JogadorTime(
        id: j['id'] as int,
        nome: j['nome'] as String,
        posicao: j['posicao'] as String?,
        gols: (j['gols'] as int?) ?? 0,
      );

  final int id;
  final String nome;
  final String? posicao;
  final int gols;
}
