import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/stud/stud.dart';

void main() {
  test('MemoryStudRepository listing and deal lifecycle', () async {
    final repo = MemoryStudRepository();
    final listing = await repo.createListing(
      const StudListingDraft(sireLabel: '雪球', title: '雪球借配', feeCents: 10000),
    );
    expect(listing.published, isTrue);
    final deal = await repo.createDeal(
      StudDealDraft(
        listingId: listing.id,
        side: 'requester',
        partnerCatteryName: '邻舍',
        myHamsterLabel: '阿花',
      ),
    );
    expect(deal.status, 'requested');
    expect(deal.feeCents, 10000);
    final confirmed = await repo.confirm(deal.id);
    expect(confirmed.status, 'confirmed');
    final started = await repo.start(deal.id);
    expect(started.status, 'in_progress');
    final done = await repo.complete(deal.id);
    expect(done.status, 'completed');
  });

  testWidgets('StudHubPage creates listing', (tester) async {
    final controller = StudController(repository: MemoryStudRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: StudHubPage(
          controller: controller,
          hamsters: const [
            I2Hamster(
              id: 'sire-1',
              internalCode: 'M-01',
              name: '大王',
              sex: 'male',
              varietyCode: 'golden',
              lifecycleStatus: 'active',
              breedingStatus: 'candidate',
              birthDate: null,
              currentEnclosureId: null,
              litterId: null,
              notes: null,
              version: 1,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('跨舍借配'), findsOneWidget);
    await tester.tap(find.byKey(const Key('stud-fab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stud-listing-sire')), findsOneWidget);
    await tester.tap(find.byKey(const Key('stud-listing-submit')));
    await tester.pumpAndSettle();
    expect(controller.listingsState.hasValue, isTrue);
    expect(controller.listingsState.data!.single.sireLabel, '大王 · M-01');
  });
}
