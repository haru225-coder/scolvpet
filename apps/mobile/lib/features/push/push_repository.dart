import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
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

String pushErrorMessage(Object error) {
  if (error is PushRepositoryException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final message = (data['error'] as Map)['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return '推送请求失败';
  }
  return error.toString();
}

/// Local token for PARTIAL builds without FCM/APNs SDK.
String generateDevPushToken({String? platform}) {
  final p = platform ?? defaultTargetPlatform.name.toLowerCase();
  return 'dev-$p-${const Uuid().v4()}';
}

String detectPushPlatform() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return 'ios';
    case TargetPlatform.android:
      return 'android';
    default:
      return 'unknown';
  }
}

class MemoryPushRepository implements PushRepository {
  final List<PushDevice> _devices = [];
  final List<PushMessage> _messages = [];
  int _seq = 0;

  @override
  Future<List<PushDevice>> listDevices() async =>
      List<PushDevice>.from(_devices);

  @override
  Future<PushDevice> upsertDevice(PushDeviceDraft draft) async {
    final token = draft.token.trim();
    if (token.isEmpty) {
      throw const PushRepositoryException('推送令牌必填');
    }
    final index = _devices.indexWhere((d) => d.token == token);
    if (index >= 0) {
      final current = _devices[index];
      final next = PushDevice(
        id: current.id,
        platform: draft.platform,
        provider: 'log',
        token: token,
        deviceName: draft.deviceName ?? current.deviceName,
        appVersion: draft.appVersion ?? current.appVersion,
        enabled: true,
        lastSeenAt: DateTime.now().toUtc(),
        version: current.version + 1,
      );
      _devices[index] = next;
      return next;
    }
    final item = PushDevice(
      id: 'pdev-${_seq++}',
      platform: draft.platform,
      provider: 'log',
      token: token,
      deviceName: draft.deviceName,
      appVersion: draft.appVersion,
      enabled: true,
      lastSeenAt: DateTime.now().toUtc(),
      version: 1,
    );
    _devices.insert(0, item);
    return item;
  }

  @override
  Future<PushDevice> disableDevice(String id) async {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index < 0) throw const PushRepositoryException('设备不存在');
    final current = _devices[index];
    final next = PushDevice(
      id: current.id,
      platform: current.platform,
      provider: current.provider,
      token: current.token,
      deviceName: current.deviceName,
      appVersion: current.appVersion,
      enabled: false,
      lastSeenAt: current.lastSeenAt,
      version: current.version + 1,
    );
    _devices[index] = next;
    return next;
  }

  @override
  Future<List<PushMessage>> listMessages() async =>
      List<PushMessage>.from(_messages);

  @override
  Future<PushMessage> createMessage(PushMessageDraft draft) async {
    final title = draft.title.trim();
    final body = draft.body.trim();
    if (title.isEmpty) throw const PushRepositoryException('标题必填');
    if (body.isEmpty) throw const PushRepositoryException('正文必填');
    final enabled = _devices.where((d) => d.enabled).toList();
    final hasTarget = draft.targetDeviceId == null
        ? enabled.isNotEmpty
        : enabled.any((d) => d.id == draft.targetDeviceId);
    final status = hasTarget ? 'sent' : 'failed';
    final item = PushMessage(
      id: 'pmsg-${_seq++}',
      title: title,
      body: body,
      data: draft.data,
      status: status,
      targetDeviceId: draft.targetDeviceId,
      provider: 'log',
      providerMessageId: hasTarget ? 'log-mem-$_seq' : null,
      attemptCount: 1,
      lastError: hasTarget ? null : 'no enabled push devices',
      sentAt: hasTarget ? DateTime.now().toUtc() : null,
      version: 1,
      createdAt: DateTime.now().toUtc(),
    );
    _messages.insert(0, item);
    return item;
  }
}

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
