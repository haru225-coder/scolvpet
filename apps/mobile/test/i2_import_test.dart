import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';

class ImportRepository extends MemoryI2Repository {
  ImportRepository({this.blocking = false});

  final bool blocking;
  int commitCount = 0;

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
  Future<I2ImportJob> uploadCsv(I2CsvUpload upload) async => _job;

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
  Future<List<I2ImportRowResult>> listImportRows(String jobId) async => [
    const I2ImportRowResult(
      rowNumber: 2,
      status: 'imported',
      mappedValues: {'internal_code': 'H-001'},
      issues: <I2ImportIssue>[],
    ),
  ];
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
}
