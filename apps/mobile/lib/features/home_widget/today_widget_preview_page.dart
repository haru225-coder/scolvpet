import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../shell/today_care_queue.dart';
import '../tasks/task_controller.dart';
import 'today_widget_publisher.dart';
import 'today_widget_snapshot.dart';

/// In-app preview of the home-screen "今日待办" widget.
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
    // iOS Widget Extension is scaffold-only (not in Xcode target). Do not claim
    // desktop success on iOS; Android still has a real AppWidget path.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'iOS 桌面组件尚未开放，请使用应用内今日待办';
      });
      return;
    }
    await widget.taskController.refresh();
    final tasks = widget.taskController.listState.data ?? const [];
    final queue = buildTodayCareQueue(tasks: tasks);
    final snapshot = TodayWidgetSnapshot.fromCareQueue(queue);
    await widget.publisher.publish(snapshot);
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
      _message = '桌面待办已更新';
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
            icon: const Icon(CupertinoIcons.arrow_clockwise),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            '桌面预览',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '同步后，桌面上的「今日待办」会显示最新安排。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
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
            icon: const Icon(CupertinoIcons.square_grid_2x2),
            label: const Text('更新桌面待办'),
          ),
          const SizedBox(height: 12),
          if (snapshot != null) ...[
            Text('最近同步', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              _updatedAtLabel(snapshot.updatedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

String _updatedAtLabel(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  if (local.year == now.year &&
      local.month == now.month &&
      local.day == now.day) {
    return '今天 $time';
  }
  return '${local.month}月${local.day}日 $time';
}

class _WidgetCard extends StatelessWidget {
  const _WidgetCard({required this.snapshot});

  final TodayWidgetSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff2b3634),
        borderRadius: BorderRadius.all(
          Radius.circular(IosMetrics.continuousRadius),
        ),
      ),
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
                    color: const Color(0xffD98B55),
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
              style: const TextStyle(color: Color(0xffe7eeec), height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
