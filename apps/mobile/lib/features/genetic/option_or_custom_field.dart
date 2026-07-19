import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/widgets/ios_widgets.dart';

/// Sentinel value meaning "user chose free-text custom entry".
const kOptionCustomSentinel = '__custom__';

/// Hybrid control: pick from [options], or switch to free-text.
///
/// - Primary path: select a catalog option (core table, etc.)
/// - Escape hatch: "其他（手填）" reveals a text field
class OptionOrCustomField extends StatefulWidget {
  const OptionOrCustomField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.customHint = '输入自定义名称',
    this.allowEmpty = true,
    this.helperText,
    this.enabled = true,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String customHint;
  final bool allowEmpty;
  final String? helperText;
  final bool enabled;

  @override
  State<OptionOrCustomField> createState() => _OptionOrCustomFieldState();
}

class _OptionOrCustomFieldState extends State<OptionOrCustomField> {
  late final TextEditingController _customCtrl;
  bool _customMode = false;

  @override
  void initState() {
    super.initState();
    final v = widget.value?.trim();
    final inOptions = v != null && v.isNotEmpty && widget.options.contains(v);
    _customMode = v != null && v.isNotEmpty && !inOptions;
    _customCtrl = TextEditingController(text: _customMode ? v : '');
  }

  @override
  void didUpdateWidget(covariant OptionOrCustomField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final v = widget.value?.trim();
    final inOptions = v != null && v.isNotEmpty && widget.options.contains(v);
    if (v != oldWidget.value) {
      // 选中“其他（手填）”后，父级会先收到 null；此时仍要保留手填状态，
      // 否则组件会立刻回到选择模式，输入框无法打开。
      if (!_customMode || inOptions) {
        _customMode = v != null && v.isNotEmpty && !inOptions;
      }
      if (_customMode && v != null && _customCtrl.text != v) {
        _customCtrl.text = v;
      }
    }
    // Options list changed while holding a value that now matches catalog.
    if (inOptions && _customMode) {
      _customMode = false;
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  String? get _pickerSelected {
    if (_customMode) return kOptionCustomSentinel;
    final v = widget.value?.trim();
    if (v != null && widget.options.contains(v)) return v;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final items = <IosPickerItem<String>>[
      if (widget.allowEmpty) const IosPickerItem(value: '', label: '（未选）'),
      for (final o in widget.options) IosPickerItem(value: o, label: o),
      const IosPickerItem(value: kOptionCustomSentinel, label: '其他（手填）…'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IosPickerField<String>(
          label: widget.label,
          items: items,
          selected: _pickerSelected ?? (widget.allowEmpty ? '' : null),
          enabled: widget.enabled,
          onSelected: (v) {
            if (v == null || v.isEmpty) {
              setState(() => _customMode = false);
              widget.onChanged(null);
              return;
            }
            if (v == kOptionCustomSentinel) {
              setState(() => _customMode = true);
              final text = _customCtrl.text.trim();
              if (text.isNotEmpty) widget.onChanged(text);
              return;
            }
            setState(() => _customMode = false);
            widget.onChanged(v);
          },
        ),
        if (_customMode) ...[
          const SizedBox(height: 8),
          TextField(
            key: Key('custom-${widget.label}'),
            controller: _customCtrl,
            enabled: widget.enabled,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: widget.customHint,
              border: const OutlineInputBorder(),
              isDense: true,
              prefixIcon: const Icon(CupertinoIcons.pencil, size: 18),
              helperText: widget.helperText ?? '可手填；核心表内名称优先用于推算，自定义名主要作档案标注',
            ),
            onChanged: (text) {
              final t = text.trim();
              widget.onChanged(t.isEmpty ? null : t);
            },
          ),
        ],
      ],
    );
  }
}
