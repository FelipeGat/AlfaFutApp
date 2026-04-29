import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'usuario.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokenStorage);

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  Future<Usuario> login({required String email, required String senha}) async {
    final r = await _api.dio.post('/auth/login', data: {
      'email': email,
      'password': senha,
      'device_name': 'app-mobile',
    });
    final usuario = Usuario.fromJson(r.data['usuario'] as Map<String, dynamic>);
    await _tokenStorage.salvar(r.data['token'] as String, usuario.id);
    return usuario;
  }

  Future<Usuario> registrar({
    required String nome,
    required String email,
    required String senha,
    String? apelido,
    String? telefone,
  }) async {
    final r = await _api.dio.post('/auth/registrar', data: {
      'name': nome,
      'apelido': apelido,
      'email': email,
      'password': senha,
      'telefone': telefone,
    });
    final usuario = Usuario.fromJson(r.data['usuario'] as Map<String, dynamic>);
    await _tokenStorage.salvar(r.data['token'] as String, usuario.id);
    return usuario;
  }

  Future<Usuario?> usuarioAtual() async {
    final token = await _tokenStorage.token();
    if (token == null) return null;
    try {
      final r = await _api.dio.get('/auth/eu');
      return Usuario.fromJson(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (_) {
      return null;
    }
  }

  Future<void> sair() async {
    try {
      await _api.dio.post('/auth/logout');
    } on DioException catch (_) {
      // ignora erro de rede; token sera limpo localmente
    }
    await _tokenStorage.limpar();
  }
}
