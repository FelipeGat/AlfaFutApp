import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._storage);

  static const _chaveToken = 'alfafut_token';
  static const _chaveUsuario = 'alfafut_usuario_id';

  final FlutterSecureStorage _storage;

  Future<void> salvar(String token, int usuarioId) async {
    await _storage.write(key: _chaveToken, value: token);
    await _storage.write(key: _chaveUsuario, value: usuarioId.toString());
  }

  Future<String?> token() => _storage.read(key: _chaveToken);

  Future<int?> usuarioId() async {
    final v = await _storage.read(key: _chaveUsuario);
    return v == null ? null : int.tryParse(v);
  }

  Future<void> limpar() async {
    await _storage.delete(key: _chaveToken);
    await _storage.delete(key: _chaveUsuario);
  }
}
