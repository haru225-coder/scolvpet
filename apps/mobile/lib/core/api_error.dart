import 'package:dio/dio.dart';

/// Shared API error text extraction. Feature wrappers pass local exceptions
/// and a fallback so Dio parsing is not copy-pasted 17 times.
String apiErrorMessage(
  Object error, {
  required String fallback,
  String? Function(Object error)? mapLocal,
  String? Function(DioException error)? mapDio,
  String? nonDioFallback,
}) {
  final local = mapLocal?.call(error);
  if (local != null) return local;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final message = (data['error'] as Map)['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    final custom = mapDio?.call(error);
    if (custom != null) return custom;
    return fallback;
  }
  return nonDioFallback ?? error.toString();
}
