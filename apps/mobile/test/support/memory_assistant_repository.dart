// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/assistant/assistant_models.dart';
import 'package:scolvpet_mobile/features/assistant/assistant_repository.dart';

class MemoryAssistantRepository implements AssistantRepository {
  MemoryAssistantRepository({this.snapshot = const AssistantSnapshot()});

  final AssistantSnapshot snapshot;

  @override
  Future<AssistantCapabilities> capabilities() async =>
      const AssistantCapabilities(
        intents: [
          'overview',
          'hamsters',
          'tasks',
          'overdue',
          'breeding',
          'usage',
          'plan',
          'help',
        ],
        modeDefault: 'rules',
        llmAvailable: false,
        disclaimer: '只读：不修改业务数据',
      );

  @override
  Future<AssistantAnswer> ask(String question, {bool preferLlm = false}) async {
    final q = question.trim();
    if (q.isEmpty) {
      throw const AssistantRepositoryException('问题不能为空');
    }
    return answerFromSnapshot(q, snapshot);
  }
}

