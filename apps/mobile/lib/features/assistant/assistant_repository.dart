import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'assistant_models.dart';

abstract interface class AssistantRepository {
  Future<AssistantCapabilities> capabilities();
  Future<AssistantAnswer> ask(String question, {bool preferLlm = false});
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
    // Agent 需要读取业务快照并等待模型生成结构化操作；单独放宽这条
    // 请求的接收窗口，避免通用 API client 的 12 秒窗口提前取消请求。
    final response = await client.withP2ReceiveTimeout(
      const Duration(seconds: 35),
      () => client.p2Api.askAssistant(
        assistantAskRequest: api.AssistantAskRequest(
          question: question,
          preferLlm: preferLlm,
        ),
        idempotencyKey: 'ask-${_uuid.v4()}',
      ),
    );
    final data = response.data?.data;
    if (data == null) {
      throw const AssistantRepositoryException('响应为空');
    }
    return _mapAnswer(data);
  }
}

AssistantCapabilities _mapCapabilities(api.AssistantCapabilities data) =>
    AssistantCapabilities(
      intents: List<String>.from(data.intents),
      modeDefault: data.modeDefault.value,
      llmAvailable: data.llmAvailable,
      disclaimer: data.disclaimer,
    );

AssistantAnswer _mapAnswer(api.AssistantAnswer data) => AssistantAnswer(
  answer: data.answer,
  intent: data.intent,
  mode: data.mode.value,
  facts: data.facts
      .map(
        (fact) => AssistantFact(
          key: fact.key,
          label: fact.label,
          value: fact.value,
          source: fact.source_,
        ),
      )
      .toList(growable: false),
  disclaimer: data.disclaimer,
  // OpenAPI AssistantAnswer 当前无 actions 字段；保留空列表以兼容 UI 动作入口。
  actions: const <AssistantAction>[],
);
