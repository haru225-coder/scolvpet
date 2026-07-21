// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/push/push_models.dart';
import 'package:scolvpet_mobile/features/push/push_repository.dart';

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
