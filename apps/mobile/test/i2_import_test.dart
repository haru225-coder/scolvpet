import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_import.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'support/memory_repositories.dart';

class ImportRepository extends MemoryI2Repository {
  ImportRepository({this.blocking = false, this.rowFailuresBeforeSuccess = 0});

  final bool blocking;
  final int rowFailuresBeforeSuccess;
  int commitCount = 0;
  int uploadCount = 0;
  int rowCalls = 0;
  I2CsvUpload? capturedUpload;

  I2ImportJob get _job => I2ImportJob(
    id: 'job-1',
    version: 2,
    phase: blocking ? 'ready_to_commit' : 'completed',
    status: 'succeeded',
    progressPercent: 100,
    sourceColumns: const ['internal_code', 'name'],
    mapping: const {'internal_code': 'internal_code', 'name': 'name'},
    preflightVersion: 2,
    totalRows: 2,
    validRows: blocking ? 1 : 2,
    warningRows: 0,
    invalidRows: blocking ? 1 : 0,
    blockingIssueCount: blocking ? 1 : 0,
    importedRows: blocking ? 0 : 2,
  );

  @override
  Future<I2ImportJob> uploadCsv(I2CsvUpload upload) async {
    uploadCount++;
    capturedUpload = upload;
    return _job;
  }

  @override
  Future<I2ImportJob> setImportMapping(
    String jobId,
    int version,
    List<I2ImportMapping> mappings,
  ) async => _job;

  @override
  Future<I2ImportJob> preflightImport(String jobId, int version) async => _job;

  @override
  Future<I2ImportJob> commitImport(
    String jobId,
    int version, {
    Set<I2ImportApprovedUpdate> approvedUpdates =
        const <I2ImportApprovedUpdate>{},
  }) async {
    commitCount++;
    return _job;
  }

  @override
  Future<List<I2ImportRowResult>> listImportRows(String jobId) async {
    rowCalls++;
    if (rowCalls <= rowFailuresBeforeSuccess) {
      throw const I2RepositoryException('逐行结果暂时不可用');
    }
    return [
      const I2ImportRowResult(
        rowNumber: 2,
        status: 'imported',
        mappedValues: {'internal_code': 'H-001'},
        issues: <I2ImportIssue>[],
      ),
    ];
  }
}

class _DelayedImportRepository extends ImportRepository {
  final gate = Completer<void>();

  @override
  Future<I2ImportJob> uploadCsv(I2CsvUpload upload) async {
    uploadCount++;
    capturedUpload = upload;
    await gate.future;
    return _job;
  }
}

