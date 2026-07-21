import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/push/push.dart';
import 'support/memory_repositories.dart';

void main() {
  test('MemoryPushRepository register and send test', () async {
    final repo = MemoryPushRepository();
    final device = await repo.upsertDevice(
      const PushDeviceDraft(token: 'dev-android-token-1', platform: 'android'),
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

  testWidgets('PushSettingsPage is a read-only availability notice', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PushSettingsPage()));
    await tester.pumpAndSettle();
    expect(find.text('通知说明'), findsOneWidget);
    expect(find.byKey(const Key('push-read-only')), findsOneWidget);
    expect(find.byKey(const Key('push-in-app-ready')), findsOneWidget);
    expect(find.byKey(const Key('push-register')), findsNothing);
    expect(find.byKey(const Key('push-send-test')), findsNothing);
    expect(find.textContaining('log'), findsNothing);
  });
}
