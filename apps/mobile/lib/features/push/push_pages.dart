import 'package:flutter/material.dart';

import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'push_controller.dart';
import 'push_models.dart';

/// Push device registry + test send (T-P1-07 PARTIAL: log provider).
class PushSettingsPage extends StatefulWidget {
  const PushSettingsPage({super.key, required this.controller});

  final PushController controller;

  @override
  State<PushSettingsPage> createState() => _PushSettingsPageState();
}

class _PushSettingsPageState extends State<PushSettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    widget.controller.refreshAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _snack(Future<bool> Function() action) async {
    final ok = await action();
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('服务端推送'),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(key: Key('push-tab-devices'), text: '设备'),
                Tab(key: Key('push-tab-messages'), text: '消息'),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('push-refresh'),
                onPressed: widget.controller.refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  '当前为 log 提供商：令牌入账并模拟送达。真实 APNs/FCM 需配置证书与 SDK。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('push-register'),
                        onPressed: () =>
                            _snack(() => widget.controller.registerThisDevice()),
                        icon: const Icon(Icons.phonelink_setup),
                        label: const Text('注册本机'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('push-send-test'),
                        onPressed: () =>
                            _snack(() => widget.controller.sendTestMessage()),
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('测试推送'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _DevicesTab(
                      state: widget.controller.devicesState,
                      onRetry: widget.controller.refreshDevices,
                      onDisable: (device) =>
                          _snack(() => widget.controller.disableDevice(device)),
                    ),
                    _MessagesTab(
                      state: widget.controller.messagesState,
                      onRetry: widget.controller.refreshMessages,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DevicesTab extends StatelessWidget {
  const _DevicesTab({
    required this.state,
    required this.onRetry,
    required this.onDisable,
  });

  final I2AsyncState<List<PushDevice>> state;
  final VoidCallback onRetry;
  final Future<void> Function(PushDevice device) onDisable;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<PushDevice>>(
      state: state,
      onRetry: onRetry,
      builder: (items) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                key: Key('push-device-${item.id}'),
                leading: Icon(
                  item.enabled ? Icons.notifications_active : Icons.notifications_off,
                ),
                title: Text('${item.platformLabel} · ${item.provider}'),
                subtitle: Text(
                  [
                    item.tokenPreview,
                    if (item.deviceName != null) item.deviceName!,
                    item.enabled ? '启用' : '已停用',
                  ].join(' · '),
                ),
                trailing: item.enabled
                    ? TextButton(
                        key: Key('push-disable-${item.id}'),
                        onPressed: () => onDisable(item),
                        child: const Text('停用'),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab({required this.state, required this.onRetry});

  final I2AsyncState<List<PushMessage>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<PushMessage>>(
      state: state,
      onRetry: onRetry,
      builder: (items) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                key: Key('push-message-${item.id}'),
                leading: Icon(
                  item.isSent ? Icons.mark_email_read_outlined : Icons.error_outline,
                  color: item.isSent ? Colors.green : Colors.orange,
                ),
                title: Text(item.title),
                subtitle: Text(
                  [
                    item.statusLabel,
                    item.body,
                    if (item.lastError != null) item.lastError!,
                  ].join(' · '),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
