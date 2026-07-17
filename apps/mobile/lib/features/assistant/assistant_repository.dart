import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
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

String assistantErrorMessage(Object error) {
  if (error is AssistantRepositoryException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final message = (data['error'] as Map)['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return '助手请求失败';
  }
  return error.toString();
}

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

class DefaultApiAssistantRepository implements AssistantRepository {
  DefaultApiAssistantRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) {
      throw const AssistantRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<AssistantCapabilities> capabilities() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/assistant/capabilities',
    );
    return AssistantCapabilities.fromJson(_data(response));
  }

  @override
  Future<AssistantAnswer> ask(String question, {bool preferLlm = false}) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/assistant/ask',
      data: {
        'question': question,
        'prefer_llm': preferLlm,
      },
      options: Options(
        headers: {'Idempotency-Key': 'ask-${_uuid.v4()}'},
      ),
    );
    return AssistantAnswer.fromJson(_data(response));
  }
}
