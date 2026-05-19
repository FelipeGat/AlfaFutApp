class Usuario {
  Usuario({
    required this.id,
    required this.nome,
    this.apelido,
    required this.email,
    this.telefone,
    this.posicaoPreferida,
    this.nivelHabilidade,
    this.preferenciasAcessibilidade,
    this.role = 'user',
    this.isAdmin = false,
  });

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id: j['id'] as int,
        nome: j['nome'] as String? ?? '',
        apelido: j['apelido'] as String?,
        email: j['email'] as String,
        telefone: j['telefone'] as String?,
        posicaoPreferida: j['posicao_preferida'] as String?,
        nivelHabilidade: j['nivel_habilidade'] as String?,
        preferenciasAcessibilidade: j['preferencias_acessibilidade'] as Map<String, dynamic>?,
        role: j['role'] as String? ?? 'user',
        isAdmin: j['is_admin'] as bool? ?? false,
      );

  final int id;
  final String nome;
  final String? apelido;
  final String email;
  final String? telefone;
  final String? posicaoPreferida;
  final String? nivelHabilidade;
  final Map<String, dynamic>? preferenciasAcessibilidade;
  final String role;
  final bool isAdmin;

  String get nomeExibicao => apelido ?? nome;

  bool get altoContraste =>
      (preferenciasAcessibilidade?['alto_contraste'] as bool?) ?? false;

  String get tamanhoFonte =>
      (preferenciasAcessibilidade?['tamanho_fonte'] as String?) ?? 'media';

  bool get reduzirMovimento =>
      (preferenciasAcessibilidade?['reduzir_movimento'] as bool?) ?? false;
}