void main() {
  test('CSV workflow reaches row report after preflight and commit', () async {
    final repository = ImportRepository();
    final controller = I2Controller(repository: repository);

    await controller.uploadCsv(
      I2CsvUpload(
        fileName: 'hamsters.csv',
        bytes: Uint8List.fromList([1, 2]),
        sha256: 'sha',
        template: 'hamster',
      ),
    );
    expect(controller.importStage, I2ImportStage.mapping);

    await controller.setImportMapping(const [
      I2ImportMapping(
        sourceColumn: 'internal_code',
        targetField: 'internal_code',
      ),
    ]);
    expect(controller.importStage, I2ImportStage.preflight);

    await controller.preflightImport();
    expect(controller.importStage, I2ImportStage.conflictPreview);

    await controller.commitImport();
    expect(repository.commitCount, 1);
    expect(controller.importStage, I2ImportStage.report);
    expect(controller.importRows.single.status, 'imported');
  });

  test(
    'blocking preflight keeps commit disabled and reports conflict',
    () async {
      final repository = ImportRepository(blocking: true);
      final controller = I2Controller(repository: repository);

      await controller.uploadCsv(
        I2CsvUpload(
          fileName: 'invalid.csv',
          bytes: Uint8List.fromList([1]),
          sha256: 'sha',
          template: 'hamster',
        ),
      );
      await controller.preflightImport();
      await controller.commitImport();

      expect(repository.commitCount, 0);
      expect(controller.importStage, I2ImportStage.conflictPreview);
      expect(controller.actionState.status, I2AsyncStatus.conflict);
    },
  );

  testWidgets('paste CSV computes UTF-8 SHA-256 and uploads once', (
    tester,
  ) async {
    final repository = ImportRepository();
    final controller = I2Controller(repository: repository);
    const csv = 'internal_code,name\nH-001,雪团\n';

    await tester.binding.setSurfaceSize(const Size(400, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: I2ImportPage(controller: controller)),
    );
    await tester.enterText(find.byKey(const Key('i2-import-csv-input')), csv);
    await tester.pump();

    expect(find.byKey(const Key('i2-import-sha256')), findsOneWidget);
    expect(find.text('文件校验码'), findsNothing);

    await tester.tap(find.byKey(const Key('i2-import-upload')));
    await tester.pumpAndSettle();

    expect(repository.uploadCount, 1);
    expect(
      repository.capturedUpload!.sha256,
      sha256.convert(utf8.encode(csv)).toString(),
    );
    expect(repository.capturedUpload!.bytes, utf8.encode(csv));
    expect(find.text('导入到：仓鼠编号'), findsOneWidget);
  });

  testWidgets('mapping only allows supported targets and rejects duplicates', (
    tester,
  ) async {
    final repository = ImportRepository();
    final controller = I2Controller(repository: repository);
    await controller.uploadCsv(
      I2CsvUpload(
        fileName: 'hamsters.csv',
        bytes: Uint8List.fromList(utf8.encode('internal_code,name\nH-1,雪团')),
        sha256: sha256
            .convert(utf8.encode('internal_code,name\nH-1,雪团'))
            .toString(),
        template: 'hamster',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: I2ImportPage(controller: controller)),
    );
    await tester.tap(find.byKey(const Key('i2-import-mapping-name')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('仓鼠编号（必需）'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('继续检查'));
    await tester.pump();

    expect(find.textContaining('只能各映射一次'), findsOneWidget);
    expect(controller.importStage, I2ImportStage.mapping);
  });

  testWidgets('upload button ignores repeated taps while file is processing', (
    tester,
  ) async {
    final repository = _DelayedImportRepository();
    final controller = I2Controller(repository: repository);
    await tester.binding.setSurfaceSize(const Size(400, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(home: I2ImportPage(controller: controller)),
    );
    await tester.enterText(
      find.byKey(const Key('i2-import-csv-input')),
      'internal_code,name\nH-001,雪团',
    );
    await tester.tap(find.byKey(const Key('i2-import-upload')));
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('i2-import-upload')),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(repository.uploadCount, 1);
    repository.gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('result fetch failure retries rows without committing again', (
    tester,
  ) async {
    final repository = ImportRepository(rowFailuresBeforeSuccess: 1);
    final controller = I2Controller(repository: repository);
    await controller.uploadCsv(
      I2CsvUpload(
        fileName: 'hamsters.csv',
        bytes: Uint8List.fromList([1]),
        sha256: 'sha',
        template: 'hamster',
      ),
    );
    await controller.setImportMapping(const [
      I2ImportMapping(
        sourceColumn: 'internal_code',
        targetField: 'internal_code',
      ),
    ]);
    await controller.preflightImport();
    await controller.commitImport();
    expect(controller.importStage, I2ImportStage.committing);

    await tester.pumpWidget(
      MaterialApp(home: I2ImportPage(controller: controller)),
    );
    expect(find.byKey(const Key('i2-import-results-retry')), findsOneWidget);

    await tester.tap(find.text('重新获取结果'));
    await tester.pumpAndSettle();

    expect(repository.commitCount, 1);
    expect(repository.rowCalls, 2);
    expect(controller.importStage, I2ImportStage.report);
  });
}
