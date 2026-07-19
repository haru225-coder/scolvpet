import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scolvpet_mobile/core/session_store.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/assistant/assistant.dart';
import 'package:scolvpet_mobile/features/health/health.dart';
import 'package:scolvpet_mobile/features/i2/i2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('local snapshot safety', () {
    test('invalid session snapshot is discarded instead of throwing', () async {
      SharedPreferences.setMockInitialValues({
        'scolvpet.read_snapshot': '{truncated',
      });

      final store = SessionStore();

      expect(await store.readSnapshot(), isNull);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.containsKey('scolvpet.read_snapshot'), isFalse);
    });

    test('legacy session snapshot accepts camel-case system rules', () async {
      SharedPreferences.setMockInitialValues({
        'scolvpet.read_snapshot': jsonEncode({
          'account': {'id': 'account-1'},
          'organization': {'id': 'organization-1'},
          'rules': <Object?>[],
          'systemRules': [
            {'id': 'rule-1'},
          ],
        }),
      });

      final snapshot = await SessionStore().readSnapshot();

      expect(snapshot, isNotNull);
      expect(snapshot!.systemRules, hasLength(1));
    });

    test('logout cleanup removes account-bound snapshots and drafts', () async {
      SharedPreferences.setMockInitialValues({
        'scolvpet.read_snapshot': '{}',
        'scolvpet.i2.snapshot': '{}',
        'scolvpet.i2.drafts': '[]',
        'today_widget_json': '{}',
      });

      await SessionStore().clear();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.containsKey('scolvpet.read_snapshot'), isFalse);
      expect(preferences.containsKey('scolvpet.i2.snapshot'), isFalse);
      expect(preferences.containsKey('scolvpet.i2.drafts'), isFalse);
      expect(preferences.containsKey('today_widget_json'), isFalse);
    });

    test('invalid I2 cache and draft container safely fall back', () async {
      SharedPreferences.setMockInitialValues({
        'scolvpet.i2.snapshot': '[]',
        'scolvpet.i2.drafts': '{}',
      });
      final preferences = await SharedPreferences.getInstance();
      final store = SharedPreferencesI2LocalStore(preferences: preferences);

      expect(await store.readSnapshot(), isNull);
      expect(await store.readDrafts(), isEmpty);
      expect(preferences.containsKey('scolvpet.i2.snapshot'), isFalse);
      expect(preferences.containsKey('scolvpet.i2.drafts'), isFalse);
    });

    test(
      'I2 cache keeps hamster cover identity and resolved avatar URL',
      () async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final store = SharedPreferencesI2LocalStore(preferences: preferences);
        final snapshot = _snapshot('avatar').copyWithHamsterAvatarForTest();

        await store.saveSnapshot(snapshot);
        final restored = await store.readSnapshot();

        expect(restored!.hamsters.single.coverMediaId, 'media-1');
        expect(
          restored.hamsters.single.avatarUrl,
          'https://cdn.example/avatar.webp',
        );
        expect(restored.hamsters.single.avatarBytes, <int>[1, 2, 3]);
      },
    );
  });

  test('latest I2 refresh wins when requests finish out of order', () async {
    final repository = _SequencedI2Repository();
    final localStore = MemoryI2LocalStore();
    final controller = I2Controller(
      repository: repository,
      localStore: localStore,
    );

    final firstRestore = controller.restore();
    await Future<void>.delayed(Duration.zero);
    expect(repository.loadCount, 1);

    final secondRestore = controller.restore();
    await Future<void>.delayed(Duration.zero);
    expect(repository.loadCount, 2);

    repository.second.complete(_snapshot('new'));
    await secondRestore;
    repository.first.complete(_snapshot('old'));
    await firstRestore;

    expect(controller.snapshotState.data!.hamsters.single.id, 'new');
    expect((await localStore.readSnapshot())!.hamsters.single.id, 'new');
  });

  test('HealthController ignores notification after dispose', () async {
    final repository = _DelayedHealthRepository();
    final controller = HealthController(repository: repository);

    final load = controller.loadForHamster('hamster-1');
    controller.dispose();
    repository.records.complete(const <HealthRecordItem>[]);

    await expectLater(load, completes);
  });

  testWidgets('assistant request completion does not touch disposed input', (
    tester,
  ) async {
    final repository = _DelayedAssistantRepository();
    final controller = AssistantController(repository: repository);
    await tester.pumpWidget(
      MaterialApp(home: AssistantPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('assistant-input')), '现在有多少只？');
    await tester.tap(find.byKey(const Key('assistant-send')));
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    repository.answer.complete(
      const AssistantAnswer(
        answer: '9 只',
        intent: 'hamsters',
        mode: 'rules',
        facts: <AssistantFact>[],
        disclaimer: '',
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}

I2Snapshot _snapshot(String id) => I2Snapshot(
  hamsters: [
    I2Hamster(
      id: id,
      internalCode: id,
      name: id,
      sex: 'unknown',
      varietyCode: null,
      lifecycleStatus: 'active',
      breedingStatus: 'candidate',
      birthDate: null,
      currentEnclosureId: null,
      litterId: null,
      notes: null,
      version: 1,
    ),
  ],
  litters: const <I2Litter>[],
  enclosures: const <I2Enclosure>[],
  lastSyncedAt: DateTime.utc(2026, 7, 18),
);

extension on I2Snapshot {
  I2Snapshot copyWithHamsterAvatarForTest() {
    final hamster = hamsters.single;
    return I2Snapshot(
      hamsters: [
        I2Hamster.fromJson({
          ...hamster.toJson(),
          'cover_media_id': 'media-1',
          'avatar_url': 'https://cdn.example/avatar.webp',
          'avatar_bytes': 'AQID',
        }),
      ],
      litters: litters,
      enclosures: enclosures,
      lastSyncedAt: lastSyncedAt,
      recentWeights: recentWeights,
    );
  }
}

class _SequencedI2Repository extends MemoryI2Repository {
  final first = Completer<I2Snapshot>();
  final second = Completer<I2Snapshot>();
  int loadCount = 0;

  @override
  Future<I2Snapshot> loadSnapshot() {
    loadCount += 1;
    return loadCount == 1 ? first.future : second.future;
  }
}

class _DelayedHealthRepository extends MemoryHealthRepository {
  final records = Completer<List<HealthRecordItem>>();

  @override
  Future<List<HealthRecordItem>> listRecords({
    String? hamsterId,
    String? litterId,
  }) => records.future;
}

class _DelayedAssistantRepository extends MemoryAssistantRepository {
  final answer = Completer<AssistantAnswer>();

  @override
  Future<AssistantAnswer> ask(String question, {bool preferLlm = false}) =>
      answer.future;
}
