import 'package:flutter/material.dart';

import '../shell/today_care_queue.dart';
import '../tasks/task_controller.dart';
import 'today_widget_publisher.dart';
import 'today_widget_snapshot.dart';

/// In-app preview of the home-screen "今日待办" widget (T-P1-05).
class TodayWidgetPreviewPage extends StatefulWidget {
  const TodayWidgetPreviewPage({
    super.key,
    required this.taskController,
    required this.publisher,
  });

  final TaskController taskController;
  final TodayWidgetPublisher publisher;

  @override
  State<TodayWidgetPreviewPage> createState() => _TodayWidgetPreviewPageState();
}

class _TodayWidgetPreviewPageState extends State<TodayWidgetPreviewPage> {
  TodayWidgetSnapshot? _snapshot;
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final last = await widget.publisher.loadLast();
    if (!mounted) return;
    setState(() {
      _snapshot = last;
      _loading = false;
    });
  }

  Future<void> _syncNow() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    await widget.taskController.refresh();
    final tasks = widget.taskController.listState.data ?? const [];
    final queue = buildTodayCareQueue(tasks: tasks);
    final snapshot = TodayWidgetSnapshot.fromCareQueue(queue);
    await widget.publisher.publish(snapshot);
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
      _message = '已同步到桌面组件数据';
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日待办组件'),
        actions: [
          IconButton(
            key: const Key('today-widget-reload'),
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            '桌面小组件预览',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Android 可长按桌面添加「今日待办」。iOS WidgetKit 扩展脚手架见 ios/TodayTasksWidget。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ))
          else
            _WidgetCard(snapshot: snapshot ?? TodayWidgetSnapshot.empty()),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(
              _message!,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('today-widget-sync'),
            onPressed: _loading ? null : _syncNow,
            icon: const Icon(Icons.widgets_outlined),
            label: const Text('从任务同步到组件'),
          ),
          const SizedBox(height: 12),
          if (snapshot != null) ...[
            Text(
              '最近同步',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              snapshot.updatedAt.toLocal().toIso8601String(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            SelectableText(
              snapshot.toJsonString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WidgetCard extends StatelessWidget {
  const _WidgetCard({required this.snapshot});

  final TodayWidgetSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff2b3634),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  snapshot.headline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  key: const Key('today-widget-count-chip'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffc77852),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    snapshot.countLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              snapshot.bodyText,
              key: const Key('today-widget-body'),
              style: const TextStyle(
                color: Color(0xffe7eeec),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
