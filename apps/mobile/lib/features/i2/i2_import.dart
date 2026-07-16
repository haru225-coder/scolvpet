import 'package:flutter/material.dart';

import 'i2_controller.dart';
import 'i2_models.dart';
import 'i2_widgets.dart';

class I2CsvTable {
  const I2CsvTable({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;
}

class I2CsvParser {
  const I2CsvParser._();

  static I2CsvTable parse(String input) {
    final rows = <List<String>>[];
    final currentRow = <String>[];
    final currentCell = StringBuffer();
    var quoted = false;
    var index = 0;

    void finishCell() {
      currentRow.add(currentCell.toString());
      currentCell.clear();
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
        quoted = !quoted;
      } else if (char == ',' && !quoted) {
        finishCell();
      } else if ((char == '\n' || char == '\r') && !quoted) {
        finishRow();
        if (char == '\r' &&
            index + 1 < input.length &&
            input[index + 1] == '\n') {
          index++;
        }
      } else {
        currentCell.write(char);
      }
      index++;
    }
    if (currentCell.isNotEmpty || currentRow.isNotEmpty) finishRow();
    if (rows.isEmpty) {
      return const I2CsvTable(headers: <String>[], rows: <List<String>>[]);
    }
    final headers = rows.first.map((value) => value.trim()).toList();
    final data = rows.skip(1).map((row) {
      final values = List<String>.filled(headers.length, '');
      for (var i = 0; i < row.length && i < values.length; i++) {
        values[i] = row[i].trim();
      }
      return values;
    }).toList();
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
  final _fileName = TextEditingController(text: 'hamsters.csv');
  final _sha256 = TextEditingController();
  final _csvText = TextEditingController();
  String _template = 'hamster';
  I2CsvTable? _table;
  final Map<String, String> _mapping = <String, String>{};

  @override
  void dispose() {
    _fileName.dispose();
    _sha256.dispose();
    _csvText.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    I2CsvUpload? upload;
    if (widget.onPickCsv != null) {
      upload = await widget.onPickCsv!();
    } else {
      if (_csvText.text.trim().isEmpty || _sha256.text.trim().isEmpty) return;
      _table = I2CsvParser.parse(_csvText.text);
      if (_table!.headers.isEmpty) return;
      upload = I2CsvUpload(
        fileName: _fileName.text.trim().isEmpty
            ? 'import.csv'
            : _fileName.text.trim(),
        bytes: csvBytes(_csvText.text),
        sha256: _sha256.text.trim(),
        template: _template,
      );
    }
    await widget.controller.uploadCsv(upload);
    if (mounted) setState(() {});
  }

  List<I2ImportMapping> _selectedMappings(I2ImportJob job) => job.sourceColumns
      .map(
        (source) => I2ImportMapping(
          sourceColumn: source,
          targetField: _mapping[source] ?? source,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final job = controller.importJob;
      return Scaffold(
        appBar: AppBar(title: const Text('数据中心 · CSV 导入 · P27')),
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
              DropdownButtonFormField<String>(
                initialValue: _template,
                decoration: const InputDecoration(labelText: '模板类型'),
                items: const [
                  DropdownMenuItem(value: 'hamster', child: Text('仓鼠')),
                  DropdownMenuItem(value: 'enclosure', child: Text('笼盒')),
                  DropdownMenuItem(value: 'weight', child: Text('体重')),
                ],
                onChanged: controller.canWrite
                    ? (value) => setState(() => _template = value!)
                    : null,
              ),
              TextField(
                controller: _fileName,
                decoration: const InputDecoration(labelText: '文件名'),
              ),
              TextField(
                controller: _sha256,
                decoration: const InputDecoration(labelText: 'SHA-256（上传前计算）'),
              ),
              TextField(
                controller: _csvText,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'CSV 内容（接线时可替换为文件选择器）',
                  hintText: 'internal_code,name,sex\nH-001,雪团,female',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_table != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '本地识别 ${_table!.headers.length} 列、${_table!.rows.length} 行',
                  ),
                ),
              const SizedBox(height: 16),
              I2WriteButton(
                enabled: controller.canWrite,
                label: '上传并识别列',
                icon: Icons.upload_file_outlined,
                onPressed: _upload,
              ),
            ],
            if (job != null &&
                controller.importStage == I2ImportStage.mapping) ...[
              _mappingCard(job),
              const SizedBox(height: 12),
              I2WriteButton(
                enabled: controller.canWrite,
                label: '保存映射并进入全量预检',
                icon: Icons.account_tree_outlined,
                onPressed: () =>
                    controller.setImportMapping(_selectedMappings(job)),
              ),
            ],
            if (job != null &&
                controller.importStage == I2ImportStage.preflight) ...[
              _jobSummary(job),
              const SizedBox(height: 12),
              I2WriteButton(
                enabled: controller.canWrite,
                label: '执行全量预检',
                icon: Icons.fact_check_outlined,
                onPressed: controller.preflightImport,
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
                label: '确认提交正式导入',
                icon: Icons.task_alt,
                onPressed: () => controller.commitImport(),
              ),
            ],
            if (controller.importStage == I2ImportStage.committing)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (job != null && controller.importStage == I2ImportStage.report)
              _reportCard(job, controller.importRows),
            if (controller.actionState.status == I2AsyncStatus.error ||
                controller.actionState.status == I2AsyncStatus.conflict)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: I2StateMessage(
                  icon: controller.actionState.status == I2AsyncStatus.conflict
                      ? Icons.warning_amber
                      : Icons.error_outline,
                  message: controller.actionState.message ?? '请求未完成，请稍后重试',
                  onRetry: controller.importStage == I2ImportStage.report
                      ? controller.retryImportRows
                      : null,
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _stageHeader(I2ImportStage stage) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in const [
            ('上传', I2ImportStage.uploading),
            ('映射', I2ImportStage.mapping),
            ('预检', I2ImportStage.preflight),
            ('冲突预览', I2ImportStage.conflictPreview),
            ('提交', I2ImportStage.committing),
            ('逐行报告', I2ImportStage.report),
          ])
            Chip(
              avatar: Icon(
                item.$2 == stage
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 16,
              ),
              label: Text(item.$1),
            ),
        ],
      ),
    ),
  );

  Widget _mappingCard(I2ImportJob job) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('字段映射'),
          const SizedBox(height: 8),
          for (final source in job.sourceColumns)
            Row(
              children: [
                Expanded(child: Text(source)),
                const Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        _mapping[source] ?? job.mapping[source] ?? source,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: '目标字段',
                    ),
                    onChanged: (value) => _mapping[source] = value.trim(),
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
  );

  Widget _jobSummary(I2ImportJob job) => Card(
    child: Column(
      children: [
        ListTile(
          title: Text('任务 ${job.id} · ${job.phase}'),
          subtitle: Text('进度 ${job.progressPercent}% · 版本 ${job.version}'),
        ),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text('总行 ${job.totalRows}')),
            Chip(label: Text('有效 ${job.validRows}')),
            Chip(label: Text('警告 ${job.warningRows}')),
            Chip(label: Text('阻塞 ${job.blockingIssueCount}')),
          ],
        ),
        const SizedBox(height: 8),
      ],
    ),
  );

  Widget _conflictPreview(I2ImportJob job) => Card(
    color: job.hasBlockingIssues ? Colors.orange.withValues(alpha: .08) : null,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        job.hasBlockingIssues
            ? '存在阻塞问题：正式提交按钮已禁用。请修复源 CSV 后创建新批次并重新预检。'
            : '预检通过：新增 ${job.validRows} 行，可提交；更新候选需逐项确认。',
      ),
    ),
  );

  Widget _reportCard(I2ImportJob job, List<I2ImportRowResult> rows) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('逐行报告 · 已导入 ${job.importedRows} 行'),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            const Text('报告生成中，请重试刷新。')
          else
            ...rows.map(
              (row) => ListTile(
                dense: true,
                leading: Text('${row.rowNumber}'),
                title: Text(row.status),
                subtitle: Text(
                  row.issues.isEmpty
                      ? '无问题'
                      : row.issues
                            .map((issue) => '${issue.code}: ${issue.message}')
                            .join('；'),
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: widget.controller.retryImportRows,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新逐行报告'),
          ),
        ],
      ),
    ),
  );
}
