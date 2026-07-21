import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'assistant_models.dart';
import 'assistant_repository.dart';

class AssistantChatTurn {
  const AssistantChatTurn({required this.question, required this.answer});

  final String question;
  final AssistantAnswer answer;
}

class AssistantController extends ChangeNotifier {
  AssistantController({required this.repository});

  final AssistantRepository repository;

  I2AsyncState<AssistantCapabilities> capabilitiesState =
      const I2AsyncState.idle();
  I2AsyncState<void> askingState = const I2AsyncState.idle();
  final List<AssistantChatTurn> turns = [];
  String? lastMessage;

  /// Server-side multi-turn session (Slice A).
  String? sessionId;
  // 有可用的 Grok2API 时默认走通用对话；服务端无 Key 会自动回退规则模式。
  bool preferLlm = true;

  Future<void> refreshCapabilities() async {
    capabilitiesState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final caps = await repository.capabilities();
      capabilitiesState = I2AsyncState.data(caps);
      if (!caps.llmAvailable) preferLlm = false;
    } catch (error) {
      capabilitiesState = I2AsyncState.error(assistantErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> ask(String question) async {
    final q = question.trim();
    if (q.isEmpty) {
      lastMessage = '请输入问题';
      notifyListeners();
      return false;
    }
    askingState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      final result = await repository.chat(
        q,
        sessionId: sessionId,
        preferLlm: preferLlm,
      );
      if (result.sessionId.isNotEmpty) {
        sessionId = result.sessionId;
      }
      turns.insert(0, AssistantChatTurn(question: q, answer: result.answer));
      askingState = const I2AsyncState.data(null);
      notifyListeners();
      return true;
    } catch (error) {
      lastMessage = assistantErrorMessage(error);
      askingState = I2AsyncState.error(lastMessage!);
      notifyListeners();
      return false;
    }
  }

  void setPreferLlm(bool value) {
    preferLlm = value;
    notifyListeners();
  }

  void clear() {
    turns.clear();
    sessionId = null;
    notifyListeners();
  }

  Future<bool> confirmAction(AssistantAction action) async {
    final id = action.actionId?.trim();
    if (id == null || id.isEmpty) {
      lastMessage = '缺少可确认的动作 ID';
      notifyListeners();
      return false;
    }
    askingState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      await repository.confirmAction(id);
      lastMessage = '已确认并执行：${action.label}';
      askingState = const I2AsyncState.data(null);
      notifyListeners();
      return true;
    } catch (error) {
      lastMessage = assistantErrorMessage(error);
      askingState = I2AsyncState.error(lastMessage!);
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAction(AssistantAction action) async {
    final id = action.actionId?.trim();
    if (id == null || id.isEmpty) {
      lastMessage = '缺少可取消的动作 ID';
      notifyListeners();
      return false;
    }
    try {
      await repository.cancelAction(id);
      lastMessage = '已取消：${action.label}';
      notifyListeners();
      return true;
    } catch (error) {
      lastMessage = assistantErrorMessage(error);
      notifyListeners();
      return false;
    }
  }
}
