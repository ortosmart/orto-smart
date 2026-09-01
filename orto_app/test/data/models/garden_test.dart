import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/garden.dart';

Map<String, dynamic> _validMap() {
  return {
    'id': '11111111-1111-4111-8111-111111111111',
    'profile_id': '22222222-2222-4222-8222-222222222222',
    'name': 'Orto di prova',
    'description': 'Descrizione di prova',
    'is_active': true,
    'row_version': 3,
  };
}

void main() {
  group('Garden.fromJson', () {
    test('reads the V1 fields without legacy fields', () {
      final garden = Garden.fromJson(_validMap());

      expect(garden.id, '11111111-1111-4111-8111-111111111111');
      expect(garden.profileId, '22222222-2222-4222-8222-222222222222');
      expect(garden.name, 'Orto di prova');
      expect(garden.description, 'Descrizione di prova');
      expect(garden.isActive, isTrue);
      expect(garden.rowVersion, 3);
    });

    test('accepts a null description', () {
      final map = _validMap()..['description'] = null;

      final garden = Garden.fromJson(map);

      expect(garden.description, isNull);
    });

    test('accepts an omitted optional description', () {
      final map = _validMap()..remove('description');

      final garden = Garden.fromJson(map);

      expect(garden.description, isNull);
    });

    test('preserves the disabled state', () {
      final map = _validMap()..['is_active'] = false;

      final garden = Garden.fromJson(map);

      expect(garden.isActive, isFalse);
    });

    test('ignores legacy and additional database fields', () {
      final map = _validMap()
        ..addAll({
          'beds_count': 15,
          'bed_length_cm': 700,
          'bed_width_cm': 90,
          'path_width_cm': 50,
          'timezone': 'Europe/Rome',
        });

      final garden = Garden.fromJson(map);

      expect(garden.id, '11111111-1111-4111-8111-111111111111');
      expect(garden.profileId, '22222222-2222-4222-8222-222222222222');
      expect(garden.name, 'Orto di prova');
      expect(garden.description, 'Descrizione di prova');
      expect(garden.isActive, isTrue);
      expect(garden.rowVersion, 3);
    });

    const requiredKeys = [
      'id',
      'profile_id',
      'name',
      'is_active',
      'row_version',
    ];

    for (final key in requiredKeys) {
      test('rejects missing $key', () {
        final map = _validMap()..remove(key);

        expect(() => Garden.fromJson(map), throwsA(isA<FormatException>()));
      });

      test('rejects null $key', () {
        final map = _validMap()..[key] = null;

        expect(() => Garden.fromJson(map), throwsA(isA<FormatException>()));
      });
    }

    final invalidCases = <String, Map<String, dynamic>>{
      'empty id': {'id': ''},
      'blank id': {'id': '   '},
      'non-string id': {'id': 1},
      'empty profile id': {'profile_id': ''},
      'blank profile id': {'profile_id': '   '},
      'non-string profile id': {'profile_id': 1},
      'empty name': {'name': ''},
      'blank name': {'name': '   '},
      'non-string name': {'name': 1},
      'non-string description': {'description': 1},
      'string active state': {'is_active': 'true'},
      'numeric active state': {'is_active': 1},
      'zero row version': {'row_version': 0},
      'negative row version': {'row_version': -1},
      'string row version': {'row_version': '3'},
      'decimal row version': {'row_version': 3.5},
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () {
        final map = _validMap()..addAll(entry.value);

        expect(() => Garden.fromJson(map), throwsA(isA<FormatException>()));
      });
    }
  });
}
