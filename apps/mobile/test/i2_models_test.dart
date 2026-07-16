import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/i2/i2_import.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';

void main() {
  test('CSV parser preserves quoted commas and CRLF rows', () {
    final table = I2CsvParser.parse(
      'internal_code,name,notes\r\n'
      'H-001,"雪团,一号","喜欢\n木屑"\r\n'
      'H-002,小黑,正常\r\n',
    );

    expect(table.headers, ['internal_code', 'name', 'notes']);
    expect(table.rows, [
      ['H-001', '雪团,一号', '喜欢\n木屑'],
      ['H-002', '小黑', '正常'],
    ]);
  });

  test(
    'snapshot keeps historical litter origin/code and litter weight link',
    () {
      final snapshot = I2Snapshot(
        hamsters: const <I2Hamster>[],
        litters: [
          I2Litter(
            id: 'l-1',
            code: 'L-2025-01',
            origin: 'import',
            bornAt: DateTime.utc(2025, 1, 2),
            initialAliveCount: 4,
            currentManagedCount: 4,
            state: 'closed',
            enclosureId: 'e-1',
            sireId: 'h-1',
            damId: 'h-2',
            version: 1,
          ),
        ],
        enclosures: const <I2Enclosure>[],
        lastSyncedAt: DateTime.utc(2025, 1, 3),
      );

      final restored = I2Snapshot.fromJson(snapshot.toJson());
      expect(restored.litters.single.code, 'L-2025-01');
      expect(restored.litters.single.origin, 'import');

      final weight = I2WeightRecord.fromJson({
        'id': 'w-1',
        'litter_id': 'l-1',
        'measurement_kind': 'litter_average',
        'subject_count': 4,
        'weight_g': 12.5,
        'recorded_at': '2025-01-03T00:00:00Z',
        'source': 'manual',
      });
      expect(weight.litterId, 'l-1');
      expect(weight.measurementKind, 'litter_average');
      expect(weight.subjectCount, 4);
    },
  );
}
