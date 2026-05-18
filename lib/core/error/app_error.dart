import 'package:dio/dio.dart';

/// Erro normalizado para exibicao na UI.
/// Use [AppError.fromDio] para converter erros Dio em mensagem amigavel.
class AppError {
  AppError({required this.mensagem, this.codigo, this.campos = const {}});

  final String mensagem;
  final int? codigo;
  final Map<String, List<String>> campos;

  bool get ehValidacao => codigo == 422 && campos.isNotEmpty;
  bool get ehAuth => codigo == 401 || codigo == 419;
  bool get ehPermissao => codigo == 403;
  bool get ehRede => codigo == null;

  /// Primeira mensagem de validacao de um campo (ou null se nao houver).
  String? primeiroErroDe(String campo) {
    final lista = campos[campo];
    return lista == null || lista.isEmpty ? null : lista.first;
  }

  factory AppError.fromException(Object e) {
    if (e is DioException) return AppError.fromDio(e);
    return AppError(mensagem: 'Algo deu errado. Tente novamente.');
  }

  factory AppError.fromDio(DioException e) {
    final res = e.response;

    // Sem resposta = problema de rede / timeout
    if (res == null) {
      final isTimeout = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      return AppError(
        mensagem: isTimeout
            ? 'O servidor demorou para responder. Tente novamente.'
            : 'Sem conexao. Verifique sua internet.',
      );
    }

    final status = res.statusCode ?? 0;
    final data = res.data;

    // Auth
    if (status == 401) return AppError(codigo: 401, mensagem: 'E-mail ou senha invalidos.');
    if (status == 403) return AppError(codigo: 403, mensagem: _msg(data) ?? 'Voce nao tem permissao para isso.');
    if (status == 404) return AppError(codigo: 404, mensagem: _msg(data) ?? 'Recurso nao encontrado.');

    // Validacao 422
    if (status == 422 && data is Map) {
      final campos = <String, List<String>>{};
      final raw = data['errors'];
      if (raw is Map) {
        raw.forEach((k, v) {
          if (v is List) campos[k.toString()] = v.map((e) => e.toString()).toList();
        });
      }
      return AppError(
        codigo: 422,
        mensagem: _msg(data) ?? 'Verifique os campos preenchidos.',
        campos: campos,
      );
    }

    // 5xx
    if (status >= 500) {
      return AppError(codigo: status, mensagem: 'Erro no servidor (' + status.toString() + '). Tente mais tarde.');
    }

    return AppError(codigo: status, mensagem: _msg(data) ?? 'Algo deu errado.');
  }

  static String? _msg(dynamic data) {
    if (data is Map) {
      return data['mensagem']?.toString() ?? data['message']?.toString();
    }
    return null;
  }

  @override
  String toString() => mensagem;
}
