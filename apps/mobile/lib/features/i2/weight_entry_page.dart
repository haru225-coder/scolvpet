part of 'i2_hamsters.dart';

class WeightEntryPage extends StatefulWidget {
  const WeightEntryPage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.onSaved,
    this.correcting,
  });

  final I2Controller controller;
  final String hamsterId;
  final VoidCallback? onSaved;

  /// When set, saving supersedes this reading instead of appending a new one.
  /// The original is kept — corrections are an audit chain, not an edit.
  final I2WeightRecord? correcting;

  @override
  State<WeightEntryPage> createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends State<WeightEntryPage> {
  final _weight = TextEditingController();
  final _notes = TextEditingController();
  bool _busy = false;

  bool get _isCorrection => widget.correcting != null;

  @override
  void initState() {
    super.initState();
    final original = widget.correcting;
    if (original != null) {
      // Prefilling the wrong value is deliberate: most corrections are a typo
      // away from the original, and the operator can see what they are changing.
      _weight.text = '${original.weightG}';
      _notes.text = original.notes ?? '';
    }
  }

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
    final original = widget.correcting;
    String? reason;
    if (original != null) {
      // The API answers 422 when an id arrives without a reason, so ask first
      // and never send a half-formed correction.
      reason = await showCorrectionReasonSheet(
        context: context,
        title: '纠正 ${original.weightG} g 的记录',
        keyPrefix: 'weight-correction',
        hint: '说明这条记录为什么不对，原记录会保留在审计链里。',
        placeholder: '纠错原因',
        confirmLabel: '确认纠正',
      );
      if (reason == null || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await widget.controller.createWeight(
        I2WeightDraft(
          hamsterId: widget.hamsterId,
          weightG: value,
          recordedAt: DateTime.now(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          correctsWeightRecordId: original?.id,
          correctionReason: reason,
        ),
      );
      if (mounted &&
          widget.controller.actionState.status == I2AsyncStatus.data) {
        final latest = widget.controller.weightState.data;
        final alert =
            latest != null &&
            latest.isNotEmpty &&
            latest.first.alertFlags.isNotEmpty;
        final saved = _isCorrection ? '已纠正为 $value g' : '已保存 $value g';
        showIosMessage(context, alert ? '$saved（检测到体重异常）' : saved);
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
        appBar: AppBar(title: Text(_isCorrection ? '纠正体重' : '录入体重')),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            I2OfflineBanner(
              offline: widget.controller.offline,
              lastSyncLabel: widget.controller.lastSyncLabel,
            ),
            if (_isCorrection)
              Padding(
                key: const Key('weight-correction-banner'),
                padding: const EdgeInsets.only(bottom: 12),
                child: IosBanner(
                  icon: CupertinoIcons.arrow_uturn_left,
                  color: IosColors.systemOrange,
                  text:
                      '正在纠正 ${i2DateTimeLabel(widget.correcting!.recordedAt)} 的 '
                      '${widget.correcting!.weightG} g。原记录会保留，新记录指向它。',
                ),
              ),
            Text(
              _isCorrection
                  ? '单位：克（g）。保存前需要填写纠错原因，会写入审计链。'
                  : '单位：克（g）。输入后点保存；服务端会快照上次体重差，客户端会标记掉重或过低。',
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
              label: busy
                  ? '保存中…'
                  : (_isCorrection ? '纠正体重' : '保存体重'),
              icon: CupertinoIcons.checkmark_circle_fill,
              onPressed: _save,
            ),
          ],
        ),
      );
    },
  );
}
