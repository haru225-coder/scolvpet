import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/core/session_store.dart';
import 'package:scolvpet_mobile/core/token_refresh.dart';

DioException _withStatus(int status) {
  final options = RequestOptions(path: '/v1/auth/sessions/refresh');
  return DioException(
    requestOptions: options,
    response: Response<dynamic>(requestOptions: options, statusCode: status),
    type: DioExceptionType.badResponse,
  );
}

DioException _networkFailure(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/v1/auth/sessions/refresh'),
  type: type,
);

void main() {
  group('buildTokenRefresher', () {
    test(
      'keeps credentials when the refresh never reaches a verdict',
      () async {
        // clear() also wipes the offline snapshot and uncommitted drafts, so a
        // weak signal must never trigger it.
        for (final type in [
          DioExceptionType.connectionTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.connectionError,
        ]) {
          final store = _RecordingSessionStore(refreshToken: 'rt_valid');
          final refresher = buildTokenRefresher(
            sessionStore: store,
            refresh: (_) async => throw _networkFailure(type),
          );

          expect(await refresher(), isFalse);
          expect(
            store.cleared,
            isFalse,
            reason: '$type must not discard tokens',
          );
        }
      },
    );

    test('keeps credentials when the server fails with 5xx', () async {
      final store = _RecordingSessionStore(refreshToken: 'rt_valid');
      final refresher = buildTokenRefresher(
        sessionStore: store,
        refresh: (_) async => throw _withStatus(500),
      );

      expect(await refresher(), isFalse);
      expect(store.cleared, isFalse);
    });

    test('discards credentials only when the server rejects them', () async {
      for (final status in [401, 403]) {
        final store = _RecordingSessionStore(refreshToken: 'rt_stale');
        final refresher = buildTokenRefresher(
          sessionStore: store,
          refresh: (_) async => throw _withStatus(status),
        );

        expect(await refresher(), isFalse);
        expect(store.cleared, isTrue, reason: '$status must force logout');
      }
    });

    test('reports success and forwards the stored refresh token', () async {
      final store = _RecordingSessionStore(refreshToken: 'rt_valid');
      String? seen;
      final refresher = buildTokenRefresher(
        sessionStore: store,
        refresh: (token) async => seen = token,
      );

      expect(await refresher(), isTrue);
      expect(seen, 'rt_valid');
      expect(store.cleared, isFalse);
    });

    test('short-circuits without a stored refresh token', () async {
      final store = _RecordingSessionStore();
      var called = false;
      final refresher = buildTokenRefresher(
        sessionStore: store,
        refresh: (_) async => called = true,
      );

      expect(await refresher(), isFalse);
      expect(called, isFalse);
      expect(store.cleared, isFalse);
    });
  });
}

class _RecordingSessionStore implements SessionStorePort {
  _RecordingSessionStore({this.refreshToken});

  final String? refreshToken;
  bool cleared = false;

  @override
  Future<void> clear() async {
    cleared = true;
  }

  @override
  Future<String?> readAccessToken() async => 'access';

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<SessionSnapshot?> readSnapshot() async => null;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {}

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}
