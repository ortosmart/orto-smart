import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/training_context.dart';

const _contextId = '44444444-4444-4444-8444-444444444444';

Map<String, dynamic> _contextMap() => {
  'id': _contextId,
  'code': 'GREENHOUSE',
  'name': 'Serra',
  'description': 'Coltivazione in ambiente protetto.',
  'is_active': true,
  'row_version': 3,
  'created_at': '2026-09-20T08:30:00+00:00',
  'updated_at': '2026-09-20T09:45:00+00:00',
};

void main() {
  group('TrainingContext.fromMap', () {
    test('maps a canonical training_contexts row', () {
      final context = TrainingContext.fromMap(_contextMap());

      expect(context.id, _contextId);
      expect(context.code, 'GREENHOUSE');
      expect(context.name, 'Serra');
      expect(context.description, 'Coltivazione in ambiente protetto.');
      expect(context.isActive, isTrue);
      expect(context.rowVersion, 3);
      expect(context.createdAt, DateTime.utc(2026, 9, 20, 8, 30));
      expect(context.updatedAt, DateTime.utc(2026, 9, 20, 9, 45));
    });

    test('accepts a null optional description', () {
      final map = _contextMap()..['description'] = null;

      final context = TrainingContext.fromMap(map);

      expect(context.description, isNull);
    });

    test('preserves an inactive context', () {
      final map = _contextMap()..['is_active'] = false;

      final context = TrainingContext.fromMap(map);

      expect(context.isActive, isFalse);
    });

    test('rejects a missing required field', () {
      final map = _contextMap()..remove('name');

      expect(() => TrainingContext.fromMap(map), throwsFormatException);
    });

    test('rejects an invalid row version', () {
      final map = _contextMap()..['row_version'] = 0;

      expect(() => TrainingContext.fromMap(map), throwsFormatException);
    });

    test('rejects an invalid timestamp', () {
      final map = _contextMap()..['updated_at'] = 'not-a-date';

      expect(() => TrainingContext.fromMap(map), throwsFormatException);
    });

    test('converts timestamps to UTC', () {
      final map = _contextMap()..['created_at'] = '2026-09-20T10:30:00+02:00';

      final context = TrainingContext.fromMap(map);

      expect(context.createdAt.isUtc, isTrue);
      expect(context.createdAt, DateTime.utc(2026, 9, 20, 8, 30));
    });

    test('rejects an invalid active flag', () {
      final map = _contextMap()..['is_active'] = 'true';

      expect(() => TrainingContext.fromMap(map), throwsFormatException);
    });
  });
}
