import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/assistant/assistant.dart';

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
    final controller = AssistantController(
      repository: MemoryAssistantRepository(
        snapshot: const AssistantSnapshot(
          organizationName: '雪团熊舍',
          activeHamsters: 9,
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: AssistantPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('AI 只读助手'), findsOneWidget);
    await tester.tap(find.byKey(const Key('assistant-preset-现在有多少只在养？')));
    await tester.pumpAndSettle();
    expect(controller.turns, isNotEmpty);
    expect(controller.turns.first.answer.answer, contains('9'));
    expect(find.textContaining('9'), findsWidgets);
  });
}
