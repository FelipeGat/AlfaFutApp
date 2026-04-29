import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

class ApiClient {
  ApiClient({required String baseUrl, required this.tokenStorage})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opcoes, handler) async {
        final token = await tokenStorage.token();
        if (token != null) {
          opcoes.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(opcoes);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          await tokenStorage.limpar();
        }
        handler.next(e);
      },
    ));
  }

  final Dio _dio;
  final TokenStorage tokenStorage;

  Dio get dio => _dio;
}
