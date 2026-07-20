import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'push_models.dart';

abstract interface class PushRepository {
  Future<List<PushDevice>> listDevices();
  Future<PushDevice> upsertDevice(PushDeviceDraft draft);
  Future<PushDevice> disableDevice(String id);

  Future<List<PushMessage>> listMessages();
  Future<PushMessage> createMessage(PushMessageDraft draft);
}

class PushRepositoryException implements Exception {
  const PushRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String pushErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '推送请求失败',
  mapLocal: (e) => e is PushRepositoryException ? e.message : null,
);

class DefaultApiPushRepository implements PushRepository {
  DefaultApiPushRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'push-${_uuid.v4()}';

  List<Map<String, dynamic>> _listData(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) {
      throw const PushRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<PushDevice>> listDevices() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/push/devices',
    );
    return _listData(response).map(PushDevice.fromJson).toList();
  }

  @override
  Future<PushDevice> upsertDevice(PushDeviceDraft draft) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '/push/devices',
      data: {
        'token': draft.token,
        'platform': draft.platform,
        'provider': draft.provider,
        if (draft.deviceName != null) 'device_name': draft.deviceName,
        if (draft.appVersion != null) 'app_version': draft.appVersion,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return PushDevice.fromJson(_data(response));
  }

  @override
  Future<PushDevice> disableDevice(String id) async {
    final response = await client.dio.delete<Map<String, dynamic>>(
      '/push/devices/$id',
    );
    return PushDevice.fromJson(_data(response));
  }

  @override
  Future<List<PushMessage>> listMessages() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/push/messages',
    );
    return _listData(response).map(PushMessage.fromJson).toList();
  }

  @override
  Future<PushMessage> createMessage(PushMessageDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/push/messages',
      data: {
        'title': draft.title,
        'body': draft.body,
        'data': draft.data,
        if (draft.targetDeviceId != null)
          'target_device_id': draft.targetDeviceId,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return PushMessage.fromJson(_data(response));
  }
}
