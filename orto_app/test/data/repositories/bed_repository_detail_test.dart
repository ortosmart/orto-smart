import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';

const _gardenId = '11111111-1111-4111-8111-111111111111';
const _bedId = '22222222-2222-4222-8222-222222222222';
const _geometryId = '33333333-3333-4333-8333-333333333333';

Map<String, dynamic> _bedMap({bool isActive = true}) {
  return {
    'id': _bedId,
    'garden_id': _gardenId,
    'number': 1,
    'name': 'Aiuola di prova',
    'notes': null,
    'is_active': isActive,
    'row_version': 5,
    'bed_geometries': [
      {
        'id': _geometryId,
        'bed_id': _bedId,
        'width_cm': 90,
        'length_cm': 700,
        'valid_from': '2026-03-01',
        'valid_to': null,
        'row_version': 2,
      },
    ],
  };
}

Future<List<Map<String, dynamic>>> _unusedListLoader(String gardenId) async {
  throw StateError('The list loader must not be called');
}

void main() {
  group('BedRepository.getBed', () {
    test('loads and maps the requested bed and geometry', () async {
      final requests = <List<String>>[];

      final repository = BedRepository.withLoader(_unusedListLoader, (
        gardenId,
        bedId,
      ) async {
        requests.add([gardenId, bedId]);
        return _bedMap();
      });

      final bed = await repository.getBed(gardenId: _gardenId, bedId: _bedId);

      expect(requests, [
        [_gardenId, _bedId],
      ]);
      expect(bed, isNotNull);

      final loaded = bed!;

      expect(loaded.id, _bedId);
      expect(loaded.gardenId, _gardenId);
      expect(loaded.number, 1);
      expect(loaded.name, 'Aiuola di prova');
      expect(loaded.notes, isNull);
      expect(loaded.isActive, isTrue);
      expect(loaded.rowVersion, 5);
      expect(loaded.geometry.id, _geometryId);
      expect(loaded.geometry.bedId, _bedId);
      expect(loaded.widthCm, 90);
      expect(loaded.lengthCm, 700);
      expect(loaded.geometry.validFrom, DateTime.utc(2026, 3, 1));
      expect(loaded.geometry.validTo, isNull);
      expect(loaded.geometry.rowVersion, 2);
    });

    test('returns a disabled bed without omitting it', () async {
      var calls = 0;

      final repository = BedRepository.withLoader(_unusedListLoader, (
        gardenId,
        bedId,
      ) async {
        calls += 1;
        return _bedMap(isActive: false);
      });

      final bed = await repository.getBed(gardenId: _gardenId, bedId: _bedId);

      expect(calls, 1);
      expect(bed, isNotNull);
      expect(bed!.id, _bedId);
      expect(bed.isActive, isFalse);
      expect(bed.rowVersion, 5);
    });

    test('returns null when the loader returns no bed', () async {
      var calls = 0;

      final repository = BedRepository.withLoader(_unusedListLoader, (
        gardenId,
        bedId,
      ) async {
        calls += 1;
        return null;
      });

      final bed = await repository.getBed(gardenId: _gardenId, bedId: _bedId);

      expect(bed, isNull);
      expect(calls, 1);
    });

    test('rejects a bed belonging to another garden', () async {
      final repository = BedRepository.withLoader(_unusedListLoader, (
        gardenId,
        bedId,
      ) async {
        return _bedMap()
          ..['garden_id'] = '44444444-4444-4444-8444-444444444444';
      });

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects another bed even when its geometry matches it', () async {
      const otherBedId = '55555555-5555-4555-8555-555555555555';
      final map = _bedMap()..['id'] = otherBedId;
      final geometries = map['bed_geometries'] as List<Map<String, dynamic>>;
      geometries.single['bed_id'] = otherBedId;

      final repository = BedRepository.withLoader(
        _unusedListLoader,
        (gardenId, bedId) async => map,
      );

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'propagates loader errors without returning null or retrying',
      () async {
        final failure = StateError('Synthetic detail loader failure');
        var calls = 0;

        final repository = BedRepository.withLoader(_unusedListLoader, (
          gardenId,
          bedId,
        ) async {
          calls += 1;
          throw failure;
        });

        await expectLater(
          repository.getBed(gardenId: _gardenId, bedId: _bedId),
          throwsA(same(failure)),
        );

        expect(calls, 1);
      },
    );

    test('fails explicitly when the detail loader is not configured', () async {
      final repository = BedRepository.withLoader(_unusedListLoader);

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Single Bed loader is not configured',
          ),
        ),
      );
    });

    test('reloads the bed on every request without caching', () async {
      var calls = 0;

      final repository = BedRepository.withLoader(_unusedListLoader, (
        gardenId,
        bedId,
      ) async {
        calls += 1;
        return _bedMap()..['row_version'] = calls;
      });

      final first = await repository.getBed(gardenId: _gardenId, bedId: _bedId);
      final second = await repository.getBed(
        gardenId: _gardenId,
        bedId: _bedId,
      );

      expect(calls, 2);
      expect(first!.rowVersion, 1);
      expect(second!.rowVersion, 2);
    });
    final invalidIdentifiers = <String, List<String>>{
      'empty garden id': ['', _bedId],
      'blank garden id': ['   ', _bedId],
      'empty bed id': [_gardenId, ''],
      'blank bed id': [_gardenId, '   '],
    };

    for (final entry in invalidIdentifiers.entries) {
      test('rejects ${entry.key} before calling a loader', () async {
        var listCalls = 0;
        var detailCalls = 0;

        final repository = BedRepository.withLoader(
          (gardenId) async {
            listCalls += 1;
            return [];
          },
          (gardenId, bedId) async {
            detailCalls += 1;
            return _bedMap();
          },
        );

        await expectLater(
          repository.getBed(gardenId: entry.value[0], bedId: entry.value[1]),
          throwsA(isA<ArgumentError>()),
        );

        expect(listCalls, 0);
        expect(detailCalls, 0);
      });
    }

    test('rejects a missing geometry relation', () async {
      final map = _bedMap()..remove('bed_geometries');

      final repository = BedRepository.withLoader(
        _unusedListLoader,
        (gardenId, bedId) async => map,
      );

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a bed without a selected geometry', () async {
      final map = _bedMap()..['bed_geometries'] = <Map<String, dynamic>>[];

      final repository = BedRepository.withLoader(
        _unusedListLoader,
        (gardenId, bedId) async => map,
      );

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects multiple selected geometries', () async {
      final map = _bedMap();
      final geometries = map['bed_geometries'] as List<Map<String, dynamic>>;

      geometries.add({
        ...geometries.single,
        'id': '66666666-6666-4666-8666-666666666666',
      });

      final repository = BedRepository.withLoader(
        _unusedListLoader,
        (gardenId, bedId) async => map,
      );

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a geometry belonging to another bed', () async {
      final map = _bedMap();
      final geometries = map['bed_geometries'] as List<Map<String, dynamic>>;

      geometries.single['bed_id'] = '77777777-7777-4777-8777-777777777777';

      final repository = BedRepository.withLoader(
        _unusedListLoader,
        (gardenId, bedId) async => map,
      );

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
