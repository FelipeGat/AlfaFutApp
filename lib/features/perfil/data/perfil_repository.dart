import '../../../core/network/api_client.dart';
import '../../auth/data/usuario.dart';

class PerfilRepository {
  PerfilRepository(this._api);
  final ApiClient _api;

  Future<Usuario> atualizarPerfil({
    String? nome,
    String? apelido,
    String? telefone,
    String? posicaoPreferida,
    String? nivelHabilidade,
  }) async {
    final r = await _api.dio.patch('/perfil', data: {
      if (nome != null) 'name': nome,
      if (apelido != null) 'apelido': apelido,
      if (telefone != null) 'telefone': telefone,
      if (posicaoPreferida != null) 'posicao_preferida': posicaoPreferida,
      if (nivelHabilidade != null) 'nivel_habilidade': nivelHabilidade,
    });
    return Usuario.fromJson(r.data['data'] as Map<String, dynamic>);
  }

  Future<Usuario> atualizarAcessibilidade({
    bool? altoContraste,
    String? tamanhoFonte,
    bool? reduzirMovimento,
    bool? leitorTelaOtimizado,
    List<String>? necessidades,
  }) async {
    final r = await _api.dio.patch('/perfil/acessibilidade', data: {
      if (altoContraste != null) 'alto_contraste': altoContraste,
      if (tamanhoFonte != null) 'tamanho_fonte': tamanhoFonte,
      if (reduzirMovimento != null) 'reduzir_movimento': reduzirMovimento,
      if (leitorTelaOtimizado != null) 'leitor_tela_otimizado': leitorTelaOtimizado,
      if (necessidades != null) 'necessidades_acessibilidade': necessidades,
    });
    return Usuario.fromJson(r.data['data'] as Map<String, dynamic>);
  }
}
