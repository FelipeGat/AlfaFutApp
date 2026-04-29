import 'evento_partida.dart';
import 'time_partida.dart';

class Placar {
  Placar({
    required this.placarA,
    required this.placarB,
    required this.tempoSegundos,
    required this.tempoFormatado,
    required this.emAndamento,
    required this.pausada,
    required this.finalizada,
    this.iniciadaEm,
    this.times = const [],
    this.eventos = const [],
  });

  factory Placar.fromJson(Map<String, dynamic> j) => Placar(
        placarA: (j['placar_a'] as int?) ?? 0,
        placarB: (j['placar_b'] as int?) ?? 0,
        tempoSegundos: (j['tempo_segundos'] as int?) ?? 0,
        tempoFormatado: j['tempo_formatado'] as String? ?? '00:00',
        emAndamento: j['em_andamento'] as bool? ?? false,
        pausada: j['pausada'] as bool? ?? false,
        finalizada: j['finalizada'] as bool? ?? false,
        iniciadaEm: j['iniciada_em'] != null ? DateTime.tryParse(j['iniciada_em']) : null,
        times: ((j['times'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(TimePartida.fromJson)
            .toList(),
        eventos: ((j['eventos'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(EventoPartida.fromJson)
            .toList(),
      );

  final int placarA;
  final int placarB;
  final int tempoSegundos;
  final String tempoFormatado;
  final bool emAndamento;
  final bool pausada;
  final bool finalizada;
  final DateTime? iniciadaEm;
  final List<TimePartida> times;
  final List<EventoPartida> eventos;

  TimePartida? get timeA => times.isNotEmpty ? times[0] : null;
  TimePartida? get timeB => times.length > 1 ? times[1] : null;

  /// Soma de gols por jogador (artilharia ranqueada)
  List<MapEntry<EventoPartida, int>> get artilharia {
    final golsPorJogador = <int, EventoPartida>{};
    final contagem = <int, int>{};
    for (final ev in eventos.where((e) => e.tipo == 'gol' && e.jogadorId != null)) {
      golsPorJogador[ev.jogadorId!] = ev;
      contagem[ev.jogadorId!] = (contagem[ev.jogadorId!] ?? 0) + 1;
    }
    final lista = contagem.entries
        .map((e) => MapEntry(golsPorJogador[e.key]!, e.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return lista;
  }
}
