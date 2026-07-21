// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/assistant/assistant_models.dart';
import 'package:scolvpet_mobile/features/assistant/assistant_repository.dart';

class MemoryAssistantRepository implements AssistantRepository {
  MemoryAssistantRepository({this.snapshot = const AssistantSnapshot()});

  final AssistantSnapshot snapshot;
  String? lastSessionId;

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
          'general',
        ],
        modeDefault: 'rules',
        llmAvailable: false,
        disclaimer: '只读：不修改业务数据',
      );

  @override
  Future<AssistantAnswer> ask(String question, {bool preferLlm = false}) async {
    final result = await chat(question, preferLlm: preferLlm);
    return result.answer;
  }

  @override
  Future<AssistantChatResult> chat(
    String message, {
    String? sessionId,
    bool preferLlm = true,
  }) async {
    final q = message.trim();
    if (q.isEmpty) {
      throw const AssistantRepositoryException('问题不能为空');
    }
    lastSessionId = sessionId ?? 'mem-session';
    return AssistantChatResult(
      sessionId: lastSessionId!,
      messageId: 'mem-msg',
      answer: answerFromSnapshot(q, snapshot),
    );
  }

  @override
  Future<Map<String, dynamic>> confirmAction(String actionId) async =>
      <String, dynamic>{'status': 'executed', 'action_id': actionId};

  @override
  Future<void> cancelAction(String actionId) async {}
}
