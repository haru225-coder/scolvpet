import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import 'i2_controller.dart';
import 'i2_models.dart';
import 'i2_widgets.dart';

class I2CsvTable {
  const I2CsvTable({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;
}

class I2CsvParseException implements Exception {
  const I2CsvParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class I2CsvParser {
  const I2CsvParser._();

  static I2CsvTable parse(String input) {
    if (input.trim().isEmpty) {
      throw const I2CsvParseException('CSV 内容为空，请粘贴包含表头和数据的内容');
    }
    final rows = <List<String>>[];
    final currentRow = <String>[];
    final currentCell = StringBuffer();
    var quoted = false;
    var closedQuote = false;
    var index = 0;
    var line = 1;
    var quotedAtLine = 1;

    void finishCell() {
      currentRow.add(currentCell.toString());
      currentCell.clear();
      closedQuote = false;
    }

    void finishRow() {
      finishCell();
      if (currentRow.any((value) => value.trim().isNotEmpty)) {
        rows.add(List<String>.from(currentRow));
      }
      currentRow.clear();
    }

    while (index < input.length) {
      final char = input[index];
      if (char == '"') {
        if (quoted && index + 1 < input.length && input[index + 1] == '"') {
          currentCell.write('"');
          index += 2;
          continue;
        }
        if (quoted) {
          quoted = false;
          closedQuote = true;
        } else if (currentCell.toString().trim().isEmpty && !closedQuote) {
          currentCell.clear();
          quoted = true;
          quotedAtLine = line;
        } else {
          throw I2CsvParseException('第 $line 行存在位置不正确的引号');
        }
      } else if (char == ',' && !quoted) {
        finishCell();
      } else if ((char == '\n' || char == '\r') && !quoted) {
        finishRow();
        if (char == '\r' &&
            index + 1 < input.length &&
            input[index + 1] == '\n') {
          index++;
        }
        line++;
      } else if (closedQuote && !quoted) {
        if (char.trim().isNotEmpty) {
          throw I2CsvParseException('第 $line 行引号结束后存在多余字符');
        }
      } else {
        if (char == '\r' &&
            index + 1 < input.length &&
            input[index + 1] == '\n') {
          currentCell.write('\n');
          index++;
          line++;
        } else {
          currentCell.write(char);
          if (char == '\n' || char == '\r') line++;
        }
      }
      index++;
    }
    if (quoted) {
      throw I2CsvParseException('第 $quotedAtLine 行的引号未闭合');
    }
    if (currentCell.isNotEmpty || currentRow.isNotEmpty) finishRow();
    if (rows.isEmpty) {
      throw const I2CsvParseException('CSV 内容为空，请保留第一行栏目名称');
    }
    final headers = rows.first
        .map((value) => value.trim().replaceFirst('\ufeff', ''))
        .toList();
    for (var i = 0; i < headers.length; i++) {
      if (headers[i].isEmpty) {
        throw I2CsvParseException('第 ${i + 1} 列缺少栏目名称');
      }
    }
    final normalizedHeaders = <String>{};
    for (final header in headers) {
      if (!normalizedHeaders.add(header.toLowerCase())) {
        throw I2CsvParseException('栏目“$header”重复，请为每一列使用不同名称');
      }
    }
    if (rows.length == 1) {
      throw const I2CsvParseException('CSV 只有表头，没有可导入的数据');
    }
    final data = <List<String>>[];
    for (var rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      if (row.length != headers.length) {
        throw I2CsvParseException(
          '第 ${rowIndex + 1} 行有 ${row.length} 列，表头有 ${headers.length} 列',
        );
      }
      data.add(row.map((value) => value.trim()).toList());
    }
    return I2CsvTable(headers: headers, rows: data);
  }
}

class I2ImportPage extends StatefulWidget {
  const I2ImportPage({super.key, required this.controller, this.onPickCsv});

  final I2Controller controller;
  final Future<I2CsvUpload> Function()? onPickCsv;

  @override
  State<I2ImportPage> createState() => _I2ImportPageState();
}

class _I2ImportPageState extends State<I2ImportPage> {
  static const _maxUploadBytes = 100 * 1024 * 1024;
  static const _skipField = '__skip__';

  final _fileName = TextEditingController(text: 'hamsters.csv');
  final _csvText = TextEditingController();
  String _template = 'hamster';
  I2CsvTable? _table;
  final Map<String, String> _mapping = <String, String>{};
  String? _computedSha256;
  String? _localError;
  bool _localBusy = false;

  @override
  void dispose() {
    _fileName.dispose();
    _csvText.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    if (_localBusy || _controllerBusy) return;
    setState(() {
      _localBusy = true;
      _localError = null;
    });
    try {
      I2CsvUpload upload;
      if (widget.onPickCsv != null) {
        final picked = await widget.onPickCsv!();
        if (picked.bytes.isEmpty) {
          throw const I2CsvParseException('所选 CSV 文件为空');
        }
        if (picked.bytes.length > _maxUploadBytes) {
          throw const I2CsvParseException('CSV 文件超过 100 MB，请拆分后再导入');
        }
        final digest = sha256.convert(picked.bytes).toString();
        final pickedTemplate = _importFields.containsKey(picked.template)
            ? picked.template
            : _template;
        upload = I2CsvUpload(
          fileName: _normalizedFileName(picked.fileName),
          bytes: picked.bytes,
          sha256: digest,
          template: pickedTemplate,
        );
        if (mounted) {
          setState(() {
            _template = pickedTemplate;
            _computedSha256 = digest;
          });
        }
      } else {
        final text = _csvText.text;
        final table = I2CsvParser.parse(text);
        final bytes = utf8.encode(text);
        if (bytes.length > _maxUploadBytes) {
          throw const I2CsvParseException('CSV 内容超过 100 MB，请拆分后再导入');
        }
        final digest = sha256.convert(bytes).toString();
        upload = I2CsvUpload(
          fileName: _normalizedFileName(_fileName.text),
          bytes: bytes,
          sha256: digest,
          template: _template,
        );
        if (mounted) {
          setState(() {
            _table = table;
            _computedSha256 = digest;
          });
        }
      }
      await widget.controller.uploadCsv(upload);
    } on I2CsvParseException catch (error) {
      if (mounted) setState(() => _localError = error.message);
    } on FormatException {
      if (mounted) setState(() => _localError = 'CSV 文件不是有效的 UTF-8 文本');
    } catch (error) {
      if (mounted) {
        setState(() => _localError = '读取 CSV 失败，请重新选择或检查文件内容');
      }
    } finally {
      if (mounted) {
        setState(() => _localBusy = false);
      }
    }
  }

  bool get _controllerBusy =>
      widget.controller.actionState.status == I2AsyncStatus.loading;

  String _normalizedFileName(String value) {
    final trimmed = value.trim().isEmpty ? 'import.csv' : value.trim();
    return trimmed.toLowerCase().endsWith('.csv') ? trimmed : '$trimmed.csv';
  }

  void _onCsvChanged(String value) {
    final bytes = utf8.encode(value);
    setState(() {
      _table = null;
      _localError = null;
      _computedSha256 = value.trim().isEmpty
          ? null
          : sha256.convert(bytes).toString();
    });
  }

  String _selectedTarget(I2ImportJob job, String source) {
    if (_mapping.containsKey(source)) return _mapping[source]!;
    final target = job.mapping[source];
    return _importFields[_template]!.any((field) => field.key == target)
        ? target!
        : _skipField;
  }

  List<I2ImportMapping> _selectedMappings(I2ImportJob job) => job.sourceColumns
      .map((source) => (source, _selectedTarget(job, source)))
      .where((entry) => entry.$2 != _skipField)
      .map(
        (entry) =>
            I2ImportMapping(sourceColumn: entry.$1, targetField: entry.$2),
      )
      .toList();

  Future<void> _pickMapping(I2ImportJob job, String source) async {
    if (_localBusy || _controllerBusy) return;
    final selected = await showIosActionSheet<String>(
      context: context,
      title: '“$source”导入到',
      items: [
        const IosActionItem(value: _skipField, label: '不导入此列'),
        for (final field in _importFields[_template]!)
          IosActionItem(
            value: field.key,
            label: field.required ? '${field.label}（必需）' : field.label,
          ),
      ],
    );
    if (selected == null || !mounted) return;
    setState(() {
      _mapping[source] = selected;
      _localError = null;
    });
  }

  Future<void> _saveMapping(I2ImportJob job) async {
    if (_localBusy || _controllerBusy) return;
    final mappings = _selectedMappings(job);
    final selectedTargets = mappings.map((mapping) => mapping.targetField);
    final duplicates = <String>{};
    final seen = <String>{};
    for (final target in selectedTargets) {
      if (!seen.add(target)) duplicates.add(target);
    }
    if (duplicates.isNotEmpty) {
      final labels = duplicates.map(_targetLabel).join('、');
      setState(() => _localError = '$labels 只能各映射一次，请调整重复栏目');
      return;
    }
    final missing = _importFields[_template]!
        .where((field) => field.required && !seen.contains(field.key))
        .map((field) => field.label)
        .toList();
    if (missing.isNotEmpty) {
      setState(() => _localError = '请先映射必需栏目：${missing.join('、')}');
      return;
    }
    if (mappings.isEmpty) {
      setState(() => _localError = '请至少选择一个需要导入的栏目');
      return;
    }
    setState(() {
      _localBusy = true;
      _localError = null;
    });
    try {
      await widget.controller.setImportMapping(mappings);
    } finally {
      if (mounted) setState(() => _localBusy = false);
    }
  }

  Future<void> _runControllerAction(Future<void> Function() action) async {
    if (_localBusy || _controllerBusy) return;
    setState(() => _localBusy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _localBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final job = controller.importJob;
      final busy = _localBusy || _controllerBusy;
      return Scaffold(
        appBar: AppBar(title: const Text('导入数据')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            I2OfflineBanner(
              offline: controller.offline,
              lastSyncLabel: controller.lastSyncLabel,
            ),
            _stageHeader(controller.importStage),
            if (controller.importStage == I2ImportStage.idle ||
                job == null) ...[
              IosPickerField<String>(
                label: '导入内容',
                selected: _template,
                items: const [
                  IosPickerItem(value: 'hamster', label: '仓鼠'),
                  IosPickerItem(value: 'enclosure', label: '笼盒'),
                  IosPickerItem(value: 'weight', label: '体重'),
                ],
                enabled: controller.canWrite,
                onSelected: (value) {
                  if (value != null) {
                    setState(() {
                      _template = value;
                      _mapping.clear();
                      _localError = null;
                    });
                  }
                },
              ),
              if (widget.onPickCsv == null) ...[
                TextField(
                  controller: _fileName,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '文件名称',
                    helperText: '未填写 .csv 后缀时会自动补齐',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('i2-import-csv-input'),
                  controller: _csvText,
                  maxLines: 8,
                  textInputAction: TextInputAction.newline,
                  onChanged: _onCsvChanged,
                  decoration: const InputDecoration(
                    labelText: '粘贴 CSV 内容',
                    hintText: 'internal_code,name\nH-001,雪团',
                    helperText: '第一行保留栏目名称，含逗号的内容请使用英文双引号包住',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: IosBanner(
                    icon: CupertinoIcons.doc,
                    color: ScolvPalette.of(context).accent,
                    text: '选择 CSV 文件后会自动计算校验值，不需要手工填写。',
                  ),
                ),
              if (_computedSha256 != null)
                Padding(
                  key: const Key('i2-import-sha256'),
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHA-256 已自动生成',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _computedSha256!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ScolvPalette.of(context).secondaryLabel,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              if (_table != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '已识别 ${_table!.headers.length} 个栏目、${_table!.rows.length} 条数据',
                  ),
                ),
              const SizedBox(height: 16),
              I2WriteButton(
                key: const Key('i2-import-upload'),
                enabled: controller.canWrite,
                label: widget.onPickCsv == null ? '读取数据' : '选择文件',
                icon: CupertinoIcons.arrow_up_doc,
                onPressed: busy ? null : _upload,
              ),
            ],
            if (job != null &&
                controller.importStage == I2ImportStage.mapping) ...[
              _mappingCard(job, busy: busy || !controller.canWrite),
              const SizedBox(height: 12),
              I2WriteButton(
                enabled: controller.canWrite,
                label: '继续检查',
                icon: CupertinoIcons.arrow_right_arrow_left,
                onPressed: busy ? null : () => _saveMapping(job),
              ),
            ],
            if (job != null &&
                controller.importStage == I2ImportStage.preflight) ...[
              _jobSummary(job),
              const SizedBox(height: 12),
              I2WriteButton(
                enabled: controller.canWrite,
                label: '检查数据',
                icon: CupertinoIcons.checkmark_shield,
                onPressed: busy
                    ? null
                    : () => _runControllerAction(controller.preflightImport),
              ),
            ],
            if (job != null &&
                controller.importStage == I2ImportStage.conflictPreview) ...[
              _jobSummary(job),
              const SizedBox(height: 8),
              _conflictPreview(job),
              const SizedBox(height: 12),
              I2WriteButton(
                enabled: controller.canWrite && !job.hasBlockingIssues,
                label: '确认导入',
                icon: CupertinoIcons.checkmark_circle_fill,
                onPressed: busy
                    ? null
                    : () => _runControllerAction(controller.commitImport),
              ),
            ],
            if (controller.importStage == I2ImportStage.committing && busy)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CupertinoActivityIndicator(radius: 12)),
              ),
            if (controller.importStage == I2ImportStage.committing &&
                !busy &&
                (controller.actionState.status == I2AsyncStatus.error ||
                    controller.actionState.status == I2AsyncStatus.conflict))
              _resultRecovery(controller.actionState.message),
            if (job != null && controller.importStage == I2ImportStage.report)
              _reportCard(job, controller.importRows, busy: busy),
            if (_localError != null)
              Padding(
                key: const Key('i2-import-local-error'),
                padding: const EdgeInsets.only(top: 16),
                child: IosBanner(
                  icon: CupertinoIcons.exclamationmark_triangle,
                  text: _localError!,
                  color: IosColors.systemRed,
                ),
              ),
            if ((controller.actionState.status == I2AsyncStatus.error ||
                    controller.actionState.status == I2AsyncStatus.conflict) &&
                controller.importStage != I2ImportStage.committing)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: I2StateMessage(
                  icon: controller.actionState.status == I2AsyncStatus.conflict
                      ? CupertinoIcons.exclamationmark_triangle
                      : CupertinoIcons.exclamationmark_circle,
                  message: controller.actionState.message ?? '请求未完成，请稍后重试',
                  tone: controller.actionState.status == I2AsyncStatus.conflict
                      ? IosColors.systemOrange
                      : IosColors.systemRed,
                  actionLabel: controller.importStage == I2ImportStage.report
                      ? '重新获取结果'
                      : null,
                  onRetry: controller.importStage == I2ImportStage.report
                      ? () => _runControllerAction(controller.retryImportRows)
                      : null,
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _stageHeader(I2ImportStage stage) => Container(
    decoration: BoxDecoration(
      color: ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in const [
            ('选择文件', 0),
            ('检查数据', 1),
            ('确认导入', 2),
            ('导入结果', 3),
          ])
            Chip(
              avatar: Icon(
                item.$2 == _stageStep(stage)
                    ? CupertinoIcons.smallcircle_fill_circle
                    : CupertinoIcons.circle,
                size: 16,
              ),
              label: Text(item.$1),
            ),
        ],
      ),
    ),
  );

  Widget _mappingCard(I2ImportJob job, {required bool busy}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '确认栏目对应关系',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 4),
      Text(
        '只显示当前模板支持的目标栏目；不需要的源列可以选择“不导入”。',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: ScolvPalette.of(context).secondaryLabel,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 10),
      IosGroupedSection(
        margin: EdgeInsets.zero,
        children: [
          for (final source in job.sourceColumns)
            IosListTile(
              key: Key('i2-import-mapping-$source'),
              title: source,
              subtitle: '导入到：${_targetLabel(_selectedTarget(job, source))}',
              onTap: busy ? null : () => _pickMapping(job, source),
            ),
        ],
      ),
    ],
  );

  Widget _jobSummary(I2ImportJob job) => Container(
    decoration: BoxDecoration(
      color: ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
    ),
    child: Column(
      children: [
        IosListTile(title: '数据检查', subtitle: '已完成 ${job.progressPercent}%'),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text('共 ${job.totalRows} 条')),
            Chip(label: Text('可导入 ${job.validRows} 条')),
            Chip(label: Text('需留意 ${job.warningRows} 条')),
            Chip(label: Text('需修改 ${job.invalidRows} 条')),
          ],
        ),
        const SizedBox(height: 8),
      ],
    ),
  );

  Widget _conflictPreview(I2ImportJob job) => Container(
    decoration: BoxDecoration(
      color: job.hasBlockingIssues
          ? Colors.orange.withValues(alpha: .08)
          : ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        job.hasBlockingIssues
            ? '有些数据需要修改。调整文件后重新选择，再继续导入。'
            : '检查完成，${job.validRows} 条数据可以导入。',
      ),
    ),
  );

  Widget _resultRecovery(String? message) => Padding(
    key: const Key('i2-import-results-retry'),
    padding: const EdgeInsets.only(top: 16),
    child: Container(
      decoration: BoxDecoration(
        color: IosColors.systemOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(
          color: IosColors.systemOrange.withValues(alpha: 0.18),
          width: IosMetrics.hairline,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '导入状态待确认',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '${message ?? '逐行结果暂未取得'}。为避免重复导入，请先重新获取结果。',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                _runControllerAction(widget.controller.retryImportRows),
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            label: const Text('重新获取结果'),
          ),
        ],
      ),
    ),
  );

  Widget _reportCard(
    I2ImportJob job,
    List<I2ImportRowResult> rows, {
    required bool busy,
  }) => Container(
    decoration: BoxDecoration(
      color: ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('导入结果：成功 ${job.importedRows} 条'),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            const Text('暂未取得逐行结果，可使用下方按钮重新获取。')
          else
            IosGroupedSection(
              margin: EdgeInsets.zero,
              children: [
                for (final row in rows)
                  IosListTile(
                    key: Key('i2-import-row-${row.rowNumber}'),
                    leading: Text('第 ${row.rowNumber} 条'),
                    title: _rowStatusLabel(row.status),
                    subtitle: row.issues.isEmpty
                        ? '已完成'
                        : row.issues.map((issue) => issue.message).join('；'),
                    showChevron: false,
                    minHeight: 40,
                  ),
              ],
            ),
          OutlinedButton.icon(
            onPressed: busy
                ? null
                : () => _runControllerAction(widget.controller.retryImportRows),
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            label: Text(rows.isEmpty ? '重新获取结果' : '刷新结果'),
          ),
        ],
      ),
    ),
  );
}

