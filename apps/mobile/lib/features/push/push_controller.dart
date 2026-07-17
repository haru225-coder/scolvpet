import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'push_models.dart';
import 'push_repository.dart';

class PushController extends ChangeNotifier {
  PushController({required this.repository});

  final PushRepository repository;

  I2AsyncState<List<PushDevice>> devicesState = const I2AsyncState.idle();
  I2AsyncState<List<PushMessage>> messagesState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;
  String? lastRegisteredToken;

  Future<void> refreshAll() async {
    await Future.wait([refreshDevices(), refreshMessages()]);
  }

  Future<void> refreshDevices() async {
    devicesState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listDevices();
      devicesState = items.isEmpty
          ? const I2AsyncState.empty(message: '尚未注册推送设备')
          : I2AsyncState.data(items);
    } catch (error) {
      devicesState = I2AsyncState.error(pushErrorMessage(error));
    }
    notifyListeners();
  }

  Future<void> refreshMessages() async {
    messagesState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final items = await repository.listMessages();
      messagesState = items.isEmpty
          ? const I2AsyncState.empty(message: '暂无推送记录')
          : I2AsyncState.data(items);
    } catch (error) {
      messagesState = I2AsyncState.error(pushErrorMessage(error));
    }
    notifyListeners();
  }

  /// Registers a dev/log token when FCM/APNs SDK is not wired yet.
  Future<bool> registerThisDevice({String? token}) => _run(() async {
    final platform = detectPushPlatform();
    final resolved = (token == null || token.trim().isEmpty)
        ? generateDevPushToken(platform: platform)
        : token.trim();
    final device = await repository.upsertDevice(
      PushDeviceDraft(
        token: resolved,
        platform: platform,
        provider: 'log',
        deviceName: '熊舍管家',
        appVersion: '0.1.0',
      ),
    );
    lastRegisteredToken = device.token;
    lastMessage = '设备已注册（${device.provider} / ${device.platformLabel}）';
    await refreshDevices();
  });

  Future<bool> disableDevice(PushDevice device) => _run(() async {
    await repository.disableDevice(device.id);
    lastMessage = '设备已停用';
    await refreshDevices();
  });

  Future<bool> sendTestMessage({
    String title = '熊舍管家测试推送',
    String body = '服务端推送链路已接通（log 提供商）',
  }) => _run(() async {
    final message = await repository.createMessage(
      PushMessageDraft(title: title, body: body, data: {'kind': 'test'}),
    );
    lastMessage = message.isSent
        ? '测试推送已发送'
        : '推送创建但未送达：${message.lastError ?? message.statusLabel}';
    await refreshMessages();
  });

  Future<bool> _run(Future<void> Function() body) async {
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      await body();
      actionState = const I2AsyncState.data(null);
      notifyListeners();
      return true;
    } catch (error) {
      final message = pushErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
