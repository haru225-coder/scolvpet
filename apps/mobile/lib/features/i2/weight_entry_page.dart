part of 'i2_hamsters.dart';

class WeightEntryPage extends StatefulWidget {
  const WeightEntryPage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.onSaved,
  });

  final I2Controller controller;
  final String hamsterId;
  final VoidCallback? onSaved;

  @override
  State<WeightEntryPage> createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends State<WeightEntryPage> {
  final _weight = TextEditingController();
  final _notes = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _weight.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final normalized = _weight.text.trim().replaceAll(',', '.');
    final value = num.tryParse(normalized);
    if (value == null || value <= 0) {
      showIosMessage(context, '请输入大于 0 的克值');
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.controller.createWeight(
        I2WeightDraft(
          hamsterId: widget.hamsterId,
          weightG: value,
          recordedAt: DateTime.now(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      );
      if (mounted &&
          widget.controller.actionState.status == I2AsyncStatus.data) {
        final latest = widget.controller.weightState.data;
        final alert =
            latest != null &&
            latest.isNotEmpty &&
            latest.first.alertFlags.isNotEmpty;
        showIosMessage(
          context,
          alert ? '已保存 $value g（检测到体重异常）' : '已保存 $value g',
        );
        widget.onSaved?.call();
      } else if (mounted && widget.controller.actionState.message != null) {
        showIosMessage(context, widget.controller.actionState.message!);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final busy =
          _busy ||
          widget.controller.actionState.status == I2AsyncStatus.loading;
      return Scaffold(
        appBar: AppBar(title: const Text('录入体重')),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            I2OfflineBanner(
              offline: widget.controller.offline,
              lastSyncLabel: widget.controller.lastSyncLabel,
            ),
            Text(
              '单位：克（g）。输入后点保存；服务端会快照上次体重差，客户端会标记掉重或过低。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const IosSectionHeader('体重'),
            IosGroupedSection(
              margin: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _weight,
                    enabled: widget.controller.canWrite && !busy,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '体重（g） *',
                      helperText: '必须 > 0',
                      filled: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: TextField(
                    controller: _notes,
                    enabled: widget.controller.canWrite && !busy,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            I2WriteButton(
              enabled: widget.controller.canWrite && !busy,
              label: busy ? '保存中…' : '保存体重',
              icon: CupertinoIcons.checkmark_circle_fill,
              onPressed: _save,
            ),
          ],
        ),
      );
    },
  );
}
