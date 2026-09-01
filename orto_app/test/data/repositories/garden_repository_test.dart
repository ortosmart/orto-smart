import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/garden_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _otherProfileId = '22222222-2222-4222-8222-222222222222';
const _gardenId = '33333333-3333-4333-8333-333333333333';
const _secondGardenId = '44444444-4444-4444-8444-444444444444';

Map<String, dynamic> _gardenMap({
  String id = _gardenId,
  String profileId = _profileId,
  String name = 'Orto di prova',
  bool isActive = true,
}) {
  return {
    'id': id,
    'profile_id': profileId,
    'name': name,
    'description': 'Descrizione di prova',
    'is_active': isActive,
    'row_version': 3,
  };
}

void main() {
  group('GardenRepository.getGardens', () {
    test('returns an empty list when no Gardens are available', () async {
      final repository = GardenRepository.withLoader((profileId) async => []);

      final gardens = await repository.getGardens(profileId: _profileId);

      expect(gardens, isEmpty);
    });

    test('maps all required Garden fields', () async {
      final repository = GardenRepository.withLoader(
        (profileId) async => [_gardenMap()],
      );

      final gardens = await repository.getGardens(profileId: _profileId);

      expect(gardens, hasLength(1));

      final garden = gardens.single;

      expect(garden.id, _gardenId);
      expect(garden.profileId, _profileId);
      expect(garden.name, 'Orto di prova');
      expect(garden.description, 'Descrizione di prova');
      expect(garden.isActive, isTrue);
      expect(garden.rowVersion, 3);
    });

    test('returns all Gardens without selecting the first', () async {
      final repository = GardenRepository.withLoader(
        (profileId) async => [
          _gardenMap(id: _secondGardenId, name: 'Secondo orto'),
          _gardenMap(),
        ],
      );

      final gardens = await repository.getGardens(profileId: _profileId);

      expect(gardens, hasLength(2));
      expect(gardens.map((garden) => garden.id), [_secondGardenId, _gardenId]);
      expect(gardens.map((garden) => garden.name), [
        'Secondo orto',
        'Orto di prova',
      ]);
    });

    test('preserves disabled Gardens in the result', () async {
      final repository = GardenRepository.withLoader(
        (profileId) async => [_gardenMap(isActive: false)],
      );

      final gardens = await repository.getGardens(profileId: _profileId);

      expect(gardens, hasLength(1));
      expect(gardens.single.isActive, isFalse);
    });

    test('preserves a null description', () async {
      final map = _gardenMap()..['description'] = null;

      final repository = GardenRepository.withLoader(
        (profileId) async => [map],
      );

      final gardens = await repository.getGardens(profileId: _profileId);

      expect(gardens.single.description, isNull);
    });

    test('passes each requested Profile ID to the loader', () async {
      final requestedIds = <String>[];

      final repository = GardenRepository.withLoader((profileId) async {
        requestedIds.add(profileId);
        return [_gardenMap(profileId: profileId)];
      });

      final first = await repository.getGardens(profileId: _profileId);
      final second = await repository.getGardens(profileId: _otherProfileId);

      expect(requestedIds, [_profileId, _otherProfileId]);
      expect(first.single.profileId, _profileId);
      expect(second.single.profileId, _otherProfileId);
    });

    test('loads again on every request without caching', () async {
      var calls = 0;

      final repository = GardenRepository.withLoader((profileId) async {
        calls += 1;
        return [_gardenMap(name: 'Orto $calls')];
      });

      final first = await repository.getGardens(profileId: _profileId);
      final second = await repository.getGardens(profileId: _profileId);

      expect(calls, 2);
      expect(first.single.name, 'Orto 1');
      expect(second.single.name, 'Orto 2');
    });

    for (final invalidId in ['', '   ']) {
      test('rejects Profile ID "$invalidId" before loading', () async {
        var calls = 0;

        final repository = GardenRepository.withLoader((profileId) async {
          calls += 1;
          return [];
        });

        await expectLater(
          repository.getGardens(profileId: invalidId),
          throwsA(isA<ArgumentError>()),
        );

        expect(calls, 0);
      });
    }

    test('propagates loader failure without retrying', () async {
      var calls = 0;
      final failure = StateError('Synthetic loader failure');

      final repository = GardenRepository.withLoader((profileId) async {
        calls += 1;
        throw failure;
      });

      await expectLater(
        repository.getGardens(profileId: _profileId),
        throwsA(same(failure)),
      );

      expect(calls, 1);
    });

    test('rejects a Garden belonging to another Profile', () async {
      final repository = GardenRepository.withLoader(
        (profileId) async => [_gardenMap(profileId: _otherProfileId)],
      );

      await expectLater(
        repository.getGardens(profileId: _profileId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects mixed Profiles without returning a partial list', () async {
      final repository = GardenRepository.withLoader(
        (profileId) async => [
          _gardenMap(),
          _gardenMap(id: _secondGardenId, profileId: _otherProfileId),
        ],
      );

      await expectLater(
        repository.getGardens(profileId: _profileId),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed Garden data', () async {
      final map = _gardenMap()..['row_version'] = 0;

      final repository = GardenRepository.withLoader(
        (profileId) async => [map],
      );

      await expectLater(
        repository.getGardens(profileId: _profileId),
        throwsA(isA<FormatException>()),
      );
    });

    test('fails the whole request when one Garden is malformed', () async {
      final invalidMap = _gardenMap(id: _secondGardenId)..remove('name');

      final repository = GardenRepository.withLoader(
        (profileId) async => [_gardenMap(), invalidMap],
      );

      await expectLater(
        repository.getGardens(profileId: _profileId),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
