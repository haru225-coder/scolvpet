import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/breeding/breeding.dart';
import 'package:scolvpet_mobile/features/health/health.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';

void main() {
  test('healthTypeLabel covers quick types', () {
    expect(healthTypeLabel('daily_check'), '日常检查');
    expect(healthTypeLabel('medication'), '用药');
    expect(healthTypeLabel('anomaly'), '异常');
  });

  test('MemoryHealthRepository creates and lists by hamster', () async {
    final repo = MemoryHealthRepository();
    final created = await repo.createRecord(
      HealthRecordDraft(
        hamsterId: 'h1',
        type: 'anomaly',
        observedAt: DateTime.utc(2026, 7, 17, 8),
        severity: 'high',
        notes: '精神不佳',
      ),
    );
    expect(created.id, isNotEmpty);
    expect(created.type, 'anomaly');

    final list = await repo.listRecords(hamsterId: 'h1');
    expect(list, hasLength(1));
    expect(list.single.notes, '精神不佳');
  });

  test('HealthController creates follow-up care task when requested', () async {
    final health = MemoryHealthRepository();
    final tasks = MemoryTaskRepository();
    final controller = HealthController(
      repository: health,
      taskRepository: tasks,
    );
    await controller.loadForHamster('h1');
    final ok = await controller.create(
      HealthRecordDraft(
        hamsterId: 'h1',
        type: 'medication',
        observedAt: DateTime.utc(2026, 7, 17),
        followUpAt: DateTime.utc(2026, 7, 20),
        notes: '恩诺沙星',
        createFollowUpTask: true,
      ),
    );
    expect(ok, isTrue);
    expect(controller.lastCreatedTask, isNotNull);
    expect(controller.lastCreatedTask!.taskType, 'medication');
    final open = await tasks.listTasks();
    expect(open.where((t) => t.taskType == 'medication'), isNotEmpty);
  });

  test('breedingTasksForTransition seeds birth and weaning tasks', () {
    final before = BreedingPlan(
      id: 'p1',
      sireId: 's',
      damId: 'd',
      ruleVersionId: 'r',
      state: 'gestation',
      version: 2,
      name: '雪团计划',
    );
    final after = BreedingPlan(
      id: 'p1',
      sireId: 's',
      damId: 'd',
      ruleVersionId: 'r',
      state: 'litter_nursing',
      version: 3,
      name: '雪团计划',
      litterId: 'l1',
    );
    final drafts = breedingTasksForTransition(
      planBefore: before,
      planAfter: after,
      enclosureId: 'e1',
      litterId: 'l1',
      livePups: 5,
      now: DateTime.utc(2026, 7, 1),
    );
    expect(drafts.map((d) => d.taskType), contains('litter_observation'));
    expect(drafts.map((d) => d.taskType), contains('weaning'));
    expect(drafts.map((d) => d.taskType), contains('pup_weight_check'));
  });

  test('BreedingController advance seeds tasks via task repository', () async {
    final taskRepo = MemoryTaskRepository();
    final breeding = BreedingController(
      repository: MemoryBreedingRepository(),
      taskRepository: taskRepo,
    );
    await breeding.createPlan(
      const CreateBreedingPlanInput(
        sireId: 's1',
        damId: 'd1',
        ruleVersionId: 'rule-1',
        name: '联动测试',
      ),
    );
    // draft → pair_ready
    await breeding.advanceHappyPath(enclosureId: 'e1');
    var tasks = await taskRepo.listTasks();
    expect(tasks.any((t) => t.taskType == 'pair_prep'), isTrue);

    // pair_ready → pairing
    await breeding.advanceHappyPath(enclosureId: 'e1');
    tasks = await taskRepo.listTasks();
    expect(tasks.any((t) => t.taskType == 'pairing_timeout'), isTrue);
  });

  testWidgets('HealthQuickPage creates a daily check record', (tester) async {
    final health = MemoryHealthRepository();
    final controller = HealthController(repository: health);

    await tester.pumpWidget(
      MaterialApp(
        home: HealthQuickPage(
          controller: controller,
          hamsterId: 'h1',
          hamsterLabel: '雪团',
          canWrite: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('health-quick-add')));
    await tester.pumpAndSettle();

    expect(find.text('快捷健康记录'), findsOneWidget);
    await tester.tap(find.byKey(const Key('health-type-daily_check')));
    await tester.enterText(find.byKey(const Key('health-notes')), '食欲正常');
    await tester.tap(find.byKey(const Key('health-save')));
    await tester.pumpAndSettle();

    expect(find.textContaining('已保存'), findsWidgets);
    final list = await health.listRecords(hamsterId: 'h1');
    expect(list, hasLength(1));
    expect(list.single.notes, '食欲正常');
  });
}
