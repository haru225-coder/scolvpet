import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/breeding/breeding.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'support/memory_repositories.dart';

void main() {
  test('wizardStepForState maps happy path', () {
    expect(wizardStepForState('draft'), BreedingWizardStep.draft);
    expect(wizardStepForState('pair_ready'), BreedingWizardStep.pairReady);
    expect(wizardStepForState('pairing'), BreedingWizardStep.pairing);
    expect(wizardStepForState('post_pair'), BreedingWizardStep.postPair);
    expect(wizardStepForState('gestation'), BreedingWizardStep.gestation);
    expect(
      wizardStepForState('litter_nursing'),
      BreedingWizardStep.litterNursing,
    );
    expect(nextActionLabel('draft'), '发布计划');
    expect(nextActionLabel('gestation'), '确认产仔');
    expect(nextActionLabel('litter_nursing'), isNull);
  });

  test('MemoryBreedingRepository advances draft to litter_nursing', () async {
    final repo = MemoryBreedingRepository();
    final created = await repo.createPlan(
      const CreateBreedingPlanInput(
        sireId: 'sire-1',
        damId: 'dam-1',
        ruleVersionId: 'rule-1',
        name: '测试计划',
      ),
    );
    expect(created.state, 'draft');

    var plan = await repo.publishPlan(
      planId: created.id,
      version: created.version,
      plannedPairingAt: DateTime.utc(2026, 7, 17),
      pairingEnclosureId: 'enc-1',
    );
    expect(plan.state, 'pair_ready');

    final paired = await repo.startPairing(
      planId: plan.id,
      version: plan.version,
      enclosureId: 'enc-1',
      startedAt: DateTime.utc(2026, 7, 17, 1),
    );
    plan = paired.plan;
    expect(plan.state, 'pairing');
    expect(paired.attempt.status, 'active');

    final separated = await repo.separatePairing(
      planId: plan.id,
      attemptId: paired.attempt.id,
      planVersion: plan.version,
      attemptVersion: paired.attempt.version,
      separatedAt: DateTime.utc(2026, 7, 17, 2),
      result: 'effective',
      sireDestinationEnclosureId: 'enc-2',
      damDestinationEnclosureId: 'enc-1',
    );
    plan = separated.plan;
    expect(plan.state, 'post_pair');

    plan = await repo.startGestation(
      planId: plan.id,
      version: plan.version,
      pairingAttemptId: separated.attempt.id,
      result: 'effective',
      baselineAt: DateTime.utc(2026, 7, 17, 3),
    );
    expect(plan.state, 'gestation');

    final birth = await repo.confirmBirth(
      planId: plan.id,
      version: plan.version,
      bornAt: DateTime.utc(2026, 8, 3),
      enclosureId: 'enc-1',
      initialAliveCount: 5,
    );
    expect(birth.plan.state, 'litter_nursing');
    expect(birth.litterId, isNotNull);
  });

  test('BreedingController advanceHappyPath runs full happy path', () async {
    final repo = MemoryBreedingRepository();
    final controller = BreedingController(repository: repo);
    await controller.createPlan(
      const CreateBreedingPlanInput(
        sireId: 'sire-1',
        damId: 'dam-1',
        ruleVersionId: 'rule-1',
        name: '控制器计划',
      ),
    );
    expect(controller.selected?.state, 'draft');

    for (final expected in [
      'pair_ready',
      'pairing',
      'post_pair',
      'gestation',
      'litter_nursing',
    ]) {
      final ok = await controller.advanceHappyPath(enclosureId: 'enc-1');
      expect(ok, isTrue, reason: 'failed before $expected');
      expect(controller.selected?.state, expected);
    }
  });

  testWidgets('BreedingWizardPage shows create and advances action', (
    tester,
  ) async {
    final repo = MemoryBreedingRepository(
      seed: [
        const BreedingPlan(
          id: 'plan-seed',
          sireId: 'sire-1',
          damId: 'dam-1',
          ruleVersionId: 'rule-1',
          state: 'draft',
          version: 1,
          name: '种子计划',
        ),
      ],
    );
    final controller = BreedingController(repository: repo);
    await controller.refresh();

    await tester.pumpWidget(
      MaterialApp(
        home: BreedingWizardPage(
          controller: controller,
          hamsters: const [
            I2Hamster(
              id: 'sire-1',
              internalCode: 'M-1',
              name: '公',
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
            I2Hamster(
              id: 'dam-1',
              internalCode: 'F-1',
              name: '母',
              sex: 'female',
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
          enclosures: const [
            I2Enclosure(
              id: 'enc-1',
              code: 'A-1',
              rackCode: 'A',
              levelCode: '1',
              state: 'vacant',
              cleanlinessState: 'clean',
              capacity: 2,
              equipment: <String>[],
              lastCleanedAt: null,
              currentHamsterIds: <String>[],
              version: 1,
            ),
          ],
          ruleVersionId: 'rule-1',
          onOpenLitters: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('繁育向导'), findsOneWidget);
    expect(find.text('种子计划'), findsOneWidget);
    expect(find.text('发布计划'), findsOneWidget);

    await tester.tap(find.byKey(const Key('breeding-next-plan-seed')));
    await tester.pumpAndSettle();
    // Publishing draft opens the pairing enclosure picker.
    expect(find.text('选择配对笼盒'), findsOneWidget);
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();
    expect(find.text('开始配对'), findsOneWidget);
    expect(controller.selected?.state, 'pair_ready');
  });
}
