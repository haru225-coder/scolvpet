import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'assistant_models.dart';

abstract interface class AssistantRepository {
  Future<AssistantCapabilities> capabilities();
  Future<AssistantAnswer> ask(String question, {bool preferLlm = false});

  /// Slice A multi-turn chat. Pass [sessionId] to continue a thread.
  Future<AssistantChatResult> chat(
    String message, {
    String? sessionId,
    bool preferLlm = true,
  });

  /// Slice C: execute a pending write draft.
  Future<Map<String, dynamic>> confirmAction(String actionId);

  /// Slice C: cancel a pending write draft.
  Future<void> cancelAction(String actionId);
}

class AssistantRepositoryException implements Exception {
  const AssistantRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String assistantErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '助手请求失败',
  mapLocal: (e) => e is AssistantRepositoryException ? e.message : null,
  mapDio: (e) {
    if (e.response != null &&
        e.response!.statusCode != null &&
        e.response!.statusCode! >= 200 &&
        e.response!.statusCode! < 300) {
      return '助手数据格式异常，请稍后重试或更新应用';
    }
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return '助手响应超时，请稍后重试';
    }
    return null;
  },
);

class DefaultApiAssistantRepository implements AssistantRepository {
  DefaultApiAssistantRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  @override
  Future<AssistantCapabilities> capabilities() async {
    final response = await client.p2Api.assistantCapabilities();
    final data = response.data?.data;
    if (data == null) {
      throw const AssistantRepositoryException('响应为空');
    }
    return _mapCapabilities(data);
  }

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
    // 通用对话 + tool 可能较慢；单独放宽 receive 窗口。
    final response = await client.withP2ReceiveTimeout(
      const Duration(seconds: 45),
      () => client.p2Api.chatAssistant(
        assistantChatRequest: api.AssistantChatRequest(
          message: message,
          sessionId: sessionId == null || sessionId.isEmpty ? null : sessionId,
          preferLlm: preferLlm,
        ),
        idempotencyKey: 'chat-${_uuid.v4()}',
      ),
    );
    final data = response.data?.data;
    if (data == null) {
      throw const AssistantRepositoryException('响应为空');
    }
    return AssistantChatResult(
      sessionId: data.sessionId,
      messageId: data.messageId,
      answer: _mapChatAnswer(data),
    );
  }

  @override
  Future<Map<String, dynamic>> confirmAction(String actionId) async {
    final id = actionId.trim();
    if (id.isEmpty) {
      throw const AssistantRepositoryException('动作 ID 无效');
    }
    final response = await client.p2Api.confirmAssistantAction(
      actionId: id,
      idempotencyKey: 'confirm-${_uuid.v4()}',
    );
    return response.data?.data.toJson() ?? <String, dynamic>{};
  }

  @override
  Future<void> cancelAction(String actionId) async {
    final id = actionId.trim();
    if (id.isEmpty) {
      throw const AssistantRepositoryException('动作 ID 无效');
    }
    await client.p2Api.cancelAssistantAction(
      actionId: id,
      idempotencyKey: 'cancel-${_uuid.v4()}',
    );
  }
}

AssistantCapabilities _mapCapabilities(api.AssistantCapabilities data) =>
    AssistantCapabilities(
      intents: List<String>.from(data.intents),
      modeDefault: data.modeDefault.value,
      llmAvailable: data.llmAvailable,
      disclaimer: data.disclaimer,
    );

AssistantAnswer _mapChatAnswer(api.AssistantChatResult data) {
  final facts = data.facts
      .map(
        (fact) => AssistantFact(
          key: fact.key,
          label: fact.label,
          value: fact.value,
          source: fact.source_,
        ),
      )
      .toList(growable: false);
  final actions = data.actions
      .map(
        (action) => AssistantAction(
          type: action.type,
          label: action.label,
          summary: action.summary,
          requiresConfirmation: action.requiresConfirmation,
          payload: Map<String, dynamic>.from(action.payload),
          actionId: action.actionId,
        ),
      )
      .toList(growable: false);
  return AssistantAnswer(
    answer: data.answer,
    intent: data.intent,
    mode: data.mode.value,
    facts: facts,
    disclaimer: data.disclaimer,
    actions: actions,
  );
}

class AssistantChatResult {
  const AssistantChatResult({
    required this.sessionId,
    required this.messageId,
    required this.answer,
  });

  final String sessionId;
  final String messageId;
  final AssistantAnswer answer;
}
