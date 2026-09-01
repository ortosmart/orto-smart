import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';

const _gardenId = '11111111-1111-4111-8111-111111111111';
const _bedId = '22222222-2222-4222-8222-222222222222';
const _geometryId = '33333333-3333-4333-8333-333333333333';
const _otherGardenId = '88888888-8888-4888-8888-888888888888';

Map<String, dynamic> _bedMap({
  String bedId = _bedId,
  int number = 1,
  String gardenId = _gardenId,
}) {
  return {
    'id': bedId,
    'garden_id': gardenId,
    'number': number,
    'name': 'Aiuola di prova',
    'notes': null,
    'is_active': true,
    'row_version': 5,
    'bed_geometries': [
      {
        'id': _geometryId,
        'bed_id': bedId,
        'width_cm': 90,
        'length_cm': 700,
        'valid_from': '2026-03-01',
        'valid_to': null,
        'row_version': 2,
      },
    ],
  };
}

void main() {
  group('BedRepository.getBeds', () {
    test('returns an empty list when no beds are available', () async {
      final repository = BedRepository.withLoader((gardenId) async => []);

      final beds = await repository.getBeds(gardenId: _gardenId);

      expect(beds, isEmpty);
    });

    test('maps a bed and its selected geometry', () async {
      final repository = BedRepository.withLoader(
        (gardenId) async => [_bedMap()],
      );

      final beds = await repository.getBeds(gardenId: _gardenId);

      expect(beds, hasLength(1));

      final bed = beds.single;

      expect(bed.id, _bedId);
      expect(bed.gardenId, _gardenId);
      expect(bed.number, 1);
      expect(bed.code, 'A01');
      expect(bed.name, 'Aiuola di prova');
      expect(bed.notes, isNull);
      expect(bed.isActive, isTrue);
      expect(bed.rowVersion, 5);
      expect(bed.geometry.id, _geometryId);
      expect(bed.geometry.bedId, _bedId);
      expect(bed.widthCm, 90);
      expect(bed.lengthCm, 700);
      expect(bed.geometry.validFrom, DateTime.utc(2026, 3, 1));
      expect(bed.geometry.validTo, isNull);
      expect(bed.geometry.rowVersion, 2);
    });

    test('maps multiple beds preserving loader order', () async {
      const secondBedId = '44444444-4444-4444-8444-444444444444';

      final repository = BedRepository.withLoader(
        (gardenId) async => [_bedMap(bedId: secondBedId, number: 2), _bedMap()],
      );

      final beds = await repository.getBeds(gardenId: _gardenId);

      expect(beds.map((bed) => bed.id), [secondBedId, _bedId]);
      expect(beds.map((bed) => bed.number), [2, 1]);
    });

    test('calls the loader once per request without caching', () async {
      var calls = 0;

      final repository = BedRepository.withLoader((gardenId) async {
        calls += 1;
        return [_bedMap(number: calls)];
      });

      final first = await repository.getBeds(gardenId: _gardenId);
      final second = await repository.getBeds(gardenId: _gardenId);

      expect(calls, 2);
      expect(first.single.number, 1);
      expect(second.single.number, 2);
    });

    test('propagates loader errors without returning an empty list', () async {
      final failure = StateError('Synthetic loader failure');

      final repository = BedRepository.withLoader((gardenId) async {
        throw failure;
      });

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(same(failure)),
      );
    });

    test('rejects a missing geometry relation', () async {
      final map = _bedMap()..remove('bed_geometries');

      final repository = BedRepository.withLoader((gardenId) async => [map]);

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a bed without a selected geometry', () async {
      final map = _bedMap()..['bed_geometries'] = <Map<String, dynamic>>[];

      final repository = BedRepository.withLoader((gardenId) async => [map]);

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects multiple selected geometries', () async {
      final map = _bedMap();
      final geometries = map['bed_geometries'] as List<Map<String, dynamic>>;

      geometries.add({
        ...geometries.single,
        'id': '55555555-5555-4555-8555-555555555555',
      });

      final repository = BedRepository.withLoader((gardenId) async => [map]);

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a geometry belonging to another bed', () async {
      final map = _bedMap();
      final geometries = map['bed_geometries'] as List<Map<String, dynamic>>;

      geometries.single['bed_id'] = '66666666-6666-4666-8666-666666666666';

      final repository = BedRepository.withLoader((gardenId) async => [map]);

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects invalid geometry dimensions', () async {
      final map = _bedMap();
      final geometries = map['bed_geometries'] as List<Map<String, dynamic>>;

      geometries.single['width_cm'] = 0;

      final repository = BedRepository.withLoader((gardenId) async => [map]);

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(isA<FormatException>()),
      );
    });

    test('fails the whole request when one bed is invalid', () async {
      final invalidMap = _bedMap(
        bedId: '77777777-7777-4777-8777-777777777777',
        number: 2,
      )..['bed_geometries'] = <Map<String, dynamic>>[];

      final repository = BedRepository.withLoader(
        (gardenId) async => [_bedMap(), invalidMap],
      );

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(isA<FormatException>()),
      );
    });

    test('passes each requested Garden ID to the loader', () async {
      final requestedIds = <String>[];

      final repository = BedRepository.withLoader((gardenId) async {
        requestedIds.add(gardenId);
        return [_bedMap(gardenId: gardenId)];
      });

      final first = await repository.getBeds(gardenId: _gardenId);
      final second = await repository.getBeds(gardenId: _otherGardenId);

      expect(requestedIds, [_gardenId, _otherGardenId]);
      expect(first.single.gardenId, _gardenId);
      expect(second.single.gardenId, _otherGardenId);
    });

    for (final invalidId in ['', '   ']) {
      test('rejects Garden ID "$invalidId" before loading', () async {
        var calls = 0;

        final repository = BedRepository.withLoader((gardenId) async {
          calls += 1;
          return [];
        });

        await expectLater(
          repository.getBeds(gardenId: invalidId),
          throwsA(isA<ArgumentError>()),
        );

        expect(calls, 0);
      });
    }

    test('rejects a bed belonging to another Garden', () async {
      final repository = BedRepository.withLoader(
        (gardenId) async => [_bedMap(gardenId: _otherGardenId)],
      );

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects mixed Gardens without returning a partial list', () async {
      final repository = BedRepository.withLoader(
        (gardenId) async => [
          _bedMap(),
          _bedMap(
            bedId: '99999999-9999-4999-8999-999999999999',
            number: 2,
            gardenId: _otherGardenId,
          ),
        ],
      );

      await expectLater(
        repository.getBeds(gardenId: _gardenId),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
