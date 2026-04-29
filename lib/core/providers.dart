import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/usuario.dart';
import '../features/despesas/data/despesa_repository.dart';
import '../features/partidas/data/partida_repository.dart';
import '../features/patotas/data/patota_repository.dart';
import 'config.dart';
import 'network/api_client.dart';
import 'storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: AppConfig.baseUrl,
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(apiClientProvider),
    ref.read(tokenStorageProvider),
  );
});

final patotaRepositoryProvider = Provider<PatotaRepository>((ref) {
  return PatotaRepository(ref.read(apiClientProvider));
});

final partidaRepositoryProvider = Provider<PartidaRepository>((ref) {
  return PartidaRepository(ref.read(apiClientProvider));
});

final despesaRepositoryProvider = Provider<DespesaRepository>((ref) {
  return DespesaRepository(ref.read(apiClientProvider));
});

final despesasPorPatotaProvider =
    FutureProvider.autoDispose.family<dynamic, int>((ref, patotaId) async {
  return ref.read(despesaRepositoryProvider).listarPorPatota(patotaId);
});

class AuthState {
  AuthState({this.usuario, this.carregando = false, this.erro});
  final Usuario? usuario;
  final bool carregando;
  final String? erro;

  bool get autenticado => usuario != null;

  AuthState copy({Usuario? usuario, bool? carregando, String? erro, bool limparUsuario = false}) {
    return AuthState(
      usuario: limparUsuario ? null : (usuario ?? this.usuario),
      carregando: carregando ?? this.carregando,
      erro: erro,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(AuthState());

  final AuthRepository _repo;

  Future<void> verificarSessao() async {
    state = state.copy(carregando: true);
    final u = await _repo.usuarioAtual();
    state = state.copy(usuario: u, carregando: false, limparUsuario: u == null);
  }

  Future<void> entrar(String email, String senha) async {
    state = state.copy(carregando: true, erro: null);
    try {
      final u = await _repo.login(email: email, senha: senha);
      state = AuthState(usuario: u);
    } catch (e) {
      state = state.copy(carregando: false, erro: 'Email ou senha invalidos.');
    }
  }

  Future<void> registrar({
    required String nome,
    required String email,
    required String senha,
    String? apelido,
    String? telefone,
  }) async {
    state = state.copy(carregando: true, erro: null);
    try {
      final u = await _repo.registrar(
        nome: nome,
        email: email,
        senha: senha,
        apelido: apelido,
        telefone: telefone,
      );
      state = AuthState(usuario: u);
    } catch (e) {
      state = state.copy(carregando: false, erro: 'Nao foi possivel criar a conta.');
    }
  }

  Future<void> sair() async {
    await _repo.sair();
    state = AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

final patotasProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(patotaRepositoryProvider).listar();
});

final partidasPorPatotaProvider =
    FutureProvider.autoDispose.family<dynamic, int>((ref, patotaId) async {
  return ref.read(partidaRepositoryProvider).listarPorPatota(patotaId);
});
