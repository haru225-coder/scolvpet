part of 'i2_hamsters.dart';

class HamsterEditorPage extends StatefulWidget {
  const HamsterEditorPage({
    super.key,
    required this.controller,
    required this.speciesRuleVersionId,
    this.existing,
    this.onSaved,
  });

  final I2Controller controller;
  final String speciesRuleVersionId;
  final I2Hamster? existing;
  final VoidCallback? onSaved;

  @override
  State<HamsterEditorPage> createState() => _HamsterEditorPageState();
}

class _HamsterEditorPageState extends State<HamsterEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _notes;
  String _sex = 'unknown';
  PhenotypeCatalog? _catalog;
  String? _seriesCode;
  String? _phenotypeLabel;
  String? _catalogError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final value = widget.existing;
    _code = TextEditingController(text: value?.internalCode);
    _name = TextEditingController(text: value?.name);
    _notes = TextEditingController(text: value?.notes);
    _sex = value?.sex ?? 'unknown';
    _seriesCode = value?.coreSeriesCode;
    _phenotypeLabel = value?.corePhenotypeLabel;
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final table = await loadBundledPhenotypeTable();
      if (!mounted) return;
      setState(() {
        _catalog = table.catalog;
        _catalogError = null;
        // Seed defaults
        if (_seriesCode == null && table.catalog.series.isNotEmpty) {
          _seriesCode = table.catalog.series.first.code;
        }
        final ser = table.catalog.seriesByCode(_seriesCode ?? '');
        if (ser != null &&
            (_phenotypeLabel == null ||
                !ser.phenotypes.contains(_phenotypeLabel))) {
          _phenotypeLabel = ser.phenotypes.isNotEmpty
              ? ser.phenotypes.first
              : null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _catalogError = '表型选项暂时不可用，可先手填');
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? get _encodedVariety {
    final label = _phenotypeLabel?.trim();
    if (label == null || label.isEmpty) return null;
    final ser = _catalog?.seriesByCode(_seriesCode ?? '');
    // Core-table option → series|label; free text → bare label (allowed).
    if (_seriesCode != null && ser != null && ser.phenotypes.contains(label)) {
      return encodeCoreVarietyCode(_seriesCode!, label);
    }
    return label;
  }

  Future<void> _save() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      if (!widget.controller.canWrite) {
        await widget.controller.saveDraft(
          I2Draft(
            id: 'hamster-form-${DateTime.now().microsecondsSinceEpoch}',
            kind: 'hamster',
            payload: {
              'internal_code': _code.text.trim(),
              'name': _name.text.trim(),
              'variety_code': _encodedVariety,
            },
          ),
        );
        if (mounted) showIosMessage(context, '已保存到本地草稿，联网后可提交');
        return;
      }
      if (widget.existing == null) {
        await widget.controller.createHamster(
          I2HamsterDraft(
            internalCode: _code.text.trim(),
            name: _name.text.trim().isEmpty ? null : _name.text.trim(),
            speciesRuleVersionId: widget.speciesRuleVersionId,
            sex: _sex,
            sourceType: 'introduced',
            varietyCode: _encodedVariety,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          ),
        );
      } else {
        await widget.controller.updateHamster(
          widget.existing!.id,
          widget.existing!.version,
          I2HamsterUpdate(
            internalCode: _code.text.trim(),
            name: _name.text.trim(),
            varietyCode: _encodedVariety,
            sex: _sex,
            notes: _notes.text.trim(),
          ),
        );
      }
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
    appBar: AppBar(title: Text(widget.existing == null ? '编辑建档' : '编辑仓鼠')),
    body: Form(
      key: _formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const IosSectionHeader('基础信息'),
          IosGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextFormField(
                  controller: _code,
                  decoration: const InputDecoration(
                    labelText: '编号（方便查找） *',
                    filled: false,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? '请填写内部编号' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: '昵称',
                    filled: false,
                  ),
                ),
              ),
              if (_catalogError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    _catalogError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (_catalog != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: IosPickerField<String>(
                    key: Key('hamster-series-$_seriesCode'),
                    label: '表型系列',
                    selected: _catalog!.series.any((s) => s.code == _seriesCode)
                        ? _seriesCode
                        : (_catalog!.series.isNotEmpty
                              ? _catalog!.series.first.code
                              : null),
                    items: [
                      for (final s in _catalog!.series)
                        IosPickerItem(value: s.code, label: s.name),
                    ],
                    enabled: widget.controller.canWrite && !_busy,
                    onSelected: (value) {
                      if (value == null) return;
                      final ser = _catalog!.seriesByCode(value);
                      setState(() {
                        _seriesCode = value;
                        _phenotypeLabel =
                            ser != null && ser.phenotypes.isNotEmpty
                            ? ser.phenotypes.first
                            : null;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: OptionOrCustomField(
                    key: Key('hamster-phenotype-$_seriesCode'),
                    label: '表型（可选择或手填）',
                    options:
                        _catalog!.seriesByCode(_seriesCode ?? '')?.phenotypes ??
                        const <String>[],
                    value: _phenotypeLabel,
                    allowEmpty: true,
                    customHint: '自定义表型名称',
                    helperText: '列表外名称可以记录；需要推算时请选择列表中的名称',
                    enabled: widget.controller.canWrite && !_busy,
                    onChanged: (value) =>
                        setState(() => _phenotypeLabel = value),
                  ),
                ),
              ],
              // Catalog failed: still allow free-text phenotype.
              if (_catalog == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextFormField(
                    initialValue: _phenotypeLabel,
                    decoration: const InputDecoration(
                      labelText: '表型（可手填）',
                      filled: false,
                      helperText: '表型选项暂时不可用，可先手填',
                    ),
                    onChanged: (v) =>
                        setState(() => _phenotypeLabel = v.trim()),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: IosPickerField<String>(
                  label: '性别',
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
          const SizedBox(height: 20),
          const IosSectionHeader('备注'),
          IosGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    filled: false,
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          I2WriteButton(
            enabled: widget.controller.canWrite && !_busy,
            label: _busy ? '保存中…' : '保存',
            icon: CupertinoIcons.checkmark_circle_fill,
            onPressed: _save,
          ),
          if (widget.controller.offline)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '当前为离线只读，保存内容会进入本地草稿。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    ),
  );
}
