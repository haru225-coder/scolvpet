import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

import 'session_store.dart';

class ApiClient {
  ApiClient({required String baseUrl, required SessionStorePort sessionStore})
    : _sessionStore = sessionStore {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${baseUrl.replaceFirst(RegExp(r'/$'), '')}/v1',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        headers: {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    api = DefaultApi(_dio);
  }

  late final Dio _dio;
  late final DefaultApi api;
  final SessionStorePort _sessionStore;

  Dio get dio => _dio;
}
