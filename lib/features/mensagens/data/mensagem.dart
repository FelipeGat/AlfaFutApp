class Mensagem {
  Mensagem({
    required this.id,
    required this.patotaId,
    this.partidaId,
    required this.conteudo,
    required this.tipo,
    required this.fixada,
    this.autorNome,
    this.autorApelido,
    this.criadaEm,
  });

  factory Mensagem.fromJson(Map<String, dynamic> j) {
    final autor = j['autor'];
    Map<String, dynamic>? autorMap;
    if (autor is Map) {
      autorMap = autor['data'] is Map ? Map<String, dynamic>.from(autor['data']) : Map<String, dynamic>.from(autor);
    }
    return Mensagem(
      id: j['id'] as int,
      patotaId: j['patota_id'] as int,
      partidaId: j['partida_id'] as int?,
      conteudo: j['conteudo'] as String,
      tipo: j['tipo'] as String? ?? 'texto',
      fixada: j['fixada'] as bool? ?? false,
      autorNome: autorMap?['nome'] as String?,
      autorApelido: autorMap?['apelido'] as String?,
      criadaEm: j['criada_em'] != null ? DateTime.tryParse(j['criada_em']) : null,
    );
  }

  final int id;
  final int patotaId;
  final int? partidaId;
  final String conteudo;
  final String tipo;
  final bool fixada;
  final String? autorNome;
  final String? autorApelido;
  final DateTime? criadaEm;

  String get autorExibicao => autorApelido ?? autorNome ?? 'Desconhecido';
}
