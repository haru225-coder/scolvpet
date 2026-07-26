import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/i2/i2.dart';

import 'support/memory_repositories.dart';

/// Wave 1 weight correction loop: a mistaken reading is superseded by a new
/// record pointing back at it, never edited in place and never deleted.
void main() {
  final recordedAt = DateTime.utc(2026, 7, 20, 9);

  I2WeightRecord seedRecord({String id = 'w-1', num weightG = 50}) =>
      I2WeightRecord(
        id: id,
        hamsterId: 'h-1',
        litterId: null,
        measurementKind: 'individual',
        subjectCount: null,
        weightG: weightG,
        recordedAt: recordedAt,
        source: 'manual',
        previousWeightG: null,
        changeFromPreviousG: null,
        notes: null,
      );

  Future<I2Controller> buildController(MemoryI2Repository repo) async {
    final controller = I2Controller(
      repository: repo,
      localStore: MemoryI2LocalStore(),
    );
    await controller.restore();
    return controller;
  }

  test('MemoryI2Repository refuses a correction without a reason', () async {
    final original = seedRecord();
    final repo = MemoryI2Repository(weights: [original]);

    expect(
      () => repo.createWeight(
        I2WeightDraft(
          hamsterId: 'h-1',
          weightG: 45,
          recordedAt: recordedAt,
          correctsWeightRecordId: original.id,
        ),
      ),
      throwsA(isA<I2RepositoryException>()),
    );

    final corrected = await repo.createWeight(
      I2WeightDraft(
        hamsterId: 'h-1',
        weightG: 45,
        recordedAt: recordedAt,
        correctsWeightRecordId: original.id,
        correctionReason: '秤没归零',
      ),
    );
    expect(corrected.correctsWeightRecordId, original.id);
    expect(corrected.correctionReason, '秤没归零');
    expect(corrected.isCorrection, isTrue);

    // The original survives — this is an audit chain, not an edit.
    final history = await repo.listWeights('h-1');
    expect(history.map((w) => w.id), contains(original.id));
    expect(history, hasLength(2));
  });

  testWidgets('WeightEntryPage prefills the reading it supersedes', (
    tester,
  ) async {
    final original = seedRecord(weightG: 50);
    final controller = await buildController(
      MemoryI2Repository(weights: [original]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WeightEntryPage(
          controller: controller,
          hamsterId: 'h-1',
          correcting: original,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weight-correction-banner')), findsOneWidget);
    expect(find.text('纠正体重'), findsWidgets);
    expect(find.widgetWithText(TextField, '50'), findsOneWidget);
  });

  testWidgets('WeightEntryPage will not save a correction without a reason', (
    tester,
  ) async {
    final original = seedRecord(weightG: 50);
    final repo = MemoryI2Repository(weights: [original]);
    final controller = await buildController(repo);

    await tester.pumpWidget(
      MaterialApp(
        home: WeightEntryPage(
          controller: controller,
          hamsterId: 'h-1',
          correcting: original,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '45');
    await tester.ensureVisible(find.byType(I2WriteButton));
    await tester.tap(find.byType(I2WriteButton));
    await tester.pumpAndSettle();

    // Backing out of the reason sheet must leave the history untouched.
    await tester.tap(find.byKey(const Key('weight-correction-correction-cancel')));
    await tester.pumpAndSettle();

    expect(await repo.listWeights('h-1'), hasLength(1));
  });

  testWidgets('WeightEntryPage saves a correction with its reason', (
    tester,
  ) async {
    final original = seedRecord(weightG: 50);
    final repo = MemoryI2Repository(weights: [original]);
    final controller = await buildController(repo);
    var saved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: WeightEntryPage(
          controller: controller,
          hamsterId: 'h-1',
          correcting: original,
          onSaved: () => saved = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '45');
    await tester.ensureVisible(find.byType(I2WriteButton));
    await tester.tap(find.byType(I2WriteButton));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('weight-correction-correction-reason')),
      '秤没归零',
    );
    await tester.tap(
      find.byKey(const Key('weight-correction-correction-confirm')),
    );
    await tester.pumpAndSettle();

    expect(saved, isTrue);
    final history = await repo.listWeights('h-1');
    expect(history, hasLength(2));
    final correction = history.firstWhere((w) => w.isCorrection);
    expect(correction.weightG, 45);
    expect(correction.correctsWeightRecordId, original.id);
    expect(correction.correctionReason, '秤没归零');
  });

  testWidgets('WeightEntryPage stays a plain entry form without a target', (
    tester,
  ) async {
    final repo = MemoryI2Repository();
    final controller = await buildController(repo);

    await tester.pumpWidget(
      MaterialApp(
        home: WeightEntryPage(controller: controller, hamsterId: 'h-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weight-correction-banner')), findsNothing);
    expect(find.text('录入体重'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '52');
    await tester.ensureVisible(find.byType(I2WriteButton));
    await tester.tap(find.byType(I2WriteButton));
    await tester.pumpAndSettle();

    // No reason sheet stands between an ordinary reading and the save.
    final history = await repo.listWeights('h-1');
    expect(history, hasLength(1));
    expect(history.single.isCorrection, isFalse);
  });
}
