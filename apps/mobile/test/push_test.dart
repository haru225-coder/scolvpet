import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/push/push.dart';

void main() {
  test('MemoryPushRepository register and send test', () async {
    final repo = MemoryPushRepository();
    final device = await repo.upsertDevice(
      const PushDeviceDraft(
        token: 'dev-android-token-1',
        platform: 'android',
      ),
    );
    expect(device.enabled, isTrue);
    final message = await repo.createMessage(
      const PushMessageDraft(title: '测试', body: '你好'),
    );
    expect(message.status, 'sent');
    expect(message.providerMessageId, isNotNull);

    await repo.disableDevice(device.id);
    final failed = await repo.createMessage(
      const PushMessageDraft(title: '再测', body: '应失败'),
    );
    expect(failed.status, 'failed');
  });

  testWidgets('PushSettingsPage registers device', (tester) async {
    final controller = PushController(repository: MemoryPushRepository());
    await tester.pumpWidget(
      MaterialApp(home: PushSettingsPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('服务端推送'), findsOneWidget);
    await tester.tap(find.byKey(const Key('push-register')));
    await tester.pumpAndSettle();
    expect(controller.devicesState.hasValue, isTrue);
    expect(controller.lastMessage, contains('设备已注册'));
    await tester.tap(find.byKey(const Key('push-send-test')));
    await tester.pumpAndSettle();
    expect(controller.messagesState.hasValue, isTrue);
    expect(controller.lastMessage, contains('测试推送已发送'));
    expect(controller.messagesState.data!.single.isSent, isTrue);
  });
}