int _stageStep(I2ImportStage stage) => switch (stage) {
  I2ImportStage.idle || I2ImportStage.uploading || I2ImportStage.error => 0,
  I2ImportStage.mapping || I2ImportStage.preflight => 1,
  I2ImportStage.conflictPreview || I2ImportStage.committing => 2,
  I2ImportStage.report => 3,
};

String _rowStatusLabel(String status) => switch (status.toLowerCase()) {
  'imported' || 'created' => '已导入',
  'updated' => '已更新',
  'skipped' => '已跳过',
  'failed' || 'invalid' => '需要修改',
  _ => '已处理',
};

class _ImportField {
  const _ImportField(this.key, this.label, {this.required = false});

  final String key;
  final String label;
  final bool required;
}

const _importFields = <String, List<_ImportField>>{
  'hamster': [
    _ImportField('internal_code', '仓鼠编号', required: true),
    _ImportField('name', '名称'),
    _ImportField('species_rule_version_id', '物种规则版本'),
    _ImportField('variety_code', '品系或品种'),
    _ImportField('sex', '性别'),
    _ImportField('born_at', '出生日期'),
    _ImportField('source_type', '来源类型'),
    _ImportField('lifecycle_status', '个体状态'),
    _ImportField('breeding_status', '繁育状态'),
    _ImportField('litter_code', '窝次编号'),
    _ImportField('sire_code', '父本编号'),
    _ImportField('dam_code', '母本编号'),
    _ImportField('enclosure_code', '笼盒编号'),
    _ImportField('enclosure_started_at', '入住时间'),
    _ImportField('tags', '标签'),
    _ImportField('notes', '备注'),
  ],
  'enclosure': [
    _ImportField('code', '笼盒编号', required: true),
    _ImportField('rack_code', '笼架编号'),
    _ImportField('level_code', '层位编号'),
    _ImportField('capacity', '容量'),
    _ImportField('state', '笼盒状态'),
    _ImportField('cleanliness', '清洁状态'),
    _ImportField('last_cleaned_at', '最近清洁时间'),
    _ImportField('disabled_reason', '停用原因'),
  ],
  'weight': [
    _ImportField('subject_type', '称重对象类型'),
    _ImportField('hamster_code', '仓鼠编号'),
    _ImportField('litter_code', '窝次编号'),
    _ImportField('measurement_kind', '称重方式'),
    _ImportField('subject_count', '个体数量'),
    _ImportField('weight_g', '体重（克）', required: true),
    _ImportField('recorded_at', '称重时间', required: true),
    _ImportField('acquisition_key', '采集编号'),
  ],
};

String _targetLabel(String target) {
  if (target == _I2ImportPageState._skipField) return '不导入';
  for (final fields in _importFields.values) {
    for (final field in fields) {
      if (field.key == target) return field.label;
    }
  }
  return target;
}
