import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

import 'session_store.dart';

class ApiClient {
  ApiClient({required String baseUrl, required SessionStorePort sessionStore})
    : _sessionStore = sessionStore {
    final root = _apiRootBase(baseUrl);
    // DefaultApi / existing feature paths are relative to /v1 (e.g. /breeding-plans).
    _dio = Dio(
      BaseOptions(
        baseUrl: '$root/v1',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        headers: {'Accept': 'application/json'},
        // 显式允许 2xx（含 201 Created / 202 Accepted），避免生成客户端把成功状态码当成错误
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    _dio.interceptors.add(_authInterceptor());
    api = DefaultApi(_dio);

    // P1/P2 generated clients emit absolute /v1/... paths; they must share the
    // host root, not the /v1 base used by DefaultApi and hand-written dio calls.
    _p2Dio = Dio(
      BaseOptions(
        baseUrl: root,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        headers: {'Accept': 'application/json'},
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );
    _p2Dio.interceptors.add(_authInterceptor());
    p2Api = P2Api(_p2Dio);
  }

  QueuedInterceptorsWrapper _authInterceptor() => QueuedInterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await _sessionStore.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  );

  late final Dio _dio;
  late final Dio _p2Dio;
  late final DefaultApi api;
  late final P2Api p2Api;
  final SessionStorePort _sessionStore;

  Dio get dio => _dio;

  /// Host-root Dio for endpoints not yet in generated client (chat/actions).
  Dio get p2Dio => _p2Dio;

  /// Temporarily override receive timeout on the P2 generated client.
  Future<T> withP2ReceiveTimeout<T>(
    Duration receiveTimeout,
    Future<T> Function() run,
  ) async {
    final previous = _p2Dio.options.receiveTimeout;
    _p2Dio.options.receiveTimeout = receiveTimeout;
    try {
      return await run();
    } finally {
      _p2Dio.options.receiveTimeout = previous;
    }
  }
}

String _apiRootBase(String baseUrl) {
  var root = baseUrl.replaceFirst(RegExp(r'/$'), '');
  if (root.endsWith('/v1')) {
    root = root.substring(0, root.length - 3);
  }
  return root;
}
