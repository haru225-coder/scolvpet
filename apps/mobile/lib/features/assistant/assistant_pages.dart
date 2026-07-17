import 'package:flutter/material.dart';

import 'assistant_controller.dart';

/// Read-only structured assistant chat (T-P2-03).
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key, required this.controller});

  final AssistantController controller;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _input = TextEditingController();
  final _presets = const [
    '现在有多少只在养？',
    '有没有逾期任务？',
    '繁育概况怎么样？',
    '我的套餐是什么？',
    '你能做什么？',
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.refreshCapabilities();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _ask([String? text]) async {
    final q = text ?? _input.text;
    final ok = await widget.controller.ask(q);
    if (ok) _input.clear();
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (!ok && message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final caps = widget.controller.capabilitiesState.data;
        final asking = widget.controller.askingState.status.name == 'loading';
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI 只读助手'),
            actions: [
              if (caps?.llmAvailable == true)
                Row(
                  children: [
                    const Text('LLM 润色', style: TextStyle(fontSize: 12)),
                    Switch(
                      key: const Key('assistant-llm-switch'),
                      value: widget.controller.preferLlm,
                      onChanged: widget.controller.setPreferLlm,
                    ),
                  ],
                ),
              IconButton(
                key: const Key('assistant-clear'),
                onPressed: () {
                  widget.controller.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  caps?.disclaimer ??
                      '只读助手：基于结构化查询回答在养/任务/繁育/用量，不会改数据。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  children: [
                    for (final p in _presets) ...[
                      ActionChip(
                        key: Key('assistant-preset-$p'),
                        label: Text(p),
                        onPressed: asking ? null : () => _ask(p),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: widget.controller.turns.isEmpty
                    ? const Center(
                        child: Text('点上方快捷问题，或输入自然语言提问'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: widget.controller.turns.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final turn = widget.controller.turns[index];
                          return Card(
                            key: Key('assistant-turn-$index'),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '问：${turn.question}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    turn.answer.answer,
                                    key: Key('assistant-answer-$index'),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '意图 ${turn.answer.intent} · 模式 ${turn.answer.mode}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('assistant-input'),
                          controller: _input,
                          decoration: const InputDecoration(
                            hintText: '例如：现在有多少只在养？',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: asking ? null : (_) => _ask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        key: const Key('assistant-send'),
                        onPressed: asking ? null : () => _ask(),
                        child: asking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('发送'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
