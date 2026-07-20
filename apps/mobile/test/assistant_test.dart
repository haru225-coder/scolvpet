import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/assistant/assistant.dart';
import 'package:scolvpet_mobile/features/tasks/task_models.dart';
import 'support/memory_repositories.dart';

void main() {
  test('detectAssistantIntent and answerFromSnapshot', () {
    final snap = const AssistantSnapshot(
      organizationName: '雪团熊舍',
      activeHamsters: 12,
      openTasks: 3,
      overdueTasks: 1,
    );
    expect(detectAssistantIntent('在养多少'), 'hamsters');
    final ans = answerFromSnapshot('在养多少', snap);
    expect(ans.answer, contains('12'));
    expect(ans.mode, 'rules');
  });

  test('MemoryAssistantRepository ask', () async {
    final repo = MemoryAssistantRepository(
      snapshot: const AssistantSnapshot(
        organizationName: '雪团熊舍',
        overdueTasks: 2,
        openTasks: 5,
      ),
    );
    final ans = await repo.ask('有逾期任务吗');
    expect(ans.intent, 'overdue');
    expect(ans.answer, contains('2'));
  });

  testWidgets('AssistantPage answers preset', (tester) async {
    var openedHamsters = false;
    final controller = AssistantController(
      repository: MemoryAssistantRepository(
        snapshot: const AssistantSnapshot(
          organizationName: '雪团熊舍',
          activeHamsters: 9,
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AssistantPage(
          controller: controller,
          onOpenHamsters: () => openedHamsters = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('问问管家'), findsWidgets);
    expect(find.text('LLM 润色'), findsNothing);
    await tester.tap(find.byKey(const Key('assistant-preset-现在有多少只在养？')));
    await tester.pumpAndSettle();
    expect(controller.turns, isNotEmpty);
    expect(controller.turns.first.answer.answer, contains('9'));
    expect(find.textContaining('9'), findsWidgets);
    expect(find.text('相关数据'), findsOneWidget);
    expect(find.text('建议'), findsOneWidget);
    expect(find.text('操作'), findsOneWidget);
    expect(find.textContaining('意图 '), findsNothing);
    expect(find.textContaining('模式 '), findsNothing);
    final openHamsters = find.text('打开仓鼠列表');
    await tester.ensureVisible(openHamsters);
    await tester.pumpAndSettle();
    await tester.tap(openHamsters);
    expect(openedHamsters, isTrue);
  });

  testWidgets('AssistantPage opens confirmed task draft from agent action', (
    tester,
  ) async {
    CreateCareTaskDraft? openedDraft;
    final controller = AssistantController(repository: _AgentRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: AssistantPage(
          controller: controller,
          onOpenTaskDraft: (draft) => openedDraft = draft,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('assistant-input')), '给雪团安排称重');
    await tester.tap(find.byKey(const Key('assistant-send')));
    await tester.pumpAndSettle();

    expect(find.text('需确认'), findsOneWidget);
    expect(find.text('一小时后给雪团称重'), findsOneWidget);
    expect(find.text('内部调试动作'), findsNothing);
    final action = find.byKey(const Key('assistant-action-task_draft'));
    await tester.ensureVisible(action);
    await tester.pumpAndSettle();
    await tester.tap(action);
    expect(openedDraft, isNotNull);
    expect(openedDraft!.targetId, 'hamster-1');
    expect(openedDraft!.title, '给雪团称重');
  });

  testWidgets('AssistantPage hides actions without executable callbacks', (
    tester,
  ) async {
    final controller = AssistantController(repository: _AgentRepository());
    await tester.pumpWidget(
      MaterialApp(home: AssistantPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('assistant-input')), '给雪团安排称重');
    await tester.tap(find.byKey(const Key('assistant-send')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('assistant-action-task_draft')), findsNothing);
    expect(find.text('内部调试动作'), findsNothing);
    expect(find.text('操作'), findsNothing);
  });

  testWidgets('AssistantPage shows busy and error states', (tester) async {
    final busyRepository = _BusyAssistantRepository();
    final busyController = AssistantController(repository: busyRepository);
    await tester.pumpWidget(
      MaterialApp(home: AssistantPage(controller: busyController)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('assistant-input')), '现在有多少只？');
    await tester.tap(find.byKey(const Key('assistant-send')));
    await tester.pump();

    final sendButton = tester.widget<FilledButton>(
      find.byKey(const Key('assistant-send')),
    );
    expect(sendButton.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    busyRepository.answer.complete(
      const AssistantAnswer(
        answer: '当前在养 9 只。',
        intent: 'hamsters',
        mode: 'rules',
        facts: <AssistantFact>[],
        disclaimer: '',
      ),
    );
    await tester.pumpAndSettle();

    final failingController = AssistantController(
      repository: _FailingAssistantRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AssistantPage(
          key: const ValueKey('failing-assistant'),
          controller: failingController,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('assistant-capabilities-error')),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('assistant-input')), '再试一次');
    await tester.tap(find.byKey(const Key('assistant-send')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('assistant-question-error')), findsOneWidget);
  });
}

class _AgentRepository implements AssistantRepository {
  @override
  Future<AssistantCapabilities> capabilities() async =>
      const AssistantCapabilities(
        intents: ['tasks'],
        modeDefault: 'agent',
        llmAvailable: true,
        disclaimer: 'Agent 操作需要确认',
      );

  @override
  Future<AssistantAnswer> ask(
    String question, {
    bool preferLlm = false,
  }) async => AssistantAnswer(
    answer: '建议创建一条称重任务草案。',
    intent: 'tasks',
    mode: 'agent',
    facts: const [],
    disclaimer: '需要确认',
    actions: [
      AssistantAction(
        type: 'task_draft',
        label: '查看称重任务',
        summary: '一小时后给雪团称重',
        requiresConfirmation: true,
        payload: {
          'task_type': 'custom',
          'target_type': 'hamster',
          'target_id': 'hamster-1',
          'title': '给雪团称重',
          'scheduled_at': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
          'priority': 'normal',
        },
      ),
      const AssistantAction(
        type: 'internal_debug',
        label: '内部调试动作',
        summary: '这条动作不应展示',
        requiresConfirmation: false,
        payload: <String, dynamic>{},
      ),
    ],
  );
}

class _BusyAssistantRepository implements AssistantRepository {
  final Completer<AssistantAnswer> answer = Completer<AssistantAnswer>();

  @override
  Future<AssistantCapabilities> capabilities() async =>
      const AssistantCapabilities(
        intents: <String>['hamsters'],
        modeDefault: 'rules',
        llmAvailable: false,
        disclaimer: '',
      );

  @override
  Future<AssistantAnswer> ask(String question, {bool preferLlm = false}) =>
      answer.future;
}

class _FailingAssistantRepository implements AssistantRepository {
  @override
  Future<AssistantCapabilities> capabilities() async {
    throw const AssistantRepositoryException('问答服务暂时不可用');
  }

  @override
  Future<AssistantAnswer> ask(String question, {bool preferLlm = false}) async {
    throw const AssistantRepositoryException('没有查到结果，请稍后重试');
  }
}
