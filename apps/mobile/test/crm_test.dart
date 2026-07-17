import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/crm/crm.dart';

void main() {
  test('MemoryCrmRepository contact → reservation → handover complete', () async {
    final repo = MemoryCrmRepository();
    final contact = await repo.createContact(
      const CrmContactDraft(name: '小王', phone: '13800001111'),
    );
    expect(contact.status, 'lead');

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

    final handover = await repo.createHandover(
      CrmHandoverDraft(
        contactId: contact.id,
        reservationId: confirmed.id,
        hamsterId: 'h-1',
      ),
    );
    expect(handover.status, 'scheduled');

    final done = await repo.completeHandover(handover.id, handover.version);
    expect(done.status, 'completed');
    expect(done.completedAt, isNotNull);

    final reservations = await repo.listReservations();
    expect(reservations.single.status, 'handed_over');
    final contacts = await repo.listContacts();
    expect(contacts.single.status, 'active');
  });

  testWidgets('CrmHubPage creates contact and shows it', (tester) async {
    final controller = CrmController(repository: MemoryCrmRepository());
    await tester.pumpWidget(
      MaterialApp(home: CrmHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('客户与交付'), findsOneWidget);
    await tester.tap(find.byKey(const Key('crm-fab')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('crm-contact-name')), '阿花');
    await tester.tap(find.byKey(const Key('crm-contact-submit')));
    await tester.pumpAndSettle();

    expect(find.textContaining('阿花'), findsOneWidget);
  });
}
