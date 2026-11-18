import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/garden_write_result.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/data/repositories/garden_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _otherProfileId = '22222222-2222-4222-8222-222222222222';
const _clientId = '33333333-3333-4333-8333-333333333333';
const _sessionId = '44444444-4444-4444-8444-444444444444';

ProfileEditLockLease _lease() {
  return ProfileEditLockLease(
    profileId: _profileId,
    identity: const AppSessionIdentity(
      clientInstanceId: _clientId,
      sessionId: _sessionId,
    ),
    lockToken: 'token-esclusivamente-fittizio',
    expiresAt: DateTime.utc(2099, 1, 1),
    rowVersion: 1,
  );
}

Future<List<Map<String, dynamic>>> _unusedLoader(String profileId) async {
  throw StateError('Read loader must not be called during a write');
}

void main() {
  group('createGarden write authority gate', () {
    test('rejects writes from a read-only repository', () async {
      final repository = GardenRepository.withLoader(_unusedLoader);

      await expectLater(
        repository.createGarden(
          profileId: _profileId,
          name: 'Orto test',
          timezone: 'Europe/Rome',
          countryCode: 'IT',
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
    });

    test('rejects a missing provider before invoking RPC', () async {
      var rpcCalls = 0;

      final repository = GardenRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls++;
        return null;
      }, null);

      await expectLater(
        repository.createGarden(
          profileId: _profileId,
          name: 'Orto test',
          timezone: 'Europe/Rome',
          countryCode: 'IT',
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(rpcCalls, 0);
    });

    test('propagates authority rejection without invoking RPC', () async {
      var rpcCalls = 0;
      const failure = ProfileWriteAuthorityUnavailableException();

      final repository = GardenRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls++;
        return null;
      }, () => throw failure);

      await expectLater(
        repository.createGarden(
          profileId: _profileId,
          name: 'Orto test',
          timezone: 'Europe/Rome',
          countryCode: 'IT',
        ),
        throwsA(same(failure)),
      );

      expect(rpcCalls, 0);
    });

    test('rejects a profile different from the lease profile', () async {
      var rpcCalls = 0;

      final repository = GardenRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls++;
        return null;
      }, _lease);

      await expectLater(
        repository.createGarden(
          profileId: _otherProfileId,
          name: 'Orto test',
          timezone: 'Europe/Rome',
          countryCode: 'IT',
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(rpcCalls, 0);
    });

    test('rejects a missing RPC invoker', () async {
      final repository = GardenRepository.withProviders(
        _unusedLoader,
        null,
        _lease,
      );

      await expectLater(
        repository.createGarden(
          profileId: _profileId,
          name: 'Orto test',
          timezone: 'Europe/Rome',
          countryCode: 'IT',
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
    });
  });

  test('createGarden sends RPC parameters and maps created result', () async {
    var rpcCalls = 0;
    String? calledFunction;
    Map<String, dynamic>? sentParameters;

    final repository = GardenRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls++;
      calledFunction = functionName;
      sentParameters = Map<String, dynamic>.from(parameters);
      return {
        'status': 'created',
        'garden_id': '55555555-5555-4555-8555-555555555555',
        'row_version': 1,
        'created_at': '2026-11-15T10:00:00+00:00',
      };
    }, _lease);

    final result = await repository.createGarden(
      profileId: _profileId,
      name: 'Orto test',
      description: 'Descrizione test',
      latitude: 45.0,
      longitude: 12.0,
      elevationM: 20,
      timezone: 'Europe/Rome',
      countryCode: 'IT',
      municipality: 'Comune test',
      locality: 'Localita test',
      streetAddress: 'Via test',
    );

    expect(rpcCalls, 1);
    expect(calledFunction, 'create_garden');
    expect(sentParameters, {
      'target_profile_id': _profileId,
      'target_client_id': _clientId,
      'target_session_id': _sessionId,
      'lock_token': 'token-esclusivamente-fittizio',
      'garden_name': 'Orto test',
      'garden_description': 'Descrizione test',
      'garden_latitude': 45.0,
      'garden_longitude': 12.0,
      'garden_elevation_m': 20,
      'garden_timezone': 'Europe/Rome',
      'garden_country_code': 'IT',
      'garden_municipality': 'Comune test',
      'garden_locality': 'Localita test',
      'garden_street_address': 'Via test',
    });

    expect(result, isA<GardenCreated>());
    final created = result as GardenCreated;
    expect(created.gardenId, '55555555-5555-4555-8555-555555555555');
    expect(created.rowVersion, 1);
    expect(created.createdAt, DateTime.utc(2026, 11, 15, 10));
  });

  group('createGarden RPC negative statuses', () {
    final cases = <String, Type>{
      'forbidden': CreateGardenForbidden,
      'write_forbidden': CreateGardenWriteForbidden,
      'invalid_input': CreateGardenInvalidInput,
      'duplicate_name': CreateGardenDuplicateName,
    };

    for (final entry in cases.entries) {
      test('maps ${entry.key} to ${entry.value}', () async {
        var rpcCalls = 0;

        final repository = GardenRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          rpcCalls++;
          expect(functionName, 'create_garden');
          return {'status': entry.key};
        }, _lease);

        final result = await repository.createGarden(
          profileId: _profileId,
          name: 'Orto test',
          timezone: 'Europe/Rome',
          countryCode: 'IT',
        );

        expect(result.runtimeType, entry.value);
        expect(rpcCalls, 1);
      });
    }
  });

  group('createGarden RPC protocol validation', () {
    final cases = <String, dynamic>{
      'null response': null,
      'unknown status': {'status': 'unexpected'},
      'missing garden id': {
        'status': 'created',
        'row_version': 1,
        'created_at': '2026-11-15T10:00:00+00:00',
      },
      'invalid row version': {
        'status': 'created',
        'garden_id': '55555555-5555-4555-8555-555555555555',
        'row_version': 0,
        'created_at': '2026-11-15T10:00:00+00:00',
      },
      'invalid creation date': {
        'status': 'created',
        'garden_id': '55555555-5555-4555-8555-555555555555',
        'row_version': 1,
        'created_at': 'not-a-date',
      },
      'invalid response structure': ['created'],
    };

    for (final entry in cases.entries) {
      test('rejects ${entry.key}', () async {
        var rpcCalls = 0;

        final repository = GardenRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          rpcCalls++;
          return entry.value;
        }, _lease);

        await expectLater(
          repository.createGarden(
            profileId: _profileId,
            name: 'Orto test',
            timezone: 'Europe/Rome',
            countryCode: 'IT',
          ),
          throwsA(isA<GardenWriteProtocolException>()),
        );

        expect(rpcCalls, 1);
      });
    }
  });
}
