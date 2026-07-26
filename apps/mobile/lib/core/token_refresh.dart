import 'package:dio/dio.dart';

import 'api_client.dart';
import 'session_store.dart';

/// Whether the server itself rejected the credential, as opposed to the request
/// never reaching a verdict (timeout, connection drop, 5xx).
bool isCredentialRejected(Object error) {
  if (error is! DioException) return false;
  final status = error.response?.statusCode;
  return status == 401 || status == 403;
}

/// Builds the single-flight 401 refresher shared by both Dio clients.
///
/// Only a server verdict on the credential may discard it: [SessionStorePort.clear]
/// also drops the offline snapshot and any uncommitted local drafts, so a weak
/// signal must fail the attempt without touching stored state.
TokenRefresher buildTokenRefresher({
  required SessionStorePort sessionStore,
  required Future<void> Function(String refreshToken) refresh,
}) {
  return () async {
    final stored = await sessionStore.readRefreshToken();
    if (stored == null || stored.isEmpty) return false;
    try {
      await refresh(stored);
      return true;
    } on Object catch (error) {
      if (isCredentialRejected(error)) {
        try {
          await sessionStore.clear();
        } on Object {
          // ignore storage failures during forced logout
        }
      }
      return false;
    }
  };
}
