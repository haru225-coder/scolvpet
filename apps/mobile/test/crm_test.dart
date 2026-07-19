import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/crm/crm.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';

void main() {
  test(
    'MemoryCrmRepository contact → reservation → handover complete',
    () async {
      final repo = MemoryCrmRepository();
      final contact = await repo.createContact(
        const CrmContactDraft(
          name: '小王',
          phone: '13800001111',
          wechat: 'xiaowang_hamster',
          notes: '偏好温顺个体',
        ),
      );
      expect(contact.status, 'lead');
      expect(contact.phone, '13800001111');
      expect(contact.wechat, 'xiaowang_hamster');
      expect(contact.notes, '偏好温顺个体');

      final reservation = await repo.createReservation(
        CrmReservationDraft(
          contactId: contact.id,
          title: '预订雪团后代',
          hamsterId: 'h-1',
        ),
      );
      expect(reservation.status, 'held');

      final confirmed = await repo.confirmReservation(
        reservation.id,
        reservation.version,
      );
      expect(confirmed.status, 'confirmed');

      final plannedAt = DateTime(2026, 8, 21, 14, 30);
      final handover = await repo.createHandover(
        CrmHandoverDraft(
          contactId: contact.id,
          reservationId: confirmed.id,
          hamsterId: 'h-1',
          scheduledAt: plannedAt,
        ),
      );
      expect(handover.status, 'scheduled');
      expect(handover.hamsterId, 'h-1');
      expect(handover.scheduledAt, plannedAt.toUtc());

      final done = await repo.completeHandover(handover.id, handover.version);
      expect(done.status, 'completed');
      expect(done.completedAt, isNotNull);
      expect(done.hamsterId, 'h-1');
      expect(done.scheduledAt, plannedAt.toUtc());

      final reservations = await repo.listReservations();
      expect(reservations.single.status, 'handed_over');
      expect(reservations.single.hamsterId, 'h-1');
      final contacts = await repo.listContacts();
      expect(contacts.single.status, 'active');
      expect(contacts.single.phone, '13800001111');
      expect(contacts.single.wechat, 'xiaowang_hamster');
    },
  );

  testWidgets('CrmHubPage creates contact and shows it', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = MemoryCrmRepository();
    final controller = CrmController(repository: repository);
    await tester.pumpWidget(
      MaterialApp(home: CrmHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('客户与交付'), findsOneWidget);
    await tester.tap(find.byKey(const Key('crm-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('crm-contact-name')), '阿花');
    await tester.enterText(
      find.byKey(const Key('crm-contact-phone')),
      '13900002222',
    );
    await tester.ensureVisible(find.byKey(const Key('crm-contact-submit')));
    await tester.tap(find.byKey(const Key('crm-contact-submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('阿花'), findsOneWidget);
    final contact = controller.contactsState.data!.single;
    expect(contact.name, '阿花');
    expect(contact.phone, '13900002222');
    expect((await repository.listContacts()).single.phone, '13900002222');
  });

  testWidgets(
    'handover form links reservation hamster and completion refreshes CRM',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repository = MemoryCrmRepository();
      final contact = await repository.createContact(
        const CrmContactDraft(name: '小王', phone: '13800001111'),
      );
      final held = await repository.createReservation(
        CrmReservationDraft(
          contactId: contact.id,
          title: '预订雪团',
          hamsterId: 'h-1',
        ),
      );
      await repository.confirmReservation(held.id, held.version);
      final controller = CrmController(repository: repository);
      const hamster = I2Hamster(
        id: 'h-1',
        internalCode: 'H-001',
        name: '雪团',
        sex: 'female',
        varietyCode: 'golden',
        lifecycleStatus: 'active',
        breedingStatus: 'candidate',
        birthDate: null,
        currentEnclosureId: null,
        litterId: null,
        notes: null,
        version: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CrmHubPage(controller: controller, hamsters: const [hamster]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('交付'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('crm-fab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('crm-handover-reservation')));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoPicker), findsOneWidget);
      await tester.drag(find.byType(CupertinoPicker), const Offset(0, -60));
      await tester.pumpAndSettle();
      await tester.tap(find.text('完成').last);
      await tester.pumpAndSettle();

      expect(find.text('预订雪团'), findsOneWidget);
      expect(find.text('雪团 · H-001'), findsOneWidget);
      await tester.tap(find.byKey(const Key('crm-handover-submit')));
      await tester.pumpAndSettle();

      final scheduled = controller.handoversState.data!.single;
      expect(scheduled.reservationId, held.id);
      expect(scheduled.hamsterId, hamster.id);
      expect(scheduled.status, 'scheduled');
      expect(scheduled.scheduledAt.toLocal().hour, 10);

      await tester.tap(find.byKey(Key('crm-handover-${scheduled.id}')));
      await tester.pumpAndSettle();
      final completeButton = find.byKey(
        Key('crm-handover-complete-${scheduled.id}'),
      );
      expect(tester.widget<FilledButton>(completeButton).onPressed, isNull);

      for (final checkbox in find.byType(CheckboxListTile).evaluate()) {
        await tester.tap(find.byWidget(checkbox.widget));
        await tester.pump();
      }
      expect(tester.widget<FilledButton>(completeButton).onPressed, isNotNull);
      await tester.ensureVisible(completeButton);
      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      expect(controller.handoversState.data!.single.status, 'completed');
      expect(controller.handoversState.data!.single.hamsterId, hamster.id);
      expect(controller.reservationsState.data!.single.status, 'handed_over');
      expect(controller.contactsState.data!.single.status, 'active');
    },
  );

  testWidgets('CrmHubPage keeps records readable but hides writes', (
    tester,
  ) async {
    final controller = CrmController(repository: MemoryCrmRepository());
    await tester.pumpWidget(
      MaterialApp(home: CrmHubPage(controller: controller, canWrite: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('客户与交付'), findsOneWidget);
    expect(find.textContaining('当前角色可查看客户'), findsOneWidget);
    expect(find.byKey(const Key('crm-fab')), findsNothing);
    expect(find.byKey(const Key('crm-refresh')), findsOneWidget);
  });
}
