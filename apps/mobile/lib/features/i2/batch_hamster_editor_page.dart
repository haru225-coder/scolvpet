part of 'i2_hamsters.dart';

class BatchHamsterEditorPage extends StatefulWidget {
  const BatchHamsterEditorPage({
    super.key,
    required this.controller,
    required this.speciesRuleVersionId,
    this.onSaved,
  });

  final I2Controller controller;
  final String speciesRuleVersionId;
  final VoidCallback? onSaved;

  @override
  State<BatchHamsterEditorPage> createState() => _BatchHamsterEditorPageState();
}

class _BatchHamsterEditorPageState extends State<BatchHamsterEditorPage> {
  final _codes = TextEditingController();
  final _namePrefix = TextEditingController();
  String _sex = 'unknown';
  bool _busy = false;

  @override
  void dispose() {
    _codes.dispose();
    _namePrefix.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final codes = _codes.text
        .split(RegExp(r'[\s,，;；]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (codes.isEmpty) return;
    setState(() => _busy = true);
    try {
      await widget.controller.createHamsters(
        codes
            .map(
              (code) => I2HamsterDraft(
                internalCode: code,
                name: _namePrefix.text.trim().isEmpty
                    ? null
                    : '${_namePrefix.text.trim()}$code',
                speciesRuleVersionId: widget.speciesRuleVersionId,
                sex: _sex,
                sourceType: 'born_here',
              ),
            )
            .toList(),
      );
      if (mounted &&
          widget.controller.actionState.status == I2AsyncStatus.data) {
        showIosMessage(context, '仓鼠档案已保存');
        widget.onSaved?.call();
      } else if (mounted && widget.controller.actionState.message != null) {
        showIosMessage(context, widget.controller.actionState.message!);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('批量建档')),
    body: ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const IosSectionHeader('编号'),
        IosGroupedSection(
          margin: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _codes,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: '内部编号 *',
                  hintText: '可用换行、逗号或分号分隔',
                  filled: false,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const IosSectionHeader('公共属性'),
        IosGroupedSection(
          margin: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _namePrefix,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: '公共昵称前缀（可选）',
                  filled: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: IosPickerField<String>(
                label: '公共性别',
                selected: _sex,
                items: const [
                  IosPickerItem(value: 'unknown', label: '待定'),
                  IosPickerItem(value: 'male', label: '公'),
                  IosPickerItem(value: 'female', label: '母'),
                ],
                enabled: widget.controller.canWrite && !_busy,
                onSelected: (value) {
                  if (value != null) setState(() => _sex = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        I2WriteButton(
          enabled: widget.controller.canWrite && !_busy,
          label: _busy ? '保存中…' : '逐只确认并提交',
          icon: CupertinoIcons.list_bullet_below_rectangle,
          onPressed: _save,
        ),
      ],
    ),
  );
}
