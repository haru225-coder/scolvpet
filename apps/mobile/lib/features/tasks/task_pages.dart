import 'package:flutter/material.dart';

import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'task_controller.dart';
import 'task_models.dart';

/// Open care tasks list with one-tap complete (T-P0-05).
class TaskListPage extends StatefulWidget {
  const TaskListPage({
    super.key,
    required this.controller,
    this.canWrite = true,
    this.offline = false,
  });

  final TaskController controller;
  final bool canWrite;
  final bool offline;

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.refresh();
  }

  Future<void> _complete(CareTaskItem task) async {
    final ok = await widget.controller.complete(task);
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (ok) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('任务'),
            actions: [
              IconButton(
                key: const Key('task-refresh'),
                tooltip: '刷新',
                onPressed: busy ? null : widget.controller.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              if (widget.offline)
                const I2OfflineBanner(offline: true, lastSyncLabel: null),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _StatChip(
                      label: '待办 ${widget.controller.openCount}',
                      color: const Color(0xff43635f),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: '逾期 ${widget.controller.overdueCount}',
                      color: widget.controller.overdueCount == 0
                          ? const Color(0xff6c7774)
                          : const Color(0xffb6534a),
                    ),
                    const Spacer(),
                    if (widget.controller.notificationsReady)
                      const Text(
                        '本地通知已同步',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff6c7774),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: I2AsyncStateView<List<CareTaskItem>>(
                  state: widget.controller.listState,
                  onRetry: widget.controller.refresh,
                  builder: (tasks) {
                    if (tasks.isEmpty) {
                      return const I2StateMessage(
                        icon: Icons.task_alt,
                        message: '暂无任务',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: widget.controller.refresh,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final overdue = task.isOverdue;
                          final open = task.isOpen;
                          return Card(
                            key: Key('task-card-${task.id}'),
                            color: overdue
                                ? const Color(0xffffe8e5)
                                : open
                                ? null
                                : const Color(0xffeef3f1),
                            child: ListTile(
                              leading: Icon(
                                open
                                    ? Icons.radio_button_unchecked
                                    : Icons.check_circle,
                                color: open
                                    ? (overdue
                                          ? const Color(0xffb6534a)
                                          : const Color(0xffc77852))
                                    : Colors.green,
                              ),
                              title: Text(
                                task.displayTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: open
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: Text(
                                '${taskTypeLabel(task.taskType)} · '
                                '${taskPriorityLabel(task.priority)} · '
                                '${taskStateLabel(task.state)}\n'
                                '计划 ${_fmt(task.scheduledAt)}'
                                '${overdue ? ' · 已逾期' : ''}',
                              ),
                              isThreeLine: true,
                              trailing: open && widget.canWrite
                                  ? TextButton(
                                      key: Key('task-complete-${task.id}'),
                                      onPressed: busy
                                          ? null
                                          : () => _complete(task),
                                      child: const Text('完成'),
                                    )
                                  : Text(
                                      taskStateLabel(task.state),
                                      style: const TextStyle(
                                        color: Color(0xff6c7774),
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(DateTime value) {
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$mi';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
