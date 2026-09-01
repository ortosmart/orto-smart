import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/bed_write_result.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';
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

Future<List<Map<String, dynamic>>> _unusedLoader(String gardenId) async {
  throw StateError('Read loader must not be called during a write');
}

void main() {
  group('createBed write authority gate', () {
    test('rejects writes from a read-only repository', () async {
      final repository = BedRepository.withLoader(_unusedLoader);

      await expectLater(
        repository.createBed(
          gardenId: _gardenId,
          number: 1,
          widthCm: 90,
          lengthCm: 700,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
    });

    test('rejects a missing provider before invoking RPC', () async {
      var rpcCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls += 1;
        return null;
      });

      await expectLater(
        repository.createBed(
          gardenId: _gardenId,
          number: 1,
          widthCm: 90,
          lengthCm: 700,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(rpcCalls, 0);
    });

    test('propagates authority rejection before invoking RPC', () async {
      var rpcCalls = 0;
      var providerCalls = 0;
      const failure = ProfileWriteAuthorityUnavailableException();

      final repository = BedRepository.withProviders(
        _unusedLoader,
        (functionName, parameters) async {
          rpcCalls += 1;
          return null;
        },
        () {
          providerCalls += 1;
          throw failure;
        },
      );

      await expectLater(
        repository.createBed(
          gardenId: _gardenId,
          number: 1,
          widthCm: 90,
          lengthCm: 700,
        ),
        throwsA(same(failure)),
      );

      expect(providerCalls, 1);
      expect(rpcCalls, 0);
    });

    test('rejects a missing RPC invoker even with a lease', () async {
      var providerCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, null, () {
        providerCalls += 1;
        return _lease();
      });

      await expectLater(
        repository.createBed(
          gardenId: _gardenId,
          number: 1,
          widthCm: 90,
          lengthCm: 700,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(providerCalls, 1);
    });
  });
  test('createBed sends RPC parameters and maps the created result', () async {
    var rpcCalls = 0;
    var providerCalls = 0;
    String? calledFunction;
    Map<String, dynamic>? sentParameters;

    final repository = BedRepository.withProviders(
      _unusedLoader,
      (functionName, parameters) async {
        rpcCalls += 1;
        calledFunction = functionName;
        sentParameters = Map<String, dynamic>.from(parameters);

        return {
          'status': 'created',
          'bed_id': '55555555-5555-4555-8555-555555555555',
          'garden_id': _gardenId,
          'number': 1,
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-08-30T16:00:00+00:00',
          'geometry_id': '66666666-6666-4666-8666-666666666666',
          'width_cm': 90,
          'length_cm': 700,
          'valid_from': '2026-03-01',
          'valid_to': null,
          'geometry_row_version': 1,
          'geometry_created_at': '2026-08-30T16:00:00+00:00',
        };
      },
      () {
        providerCalls += 1;
        return _lease();
      },
    );

    final result = await repository.createBed(
      gardenId: _gardenId,
      number: 1,
      name: 'Aiuola di prova',
      notes: 'Note di prova',
      widthCm: 90,
      lengthCm: 700,
      validFrom: DateTime(2026, 3, 1),
    );

    expect(providerCalls, 1);
    expect(rpcCalls, 1);
    expect(calledFunction, 'create_bed');
    expect(sentParameters, {
      'target_profile_id': _profileId,
      'target_garden_id': _gardenId,
      'target_client_id': _clientId,
      'target_session_id': _sessionId,
      'lock_token': 'token-esclusivamente-fittizio',
      'bed_number': 1,
      'bed_name': 'Aiuola di prova',
      'bed_notes': 'Note di prova',
      'geometry_width_cm': 90,
      'geometry_length_cm': 700,
      'geometry_valid_from': '2026-03-01',
    });

    expect(result, isA<BedCreated>());

    final created = result as BedCreated;

    expect(created.bedId, '55555555-5555-4555-8555-555555555555');
    expect(created.gardenId, _gardenId);
    expect(created.number, 1);
    expect(created.isActive, isTrue);
    expect(created.rowVersion, 1);
    expect(created.createdAt, DateTime.utc(2026, 8, 30, 16));
    expect(created.createdAt.isUtc, isTrue);
    expect(created.geometryId, '66666666-6666-4666-8666-666666666666');
    expect(created.widthCm, 90);
    expect(created.lengthCm, 700);
    expect(created.validFrom, DateTime.utc(2026, 3, 1));
    expect(created.validFrom.isUtc, isTrue);
    expect(created.validTo, isNull);
    expect(created.geometryRowVersion, 1);
    expect(created.geometryCreatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(created.geometryCreatedAt.isUtc, isTrue);
  });
  group('createBed server rejections', () {
    final statusCases = <String, Matcher>{
      'forbidden': isA<CreateBedForbidden>(),
      'write_forbidden': isA<CreateBedWriteForbidden>(),
      'not_found': isA<CreateBedNotFound>(),
      'invalid_input': isA<CreateBedInvalidInput>(),
      'duplicate_number': isA<CreateBedDuplicateNumber>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key} without retrying', () async {
        var rpcCalls = 0;
        var providerCalls = 0;

        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async {
            rpcCalls += 1;
            return {'status': entry.key};
          },
          () {
            providerCalls += 1;
            return _lease();
          },
        );

        final result = await repository.createBed(
          gardenId: _gardenId,
          number: 1,
          widthCm: 90,
          lengthCm: 700,
        );

        expect(result, entry.value);
        expect(providerCalls, 1);
        expect(rpcCalls, 1);
      });
    }
  });
  group('createBed invalid response envelope', () {
    final invalidResponses = <String, Object?>{
      'null response': null,
      'string response': 'created',
      'list response': <Object?>[],
      'missing status': <String, dynamic>{},
      'null status': <String, dynamic>{'status': null},
      'non-string status': <String, dynamic>{'status': 1},
      'unknown status': <String, dynamic>{'status': 'unexpected'},
      'status from another operation': <String, dynamic>{'status': 'updated'},
      'non-string map key': <Object, Object?>{1: 'created'},
    };

    for (final entry in invalidResponses.entries) {
      test('rejects ${entry.key}', () async {
        var rpcCalls = 0;

        final repository = BedRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          rpcCalls += 1;
          return entry.value;
        }, _lease);

        await expectLater(
          repository.createBed(
            gardenId: _gardenId,
            number: 1,
            widthCm: 90,
            lengthCm: 700,
          ),
          throwsA(isA<BedWriteProtocolException>()),
        );

        expect(rpcCalls, 1);
      });
    }
  });
  group('createBed invalid created payload', () {
    Map<String, dynamic> validPayload() {
      return {
        'status': 'created',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'number': 1,
        'is_active': true,
        'row_version': 1,
        'created_at': '2026-08-30T16:00:00+00:00',
        'geometry_id': '66666666-6666-4666-8666-666666666666',
        'width_cm': 90,
        'length_cm': 700,
        'valid_from': '2026-03-01',
        'valid_to': null,
        'geometry_row_version': 1,
        'geometry_created_at': '2026-08-30T16:00:00+00:00',
      };
    }

    final invalidCases = <String, Map<String, dynamic>>{
      'empty bed id': {'bed_id': ''},
      'blank garden id': {'garden_id': '   '},
      'empty geometry id': {'geometry_id': ''},
      'zero number': {'number': 0},
      'non-integer number': {'number': 1.5},
      'inactive new bed': {'is_active': false},
      'non-boolean active state': {'is_active': 'true'},
      'zero bed version': {'row_version': 0},
      'negative geometry version': {'geometry_row_version': -1},
      'zero width': {'width_cm': 0},
      'negative length': {'length_cm': -1},
      'invalid creation timestamp': {'created_at': 'invalid'},
      'invalid geometry timestamp': {'geometry_created_at': 'invalid'},
      'impossible civil date': {'valid_from': '2026-02-29'},
      'timestamp instead of civil date': {'valid_from': '2026-03-01T00:00:00Z'},
      'closed initial geometry': {'valid_to': '2026-06-01'},
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () async {
        final payload = validPayload()..addAll(entry.value);

        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async => payload,
          _lease,
        );

        await expectLater(
          repository.createBed(
            gardenId: _gardenId,
            number: 1,
            widthCm: 90,
            lengthCm: 700,
          ),
          throwsA(isA<BedWriteProtocolException>()),
        );
      });
    }

    for (final key in validPayload().keys.where((key) => key != 'status')) {
      test('rejects missing $key', () async {
        final payload = validPayload()..remove(key);

        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async => payload,
          _lease,
        );

        await expectLater(
          repository.createBed(
            gardenId: _gardenId,
            number: 1,
            widthCm: 90,
            lengthCm: 700,
          ),
          throwsA(isA<BedWriteProtocolException>()),
        );
      });
    }
  });
  test('createBed sends null optional values to the server', () async {
    Map<String, dynamic>? sentParameters;

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      sentParameters = Map<String, dynamic>.from(parameters);
      return {'status': 'duplicate_number'};
    }, _lease);

    final result = await repository.createBed(
      gardenId: _gardenId,
      number: 1,
      widthCm: 90,
      lengthCm: 700,
    );

    expect(result, isA<CreateBedDuplicateNumber>());
    expect(sentParameters, {
      'target_profile_id': _profileId,
      'target_garden_id': _gardenId,
      'target_client_id': _clientId,
      'target_session_id': _sessionId,
      'lock_token': 'token-esclusivamente-fittizio',
      'bed_number': 1,
      'bed_name': null,
      'bed_notes': null,
      'geometry_width_cm': 90,
      'geometry_length_cm': 700,
      'geometry_valid_from': null,
    });
  });

  test('createBed propagates RPC failure without retrying', () async {
    var rpcCalls = 0;
    final failure = StateError('Synthetic RPC failure');

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;
      throw failure;
    }, _lease);

    await expectLater(
      repository.createBed(
        gardenId: _gardenId,
        number: 1,
        widthCm: 90,
        lengthCm: 700,
      ),
      throwsA(same(failure)),
    );

    expect(rpcCalls, 1);
  });
  group('updateBed write authority gate', () {
    const bedId = '55555555-5555-4555-8555-555555555555';

    test('rejects writes from a read-only repository', () async {
      final repository = BedRepository.withLoader(_unusedLoader);

      await expectLater(
        repository.updateBed(bedId: bedId, expectedRowVersion: 1, number: 2),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
    });

    test('rejects a missing provider before invoking RPC', () async {
      var rpcCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls += 1;
        return null;
      });

      await expectLater(
        repository.updateBed(bedId: bedId, expectedRowVersion: 1, number: 2),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(rpcCalls, 0);
    });

    test('propagates authority rejection before invoking RPC', () async {
      var rpcCalls = 0;
      var providerCalls = 0;
      const failure = ProfileWriteAuthorityUnavailableException();

      final repository = BedRepository.withProviders(
        _unusedLoader,
        (functionName, parameters) async {
          rpcCalls += 1;
          return null;
        },
        () {
          providerCalls += 1;
          throw failure;
        },
      );

      await expectLater(
        repository.updateBed(bedId: bedId, expectedRowVersion: 1, number: 2),
        throwsA(same(failure)),
      );

      expect(providerCalls, 1);
      expect(rpcCalls, 0);
    });

    test('rejects a missing RPC invoker even with a lease', () async {
      var providerCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, null, () {
        providerCalls += 1;
        return _lease();
      });

      await expectLater(
        repository.updateBed(bedId: bedId, expectedRowVersion: 1, number: 2),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(providerCalls, 1);
    });
  });
  test('updateBed sends RPC parameters and maps the updated result', () async {
    const bedId = '55555555-5555-4555-8555-555555555555';
    var rpcCalls = 0;
    var providerCalls = 0;
    String? calledFunction;
    Map<String, dynamic>? sentParameters;

    final repository = BedRepository.withProviders(
      _unusedLoader,
      (functionName, parameters) async {
        rpcCalls += 1;
        calledFunction = functionName;
        sentParameters = Map<String, dynamic>.from(parameters);

        return {
          'status': 'updated',
          'bed_id': bedId,
          'garden_id': _gardenId,
          'number': 2,
          'row_version': 8,
          'updated_at': '2026-08-30T18:00:00+02:00',
        };
      },
      () {
        providerCalls += 1;
        return _lease();
      },
    );

    final result = await repository.updateBed(
      bedId: bedId,
      expectedRowVersion: 7,
      number: 2,
      name: 'Nome aggiornato',
      notes: 'Note aggiornate',
    );

    expect(providerCalls, 1);
    expect(rpcCalls, 1);
    expect(calledFunction, 'update_bed');
    expect(sentParameters, {
      'target_profile_id': _profileId,
      'target_bed_id': bedId,
      'expected_row_version': 7,
      'target_client_id': _clientId,
      'target_session_id': _sessionId,
      'lock_token': 'token-esclusivamente-fittizio',
      'bed_number': 2,
      'bed_name': 'Nome aggiornato',
      'bed_notes': 'Note aggiornate',
    });

    expect(result, isA<BedUpdated>());

    final updated = result as BedUpdated;

    expect(updated.bedId, bedId);
    expect(updated.gardenId, _gardenId);
    expect(updated.number, 2);
    expect(updated.rowVersion, 8);
    expect(updated.updatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(updated.updatedAt.isUtc, isTrue);
  });
  test('updateBed maps unchanged and sends null optional fields', () async {
    const bedId = '55555555-5555-4555-8555-555555555555';
    var rpcCalls = 0;
    Map<String, dynamic>? sentParameters;

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;
      sentParameters = Map<String, dynamic>.from(parameters);

      return {
        'status': 'unchanged',
        'bed_id': bedId,
        'garden_id': _gardenId,
        'row_version': 7,
        'updated_at': '2026-08-30T16:00:00+00:00',
      };
    }, _lease);

    final result = await repository.updateBed(
      bedId: bedId,
      expectedRowVersion: 7,
      number: 2,
    );

    expect(rpcCalls, 1);
    expect(sentParameters, {
      'target_profile_id': _profileId,
      'target_bed_id': bedId,
      'expected_row_version': 7,
      'target_client_id': _clientId,
      'target_session_id': _sessionId,
      'lock_token': 'token-esclusivamente-fittizio',
      'bed_number': 2,
      'bed_name': null,
      'bed_notes': null,
    });

    expect(result, isA<UpdateBedUnchanged>());

    final unchanged = result as UpdateBedUnchanged;

    expect(unchanged.bedId, bedId);
    expect(unchanged.gardenId, _gardenId);
    expect(unchanged.rowVersion, 7);
    expect(unchanged.updatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(unchanged.updatedAt.isUtc, isTrue);
  });

  test('updateBed maps version conflict without retrying', () async {
    const bedId = '55555555-5555-4555-8555-555555555555';
    var rpcCalls = 0;

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;

      return {
        'status': 'version_conflict',
        'bed_id': bedId,
        'expected_row_version': 7,
        'current_row_version': 8,
        'updated_at': '2026-08-30T18:00:00+02:00',
      };
    }, _lease);

    final result = await repository.updateBed(
      bedId: bedId,
      expectedRowVersion: 7,
      number: 2,
    );

    expect(rpcCalls, 1);
    expect(result, isA<UpdateBedVersionConflict>());

    final conflict = result as UpdateBedVersionConflict;

    expect(conflict.bedId, bedId);
    expect(conflict.expectedRowVersion, 7);
    expect(conflict.currentRowVersion, 8);
    expect(conflict.updatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(conflict.updatedAt.isUtc, isTrue);
  });
  group('updateBed server rejections', () {
    final statusCases = <String, Matcher>{
      'forbidden': isA<UpdateBedForbidden>(),
      'write_forbidden': isA<UpdateBedWriteForbidden>(),
      'not_found': isA<UpdateBedNotFound>(),
      'invalid_input': isA<UpdateBedInvalidInput>(),
      'duplicate_number': isA<UpdateBedDuplicateNumber>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key} without retrying', () async {
        var rpcCalls = 0;

        final repository = BedRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          rpcCalls += 1;
          return {'status': entry.key};
        }, _lease);

        final result = await repository.updateBed(
          bedId: '55555555-5555-4555-8555-555555555555',
          expectedRowVersion: 7,
          number: 2,
        );

        expect(result, entry.value);
        expect(rpcCalls, 1);
      });
    }
  });

  test('updateBed propagates RPC failure without retrying', () async {
    var rpcCalls = 0;
    final failure = StateError('Synthetic RPC failure');

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;
      throw failure;
    }, _lease);

    await expectLater(
      repository.updateBed(
        bedId: '55555555-5555-4555-8555-555555555555',
        expectedRowVersion: 7,
        number: 2,
      ),
      throwsA(same(failure)),
    );

    expect(rpcCalls, 1);
  });
  group('updateBed invalid responses', () {
    final invalidEnvelopes = <String, Object?>{
      'null response': null,
      'string response': 'updated',
      'list response': <Object?>[],
      'missing status': <String, dynamic>{},
      'null status': <String, dynamic>{'status': null},
      'non-string status': <String, dynamic>{'status': 1},
      'unknown status': <String, dynamic>{'status': 'unexpected'},
      'status from another operation': <String, dynamic>{'status': 'created'},
      'non-string map key': <Object, Object?>{1: 'updated'},
    };

    for (final entry in invalidEnvelopes.entries) {
      test('rejects ${entry.key}', () async {
        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async => entry.value,
          _lease,
        );

        await expectLater(
          repository.updateBed(
            bedId: '55555555-5555-4555-8555-555555555555',
            expectedRowVersion: 7,
            number: 2,
          ),
          throwsA(isA<BedWriteProtocolException>()),
        );
      });
    }

    final payloads = <String, Map<String, dynamic>>{
      'updated': {
        'status': 'updated',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'number': 2,
        'row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
      },
      'unchanged': {
        'status': 'unchanged',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'row_version': 7,
        'updated_at': '2026-08-30T16:00:00+00:00',
      },
      'version_conflict': {
        'status': 'version_conflict',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'expected_row_version': 7,
        'current_row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
      },
    };

    for (final entry in payloads.entries) {
      for (final key in entry.value.keys.where((key) => key != 'status')) {
        test('rejects ${entry.key} missing $key', () async {
          final payload = Map<String, dynamic>.from(entry.value)..remove(key);

          final repository = BedRepository.withProviders(
            _unusedLoader,
            (functionName, parameters) async => payload,
            _lease,
          );

          await expectLater(
            repository.updateBed(
              bedId: '55555555-5555-4555-8555-555555555555',
              expectedRowVersion: 7,
              number: 2,
            ),
            throwsA(isA<BedWriteProtocolException>()),
          );
        });
      }

      for (final field in entry.value.entries.where(
        (field) => field.key != 'status',
      )) {
        test('rejects ${entry.key} invalid ${field.key}', () async {
          final Object invalidValue;

          if (field.value is int) {
            invalidValue = 0;
          } else if (field.key == 'updated_at') {
            invalidValue = 'invalid';
          } else {
            invalidValue = '   ';
          }

          final payload = Map<String, dynamic>.from(entry.value)
            ..[field.key] = invalidValue;

          final repository = BedRepository.withProviders(
            _unusedLoader,
            (functionName, parameters) async => payload,
            _lease,
          );

          await expectLater(
            repository.updateBed(
              bedId: '55555555-5555-4555-8555-555555555555',
              expectedRowVersion: 7,
              number: 2,
            ),
            throwsA(isA<BedWriteProtocolException>()),
          );
        });
      }
    }
  });
  group('setBedActive write authority gate', () {
    const bedId = '55555555-5555-4555-8555-555555555555';

    test('rejects writes from a read-only repository', () async {
      final repository = BedRepository.withLoader(_unusedLoader);

      await expectLater(
        repository.setBedActive(
          bedId: bedId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
    });

    test('rejects a missing provider before invoking RPC', () async {
      var rpcCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls += 1;
        return null;
      });

      await expectLater(
        repository.setBedActive(
          bedId: bedId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(rpcCalls, 0);
    });

    test('propagates authority rejection before invoking RPC', () async {
      var rpcCalls = 0;
      var providerCalls = 0;
      const failure = ProfileWriteAuthorityUnavailableException();

      final repository = BedRepository.withProviders(
        _unusedLoader,
        (functionName, parameters) async {
          rpcCalls += 1;
          return null;
        },
        () {
          providerCalls += 1;
          throw failure;
        },
      );

      await expectLater(
        repository.setBedActive(
          bedId: bedId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(same(failure)),
      );

      expect(providerCalls, 1);
      expect(rpcCalls, 0);
    });

    test('rejects a missing RPC invoker even with a lease', () async {
      var providerCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, null, () {
        providerCalls += 1;
        return _lease();
      });

      await expectLater(
        repository.setBedActive(
          bedId: bedId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(providerCalls, 1);
    });
  });
  group('setBedActive successful update', () {
    for (final active in [false, true]) {
      test('sends and maps isActive=$active', () async {
        const bedId = '55555555-5555-4555-8555-555555555555';
        var rpcCalls = 0;
        var providerCalls = 0;
        String? calledFunction;
        Map<String, dynamic>? sentParameters;

        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async {
            rpcCalls += 1;
            calledFunction = functionName;
            sentParameters = Map<String, dynamic>.from(parameters);

            return {
              'status': 'updated',
              'bed_id': bedId,
              'garden_id': _gardenId,
              'is_active': active,
              'row_version': 8,
              'updated_at': '2026-08-30T18:00:00+02:00',
            };
          },
          () {
            providerCalls += 1;
            return _lease();
          },
        );

        final result = await repository.setBedActive(
          bedId: bedId,
          expectedRowVersion: 7,
          isActive: active,
        );

        expect(providerCalls, 1);
        expect(rpcCalls, 1);
        expect(calledFunction, 'set_bed_active');
        expect(sentParameters, {
          'target_profile_id': _profileId,
          'target_bed_id': bedId,
          'expected_row_version': 7,
          'target_client_id': _clientId,
          'target_session_id': _sessionId,
          'lock_token': 'token-esclusivamente-fittizio',
          'bed_is_active': active,
        });

        expect(result, isA<BedActiveUpdated>());

        final updated = result as BedActiveUpdated;

        expect(updated.bedId, bedId);
        expect(updated.gardenId, _gardenId);
        expect(updated.isActive, active);
        expect(updated.rowVersion, 8);
        expect(updated.updatedAt, DateTime.utc(2026, 8, 30, 16));
        expect(updated.updatedAt.isUtc, isTrue);
      });
    }
  });
  group('setBedActive unchanged', () {
    for (final active in [false, true]) {
      test('maps unchanged with isActive=$active', () async {
        const bedId = '55555555-5555-4555-8555-555555555555';
        var rpcCalls = 0;

        final repository = BedRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          rpcCalls += 1;

          return {
            'status': 'unchanged',
            'bed_id': bedId,
            'garden_id': _gardenId,
            'is_active': active,
            'row_version': 7,
            'updated_at': '2026-08-30T18:00:00+02:00',
          };
        }, _lease);

        final result = await repository.setBedActive(
          bedId: bedId,
          expectedRowVersion: 7,
          isActive: active,
        );

        expect(rpcCalls, 1);
        expect(result, isA<SetBedActiveUnchanged>());

        final unchanged = result as SetBedActiveUnchanged;

        expect(unchanged.bedId, bedId);
        expect(unchanged.gardenId, _gardenId);
        expect(unchanged.isActive, active);
        expect(unchanged.rowVersion, 7);
        expect(unchanged.updatedAt, DateTime.utc(2026, 8, 30, 16));
        expect(unchanged.updatedAt.isUtc, isTrue);
      });
    }
  });

  test('setBedActive maps version conflict without retrying', () async {
    const bedId = '55555555-5555-4555-8555-555555555555';
    var rpcCalls = 0;

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;

      return {
        'status': 'version_conflict',
        'bed_id': bedId,
        'expected_row_version': 7,
        'current_row_version': 8,
        'updated_at': '2026-08-30T18:00:00+02:00',
      };
    }, _lease);

    final result = await repository.setBedActive(
      bedId: bedId,
      expectedRowVersion: 7,
      isActive: false,
    );

    expect(rpcCalls, 1);
    expect(result, isA<SetBedActiveVersionConflict>());

    final conflict = result as SetBedActiveVersionConflict;

    expect(conflict.bedId, bedId);
    expect(conflict.expectedRowVersion, 7);
    expect(conflict.currentRowVersion, 8);
    expect(conflict.updatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(conflict.updatedAt.isUtc, isTrue);
  });
  group('setBedActive server rejections', () {
    final statusCases = <String, Matcher>{
      'forbidden': isA<SetBedActiveForbidden>(),
      'write_forbidden': isA<SetBedActiveWriteForbidden>(),
      'not_found': isA<SetBedActiveNotFound>(),
      'invalid_input': isA<SetBedActiveInvalidInput>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key} without retrying', () async {
        var rpcCalls = 0;

        final repository = BedRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          rpcCalls += 1;
          return {'status': entry.key};
        }, _lease);

        final result = await repository.setBedActive(
          bedId: '55555555-5555-4555-8555-555555555555',
          expectedRowVersion: 7,
          isActive: false,
        );

        expect(result, entry.value);
        expect(rpcCalls, 1);
      });
    }
  });

  test('setBedActive propagates RPC failure without retrying', () async {
    var rpcCalls = 0;
    final failure = StateError('Synthetic RPC failure');

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;
      throw failure;
    }, _lease);

    await expectLater(
      repository.setBedActive(
        bedId: '55555555-5555-4555-8555-555555555555',
        expectedRowVersion: 7,
        isActive: false,
      ),
      throwsA(same(failure)),
    );

    expect(rpcCalls, 1);
  });
  group('setBedActive invalid responses', () {
    final invalidEnvelopes = <String, Object?>{
      'null response': null,
      'string response': 'updated',
      'list response': <Object?>[],
      'missing status': <String, dynamic>{},
      'null status': <String, dynamic>{'status': null},
      'non-string status': <String, dynamic>{'status': 1},
      'unknown status': <String, dynamic>{'status': 'unexpected'},
      'status from another operation': <String, dynamic>{'status': 'created'},
      'non-string map key': <Object, Object?>{1: 'updated'},
    };

    for (final entry in invalidEnvelopes.entries) {
      test('rejects ${entry.key}', () async {
        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async => entry.value,
          _lease,
        );

        await expectLater(
          repository.setBedActive(
            bedId: '55555555-5555-4555-8555-555555555555',
            expectedRowVersion: 7,
            isActive: false,
          ),
          throwsA(isA<BedWriteProtocolException>()),
        );
      });
    }

    final payloads = <String, Map<String, dynamic>>{
      'updated': {
        'status': 'updated',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'is_active': false,
        'row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
      },
      'unchanged': {
        'status': 'unchanged',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'is_active': false,
        'row_version': 7,
        'updated_at': '2026-08-30T16:00:00+00:00',
      },
      'version_conflict': {
        'status': 'version_conflict',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'expected_row_version': 7,
        'current_row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
      },
    };

    for (final entry in payloads.entries) {
      for (final key in entry.value.keys.where((key) => key != 'status')) {
        test('rejects ${entry.key} missing $key', () async {
          final payload = Map<String, dynamic>.from(entry.value)..remove(key);

          final repository = BedRepository.withProviders(
            _unusedLoader,
            (functionName, parameters) async => payload,
            _lease,
          );

          await expectLater(
            repository.setBedActive(
              bedId: '55555555-5555-4555-8555-555555555555',
              expectedRowVersion: 7,
              isActive: false,
            ),
            throwsA(isA<BedWriteProtocolException>()),
          );
        });
      }

      for (final field in entry.value.entries.where(
        (field) => field.key != 'status',
      )) {
        test('rejects ${entry.key} invalid ${field.key}', () async {
          final Object invalidValue;

          if (field.value is bool) {
            invalidValue = 'false';
          } else if (field.value is int) {
            invalidValue = 0;
          } else if (field.key == 'updated_at') {
            invalidValue = 'invalid';
          } else {
            invalidValue = '   ';
          }

          final payload = Map<String, dynamic>.from(entry.value)
            ..[field.key] = invalidValue;

          final repository = BedRepository.withProviders(
            _unusedLoader,
            (functionName, parameters) async => payload,
            _lease,
          );

          await expectLater(
            repository.setBedActive(
              bedId: '55555555-5555-4555-8555-555555555555',
              expectedRowVersion: 7,
              isActive: false,
            ),
            throwsA(isA<BedWriteProtocolException>()),
          );
        });
      }
    }

    for (final status in ['updated', 'unchanged']) {
      for (final invalidState in <Object?>[null, 0, 1]) {
        test('rejects $status with is_active=$invalidState', () async {
          final payload = Map<String, dynamic>.from(payloads[status]!)
            ..['is_active'] = invalidState;

          final repository = BedRepository.withProviders(
            _unusedLoader,
            (functionName, parameters) async => payload,
            _lease,
          );

          await expectLater(
            repository.setBedActive(
              bedId: '55555555-5555-4555-8555-555555555555',
              expectedRowVersion: 7,
              isActive: false,
            ),
            throwsA(isA<BedWriteProtocolException>()),
          );
        });
      }
    }
  });
  group('changeBedGeometry write authority gate', () {
    const bedId = '55555555-5555-4555-8555-555555555555';

    test('rejects writes from a read-only repository', () async {
      final repository = BedRepository.withLoader(_unusedLoader);

      await expectLater(
        repository.changeBedGeometry(
          bedId: bedId,
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
    });

    test('rejects a missing provider before invoking RPC', () async {
      var rpcCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls += 1;
        return null;
      });

      await expectLater(
        repository.changeBedGeometry(
          bedId: bedId,
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(rpcCalls, 0);
    });

    test('propagates authority rejection before invoking RPC', () async {
      var rpcCalls = 0;
      var providerCalls = 0;
      const failure = ProfileWriteAuthorityUnavailableException();

      final repository = BedRepository.withProviders(
        _unusedLoader,
        (functionName, parameters) async {
          rpcCalls += 1;
          return null;
        },
        () {
          providerCalls += 1;
          throw failure;
        },
      );

      await expectLater(
        repository.changeBedGeometry(
          bedId: bedId,
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
        ),
        throwsA(same(failure)),
      );

      expect(providerCalls, 1);
      expect(rpcCalls, 0);
    });

    test('rejects a missing RPC invoker even with a lease', () async {
      var providerCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, null, () {
        providerCalls += 1;
        return _lease();
      });

      await expectLater(
        repository.changeBedGeometry(
          bedId: bedId,
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(providerCalls, 1);
    });
  });
  group('changeBedGeometry successful change', () {
    for (final endDate in <String?>[null, '2026-08-01']) {
      test('maps changed geometry with valid_to=$endDate', () async {
        const bedId = '55555555-5555-4555-8555-555555555555';
        const geometryId = '66666666-6666-4666-8666-666666666666';
        const previousId = '77777777-7777-4777-8777-777777777777';

        var rpcCalls = 0;
        var providerCalls = 0;
        String? calledFunction;
        Map<String, dynamic>? sentParameters;

        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async {
            rpcCalls += 1;
            calledFunction = functionName;
            sentParameters = Map<String, dynamic>.from(parameters);

            return {
              'status': 'changed',
              'bed_id': bedId,
              'garden_id': _gardenId,
              'row_version': 8,
              'updated_at': '2026-08-30T18:00:00+02:00',
              'geometry_id': geometryId,
              'width_cm': 100,
              'length_cm': 700,
              'valid_from': '2026-06-01',
              'valid_to': endDate,
              'geometry_row_version': 1,
              'geometry_created_at': '2026-08-30T18:00:00+02:00',
              'previous_geometry_id': previousId,
              'previous_geometry_valid_to': '2026-06-01',
              'previous_geometry_row_version': 4,
              'previous_geometry_updated_at': '2026-08-30T18:00:00+02:00',
            };
          },
          () {
            providerCalls += 1;
            return _lease();
          },
        );

        final result = await repository.changeBedGeometry(
          bedId: bedId,
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
        );

        expect(providerCalls, 1);
        expect(rpcCalls, 1);
        expect(calledFunction, 'change_bed_geometry');
        expect(sentParameters, {
          'target_profile_id': _profileId,
          'target_bed_id': bedId,
          'expected_row_version': 7,
          'target_client_id': _clientId,
          'target_session_id': _sessionId,
          'lock_token': 'token-esclusivamente-fittizio',
          'geometry_width_cm': 100,
          'geometry_length_cm': 700,
          'geometry_valid_from': '2026-06-01',
        });

        expect(result, isA<BedGeometryChanged>());

        final changed = result as BedGeometryChanged;

        expect(changed.bedId, bedId);
        expect(changed.gardenId, _gardenId);
        expect(changed.rowVersion, 8);
        expect(changed.updatedAt, DateTime.utc(2026, 8, 30, 16));
        expect(changed.updatedAt.isUtc, isTrue);
        expect(changed.geometryId, geometryId);
        expect(changed.widthCm, 100);
        expect(changed.lengthCm, 700);
        expect(changed.validFrom, DateTime.utc(2026, 6, 1));
        expect(changed.validFrom.isUtc, isTrue);
        expect(
          changed.validTo,
          endDate == null ? null : DateTime.utc(2026, 8, 1),
        );
        if (changed.validTo != null) {
          expect(changed.validTo!.isUtc, isTrue);
        }
        expect(changed.geometryRowVersion, 1);
        expect(changed.geometryCreatedAt, DateTime.utc(2026, 8, 30, 16));
        expect(changed.geometryCreatedAt.isUtc, isTrue);

        final previous = changed.previousGeometry;

        expect(previous.geometryId, previousId);
        expect(previous.validTo, changed.validFrom);
        expect(previous.validTo.isUtc, isTrue);
        expect(previous.rowVersion, 4);
        expect(previous.updatedAt, DateTime.utc(2026, 8, 30, 16));
        expect(previous.updatedAt.isUtc, isTrue);
      });
    }
  });
  group('changeBedGeometry unchanged and correction required', () {
    for (final status in ['unchanged', 'correction_required']) {
      test('maps $status without another RPC', () async {
        const bedId = '55555555-5555-4555-8555-555555555555';
        const geometryId = '66666666-6666-4666-8666-666666666666';
        final calledFunctions = <String>[];

        final repository = BedRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          calledFunctions.add(functionName);

          return {
            'status': status,
            'bed_id': bedId,
            'garden_id': _gardenId,
            'row_version': 7,
            'updated_at': '2026-08-30T18:00:00+02:00',
            'geometry_id': geometryId,
            'geometry_row_version': 3,
            'geometry_updated_at': '2026-08-29T17:00:00+02:00',
          };
        }, _lease);

        final result = await repository.changeBedGeometry(
          bedId: bedId,
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
        );

        expect(calledFunctions, ['change_bed_geometry']);

        if (status == 'unchanged') {
          expect(result, isA<ChangeBedGeometryUnchanged>());

          final unchanged = result as ChangeBedGeometryUnchanged;

          expect(unchanged.bedId, bedId);
          expect(unchanged.gardenId, _gardenId);
          expect(unchanged.rowVersion, 7);
          expect(unchanged.updatedAt, DateTime.utc(2026, 8, 30, 16));
          expect(unchanged.updatedAt.isUtc, isTrue);
          expect(unchanged.geometryId, geometryId);
          expect(unchanged.geometryRowVersion, 3);
          expect(unchanged.geometryUpdatedAt, DateTime.utc(2026, 8, 29, 15));
          expect(unchanged.geometryUpdatedAt.isUtc, isTrue);
        } else {
          expect(result, isA<BedGeometryCorrectionRequired>());

          final correction = result as BedGeometryCorrectionRequired;

          expect(correction.bedId, bedId);
          expect(correction.gardenId, _gardenId);
          expect(correction.rowVersion, 7);
          expect(correction.updatedAt, DateTime.utc(2026, 8, 30, 16));
          expect(correction.updatedAt.isUtc, isTrue);
          expect(correction.geometryId, geometryId);
          expect(correction.geometryRowVersion, 3);
          expect(correction.geometryUpdatedAt, DateTime.utc(2026, 8, 29, 15));
          expect(correction.geometryUpdatedAt.isUtc, isTrue);
        }
      });
    }
  });

  test('changeBedGeometry maps version conflict without retrying', () async {
    const bedId = '55555555-5555-4555-8555-555555555555';
    var rpcCalls = 0;

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;

      return {
        'status': 'version_conflict',
        'bed_id': bedId,
        'expected_row_version': 7,
        'current_row_version': 8,
        'updated_at': '2026-08-30T18:00:00+02:00',
      };
    }, _lease);

    final result = await repository.changeBedGeometry(
      bedId: bedId,
      expectedRowVersion: 7,
      widthCm: 100,
      lengthCm: 700,
      validFrom: DateTime(2026, 6, 1),
    );

    expect(rpcCalls, 1);
    expect(result, isA<ChangeBedGeometryVersionConflict>());

    final conflict = result as ChangeBedGeometryVersionConflict;

    expect(conflict.bedId, bedId);
    expect(conflict.expectedRowVersion, 7);
    expect(conflict.currentRowVersion, 8);
    expect(conflict.updatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(conflict.updatedAt.isUtc, isTrue);
  });
  group('changeBedGeometry server rejections', () {
    final statusCases = <String, Matcher>{
      'forbidden': isA<ChangeBedGeometryForbidden>(),
      'write_forbidden': isA<ChangeBedGeometryWriteForbidden>(),
      'not_found': isA<ChangeBedGeometryNotFound>(),
      'invalid_input': isA<ChangeBedGeometryInvalidInput>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key} without retrying', () async {
        var rpcCalls = 0;

        final repository = BedRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          rpcCalls += 1;
          return {'status': entry.key};
        }, _lease);

        final result = await repository.changeBedGeometry(
          bedId: '55555555-5555-4555-8555-555555555555',
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
        );

        expect(result, entry.value);
        expect(rpcCalls, 1);
      });
    }
  });

  test('changeBedGeometry propagates RPC failure without retrying', () async {
    var rpcCalls = 0;
    final failure = StateError('Synthetic RPC failure');

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;
      throw failure;
    }, _lease);

    await expectLater(
      repository.changeBedGeometry(
        bedId: '55555555-5555-4555-8555-555555555555',
        expectedRowVersion: 7,
        widthCm: 100,
        lengthCm: 700,
        validFrom: DateTime(2026, 6, 1),
      ),
      throwsA(same(failure)),
    );

    expect(rpcCalls, 1);
  });
  group('changeBedGeometry invalid changed payload', () {
    Map<String, dynamic> validPayload() {
      return {
        'status': 'changed',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
        'geometry_id': '66666666-6666-4666-8666-666666666666',
        'width_cm': 100,
        'length_cm': 700,
        'valid_from': '2026-06-01',
        'valid_to': null,
        'geometry_row_version': 1,
        'geometry_created_at': '2026-08-30T16:00:00+00:00',
        'previous_geometry_id': '77777777-7777-4777-8777-777777777777',
        'previous_geometry_valid_to': '2026-06-01',
        'previous_geometry_row_version': 4,
        'previous_geometry_updated_at': '2026-08-30T16:00:00+00:00',
      };
    }

    final invalidCases = <String, Map<String, dynamic>>{
      'empty bed id': {'bed_id': ''},
      'blank garden id': {'garden_id': '   '},
      'empty geometry id': {'geometry_id': ''},
      'empty previous geometry id': {'previous_geometry_id': ''},
      'zero bed version': {'row_version': 0},
      'zero geometry version': {'geometry_row_version': 0},
      'zero previous version': {'previous_geometry_row_version': 0},
      'zero width': {'width_cm': 0},
      'negative length': {'length_cm': -1},
      'invalid bed timestamp': {'updated_at': 'invalid'},
      'invalid geometry timestamp': {'geometry_created_at': 'invalid'},
      'invalid previous timestamp': {'previous_geometry_updated_at': 'invalid'},
      'impossible start date': {'valid_from': '2026-06-31'},
      'impossible end date': {'valid_to': '2026-08-32'},
      'empty interval': {'valid_to': '2026-06-01'},
      'inverted interval': {'valid_to': '2026-05-31'},
      'missing shared boundary': {'previous_geometry_valid_to': '2026-05-31'},
      'overlapping shared boundary': {
        'previous_geometry_valid_to': '2026-06-02',
      },
      'null previous end date': {'previous_geometry_valid_to': null},
      'timestamp instead of previous civil date': {
        'previous_geometry_valid_to': '2026-06-01T00:00:00Z',
      },
      'same geometry identity': {
        'previous_geometry_id': '66666666-6666-4666-8666-666666666666',
      },
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () async {
        final payload = validPayload()..addAll(entry.value);

        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async => payload,
          _lease,
        );

        await expectLater(
          repository.changeBedGeometry(
            bedId: '55555555-5555-4555-8555-555555555555',
            expectedRowVersion: 7,
            widthCm: 100,
            lengthCm: 700,
            validFrom: DateTime(2026, 6, 1),
          ),
          throwsA(isA<BedWriteProtocolException>()),
        );
      });
    }

    for (final key in validPayload().keys.where((key) => key != 'status')) {
      test('rejects missing $key', () async {
        final payload = validPayload()..remove(key);

        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async => payload,
          _lease,
        );

        await expectLater(
          repository.changeBedGeometry(
            bedId: '55555555-5555-4555-8555-555555555555',
            expectedRowVersion: 7,
            widthCm: 100,
            lengthCm: 700,
            validFrom: DateTime(2026, 6, 1),
          ),
          throwsA(isA<BedWriteProtocolException>()),
        );
      });
    }
  });
  group('changeBedGeometry invalid responses', () {
    final invalidEnvelopes = <String, Object?>{
      'null response': null,
      'string response': 'changed',
      'list response': <Object?>[],
      'missing status': <String, dynamic>{},
      'null status': <String, dynamic>{'status': null},
      'non-string status': <String, dynamic>{'status': 1},
      'unknown status': <String, dynamic>{'status': 'unexpected'},
      'status from another operation': <String, dynamic>{'status': 'corrected'},
      'non-string map key': <Object, Object?>{1: 'changed'},
    };

    Future<void> expectProtocolError(Object? response) async {
      var rpcCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls += 1;
        return response;
      }, _lease);

      await expectLater(
        repository.changeBedGeometry(
          bedId: '55555555-5555-4555-8555-555555555555',
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
        ),
        throwsA(isA<BedWriteProtocolException>()),
      );

      expect(rpcCalls, 1);
    }

    for (final entry in invalidEnvelopes.entries) {
      test('rejects ${entry.key}', () async {
        await expectProtocolError(entry.value);
      });
    }

    final payloads = <String, Map<String, dynamic>>{
      'unchanged': {
        'status': 'unchanged',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'row_version': 7,
        'updated_at': '2026-08-30T16:00:00+00:00',
        'geometry_id': '66666666-6666-4666-8666-666666666666',
        'geometry_row_version': 3,
        'geometry_updated_at': '2026-08-29T15:00:00+00:00',
      },
      'correction_required': {
        'status': 'correction_required',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'row_version': 7,
        'updated_at': '2026-08-30T16:00:00+00:00',
        'geometry_id': '66666666-6666-4666-8666-666666666666',
        'geometry_row_version': 3,
        'geometry_updated_at': '2026-08-29T15:00:00+00:00',
      },
      'version_conflict': {
        'status': 'version_conflict',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'expected_row_version': 7,
        'current_row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
      },
    };

    for (final entry in payloads.entries) {
      for (final field in entry.value.entries.where(
        (field) => field.key != 'status',
      )) {
        test('rejects ${entry.key} missing ${field.key}', () async {
          final payload = Map<String, dynamic>.from(entry.value)
            ..remove(field.key);

          await expectProtocolError(payload);
        });

        test('rejects ${entry.key} invalid ${field.key}', () async {
          final Object invalidValue;

          if (field.value is int) {
            invalidValue = 0;
          } else if (field.key.endsWith('_at')) {
            invalidValue = 'invalid';
          } else {
            invalidValue = '   ';
          }

          final payload = Map<String, dynamic>.from(entry.value)
            ..[field.key] = invalidValue;

          await expectProtocolError(payload);
        });
      }
    }
  });
  group('correctBedGeometry write authority gate', () {
    const bedId = '55555555-5555-4555-8555-555555555555';
    const geometryId = '66666666-6666-4666-8666-666666666666';

    Future<void> expectUnavailable(BedRepository repository) async {
      await expectLater(
        repository.correctBedGeometry(
          bedId: bedId,
          geometryId: geometryId,
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
          reason: 'Correzione delle misure registrate',
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
    }

    test('rejects writes from a read-only repository', () async {
      final repository = BedRepository.withLoader(_unusedLoader);

      await expectUnavailable(repository);
    });

    test('rejects a missing provider before invoking RPC', () async {
      var rpcCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls += 1;
        return null;
      });

      await expectUnavailable(repository);

      expect(rpcCalls, 0);
    });

    test('propagates authority rejection before invoking RPC', () async {
      var rpcCalls = 0;
      var providerCalls = 0;
      const failure = ProfileWriteAuthorityUnavailableException();

      final repository = BedRepository.withProviders(
        _unusedLoader,
        (functionName, parameters) async {
          rpcCalls += 1;
          return null;
        },
        () {
          providerCalls += 1;
          throw failure;
        },
      );

      await expectLater(
        repository.correctBedGeometry(
          bedId: bedId,
          geometryId: geometryId,
          expectedRowVersion: 7,
          widthCm: 100,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
          reason: 'Correzione delle misure registrate',
        ),
        throwsA(same(failure)),
      );

      expect(providerCalls, 1);
      expect(rpcCalls, 0);
    });

    test('rejects a missing RPC invoker even with a lease', () async {
      var providerCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, null, () {
        providerCalls += 1;
        return _lease();
      });

      await expectUnavailable(repository);

      expect(providerCalls, 1);
    });
  });
  group('correctBedGeometry successful correction without previous', () {
    for (final endDate in <String?>[null, '2026-08-01']) {
      test('maps corrected geometry with valid_to=$endDate', () async {
        const bedId = '55555555-5555-4555-8555-555555555555';
        const geometryId = '66666666-6666-4666-8666-666666666666';
        const correctionId = '88888888-8888-4888-8888-888888888888';

        var rpcCalls = 0;
        var providerCalls = 0;
        String? calledFunction;
        Map<String, dynamic>? sentParameters;

        final repository = BedRepository.withProviders(
          _unusedLoader,
          (functionName, parameters) async {
            rpcCalls += 1;
            calledFunction = functionName;
            sentParameters = Map<String, dynamic>.from(parameters);

            return {
              'status': 'corrected',
              'bed_id': bedId,
              'garden_id': _gardenId,
              'row_version': 8,
              'updated_at': '2026-08-30T18:00:00+02:00',
              'geometry_id': geometryId,
              'width_cm': 110,
              'length_cm': 700,
              'valid_from': '2026-06-01',
              'valid_to': endDate,
              'geometry_row_version': 4,
              'geometry_updated_at': '2026-08-30T18:00:00+02:00',
              'correction_id': correctionId,
              'correction_created_at': '2026-08-30T18:00:01+02:00',
            };
          },
          () {
            providerCalls += 1;
            return _lease();
          },
        );

        final result = await repository.correctBedGeometry(
          bedId: bedId,
          geometryId: geometryId,
          expectedRowVersion: 7,
          widthCm: 110,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
          reason: 'Correzione delle misure registrate',
        );

        expect(providerCalls, 1);
        expect(rpcCalls, 1);
        expect(calledFunction, 'correct_bed_geometry');
        expect(sentParameters, {
          'target_profile_id': _profileId,
          'target_bed_id': bedId,
          'target_geometry_id': geometryId,
          'expected_row_version': 7,
          'target_client_id': _clientId,
          'target_session_id': _sessionId,
          'lock_token': 'token-esclusivamente-fittizio',
          'geometry_width_cm': 110,
          'geometry_length_cm': 700,
          'geometry_valid_from': '2026-06-01',
          'correction_reason': 'Correzione delle misure registrate',
        });

        expect(result, isA<BedGeometryCorrected>());

        final corrected = result as BedGeometryCorrected;

        expect(corrected.bedId, bedId);
        expect(corrected.gardenId, _gardenId);
        expect(corrected.rowVersion, 8);
        expect(corrected.updatedAt, DateTime.utc(2026, 8, 30, 16));
        expect(corrected.updatedAt.isUtc, isTrue);
        expect(corrected.geometryId, geometryId);
        expect(corrected.widthCm, 110);
        expect(corrected.lengthCm, 700);
        expect(corrected.validFrom, DateTime.utc(2026, 6, 1));
        expect(corrected.validFrom.isUtc, isTrue);
        expect(
          corrected.validTo,
          endDate == null ? null : DateTime.utc(2026, 8, 1),
        );
        if (corrected.validTo != null) {
          expect(corrected.validTo!.isUtc, isTrue);
        }
        expect(corrected.geometryRowVersion, 4);
        expect(corrected.geometryUpdatedAt, DateTime.utc(2026, 8, 30, 16));
        expect(corrected.geometryUpdatedAt.isUtc, isTrue);
        expect(corrected.correctionId, correctionId);
        expect(
          corrected.correctionCreatedAt,
          DateTime.utc(2026, 8, 30, 16, 0, 1),
        );
        expect(corrected.correctionCreatedAt.isUtc, isTrue);
        expect(corrected.previousGeometry, isNull);
      });
    }
  });
  test('correctBedGeometry maps the modified previous geometry', () async {
    const bedId = '55555555-5555-4555-8555-555555555555';
    const geometryId = '66666666-6666-4666-8666-666666666666';
    const previousId = '77777777-7777-4777-8777-777777777777';
    const correctionId = '88888888-8888-4888-8888-888888888888';

    var rpcCalls = 0;

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;

      return {
        'status': 'corrected',
        'bed_id': bedId,
        'garden_id': _gardenId,
        'row_version': 8,
        'updated_at': '2026-08-30T18:00:00+02:00',
        'geometry_id': geometryId,
        'width_cm': 110,
        'length_cm': 700,
        'valid_from': '2026-05-01',
        'valid_to': '2026-08-01',
        'geometry_row_version': 4,
        'geometry_updated_at': '2026-08-30T18:00:00+02:00',
        'correction_id': correctionId,
        'correction_created_at': '2026-08-30T18:00:01+02:00',
        'previous_geometry_id': previousId,
        'previous_geometry_valid_to': '2026-05-01',
        'previous_geometry_row_version': 6,
        'previous_geometry_updated_at': '2026-08-30T18:00:00+02:00',
      };
    }, _lease);

    final result = await repository.correctBedGeometry(
      bedId: bedId,
      geometryId: geometryId,
      expectedRowVersion: 7,
      widthCm: 110,
      lengthCm: 700,
      validFrom: DateTime(2026, 5, 1),
      reason: 'Correzione della data e delle misure',
    );

    expect(rpcCalls, 1);
    expect(result, isA<BedGeometryCorrected>());

    final corrected = result as BedGeometryCorrected;

    expect(corrected.bedId, bedId);
    expect(corrected.gardenId, _gardenId);
    expect(corrected.rowVersion, 8);
    expect(corrected.geometryId, geometryId);
    expect(corrected.geometryRowVersion, 4);
    expect(corrected.validFrom, DateTime.utc(2026, 5, 1));
    expect(corrected.validTo, DateTime.utc(2026, 8, 1));
    expect(corrected.correctionId, correctionId);
    expect(corrected.correctionCreatedAt, DateTime.utc(2026, 8, 30, 16, 0, 1));

    expect(corrected.previousGeometry, isNotNull);

    final previous = corrected.previousGeometry!;

    expect(previous.geometryId, previousId);
    expect(previous.geometryId, isNot(corrected.geometryId));
    expect(previous.validTo, corrected.validFrom);
    expect(previous.validTo.isUtc, isTrue);
    expect(previous.rowVersion, 6);
    expect(previous.updatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(previous.updatedAt.isUtc, isTrue);
  });
  test('correctBedGeometry maps unchanged without audit fields', () async {
    const bedId = '55555555-5555-4555-8555-555555555555';
    const geometryId = '66666666-6666-4666-8666-666666666666';
    var rpcCalls = 0;

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;

      return {
        'status': 'unchanged',
        'bed_id': bedId,
        'garden_id': _gardenId,
        'row_version': 7,
        'updated_at': '2026-08-30T18:00:00+02:00',
        'geometry_id': geometryId,
        'geometry_row_version': 3,
        'geometry_updated_at': '2026-08-29T17:00:00+02:00',
      };
    }, _lease);

    final result = await repository.correctBedGeometry(
      bedId: bedId,
      geometryId: geometryId,
      expectedRowVersion: 7,
      widthCm: 100,
      lengthCm: 700,
      validFrom: DateTime(2026, 6, 1),
      reason: 'Verifica delle misure registrate',
    );

    expect(rpcCalls, 1);
    expect(result, isA<CorrectBedGeometryUnchanged>());

    final unchanged = result as CorrectBedGeometryUnchanged;

    expect(unchanged.bedId, bedId);
    expect(unchanged.gardenId, _gardenId);
    expect(unchanged.rowVersion, 7);
    expect(unchanged.updatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(unchanged.updatedAt.isUtc, isTrue);
    expect(unchanged.geometryId, geometryId);
    expect(unchanged.geometryRowVersion, 3);
    expect(unchanged.geometryUpdatedAt, DateTime.utc(2026, 8, 29, 15));
    expect(unchanged.geometryUpdatedAt.isUtc, isTrue);
  });

  test('correctBedGeometry maps version conflict without retrying', () async {
    const bedId = '55555555-5555-4555-8555-555555555555';
    const geometryId = '66666666-6666-4666-8666-666666666666';
    var rpcCalls = 0;

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;

      return {
        'status': 'version_conflict',
        'bed_id': bedId,
        'expected_row_version': 7,
        'current_row_version': 8,
        'updated_at': '2026-08-30T18:00:00+02:00',
      };
    }, _lease);

    final result = await repository.correctBedGeometry(
      bedId: bedId,
      geometryId: geometryId,
      expectedRowVersion: 7,
      widthCm: 110,
      lengthCm: 700,
      validFrom: DateTime(2026, 6, 1),
      reason: 'Correzione delle misure registrate',
    );

    expect(rpcCalls, 1);
    expect(result, isA<CorrectBedGeometryVersionConflict>());

    final conflict = result as CorrectBedGeometryVersionConflict;

    expect(conflict.bedId, bedId);
    expect(conflict.expectedRowVersion, 7);
    expect(conflict.currentRowVersion, 8);
    expect(conflict.updatedAt, DateTime.utc(2026, 8, 30, 16));
    expect(conflict.updatedAt.isUtc, isTrue);
  });
  group('correctBedGeometry server rejections', () {
    final statusCases = <String, Matcher>{
      'forbidden': isA<CorrectBedGeometryForbidden>(),
      'write_forbidden': isA<CorrectBedGeometryWriteForbidden>(),
      'not_found': isA<CorrectBedGeometryNotFound>(),
      'invalid_input': isA<CorrectBedGeometryInvalidInput>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key} without retrying', () async {
        var rpcCalls = 0;

        final repository = BedRepository.withProviders(_unusedLoader, (
          functionName,
          parameters,
        ) async {
          rpcCalls += 1;
          return {'status': entry.key};
        }, _lease);

        final result = await repository.correctBedGeometry(
          bedId: '55555555-5555-4555-8555-555555555555',
          geometryId: '66666666-6666-4666-8666-666666666666',
          expectedRowVersion: 7,
          widthCm: 110,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
          reason: 'Correzione delle misure registrate',
        );

        expect(result, entry.value);
        expect(rpcCalls, 1);
      });
    }
  });

  test('correctBedGeometry propagates RPC failure without retrying', () async {
    var rpcCalls = 0;
    final failure = StateError('Synthetic RPC failure');

    final repository = BedRepository.withProviders(_unusedLoader, (
      functionName,
      parameters,
    ) async {
      rpcCalls += 1;
      throw failure;
    }, _lease);

    await expectLater(
      repository.correctBedGeometry(
        bedId: '55555555-5555-4555-8555-555555555555',
        geometryId: '66666666-6666-4666-8666-666666666666',
        expectedRowVersion: 7,
        widthCm: 110,
        lengthCm: 700,
        validFrom: DateTime(2026, 6, 1),
        reason: 'Correzione delle misure registrate',
      ),
      throwsA(same(failure)),
    );

    expect(rpcCalls, 1);
  });
  group('correctBedGeometry invalid previous geometry', () {
    Map<String, dynamic> validPayload() {
      return {
        'status': 'corrected',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
        'geometry_id': '66666666-6666-4666-8666-666666666666',
        'width_cm': 110,
        'length_cm': 700,
        'valid_from': '2026-05-01',
        'valid_to': '2026-08-01',
        'geometry_row_version': 4,
        'geometry_updated_at': '2026-08-30T16:00:00+00:00',
        'correction_id': '88888888-8888-4888-8888-888888888888',
        'correction_created_at': '2026-08-30T16:00:01+00:00',
        'previous_geometry_id': '77777777-7777-4777-8777-777777777777',
        'previous_geometry_valid_to': '2026-05-01',
        'previous_geometry_row_version': 6,
        'previous_geometry_updated_at': '2026-08-30T16:00:00+00:00',
      };
    }

    Future<void> expectProtocolError(Map<String, dynamic> payload) async {
      var rpcCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls += 1;
        return payload;
      }, _lease);

      await expectLater(
        repository.correctBedGeometry(
          bedId: '55555555-5555-4555-8555-555555555555',
          geometryId: '66666666-6666-4666-8666-666666666666',
          expectedRowVersion: 7,
          widthCm: 110,
          lengthCm: 700,
          validFrom: DateTime(2026, 5, 1),
          reason: 'Correzione della data e delle misure',
        ),
        throwsA(isA<BedWriteProtocolException>()),
      );

      expect(rpcCalls, 1);
    }

    const previousKeys = [
      'previous_geometry_id',
      'previous_geometry_valid_to',
      'previous_geometry_row_version',
      'previous_geometry_updated_at',
    ];

    for (final key in previousKeys) {
      test('rejects partial block missing $key', () async {
        final payload = validPayload()..remove(key);

        await expectProtocolError(payload);
      });

      test('rejects partial block containing only $key', () async {
        final payload = validPayload();

        for (final otherKey in previousKeys) {
          if (otherKey != key) {
            payload.remove(otherKey);
          }
        }

        await expectProtocolError(payload);
      });

      test('rejects null $key', () async {
        final payload = validPayload()..[key] = null;

        await expectProtocolError(payload);
      });
    }

    final invalidCases = <String, Map<String, dynamic>>{
      'blank previous id': {'previous_geometry_id': '   '},
      'same geometry identity': {
        'previous_geometry_id': '66666666-6666-4666-8666-666666666666',
      },
      'gap at shared boundary': {'previous_geometry_valid_to': '2026-04-30'},
      'overlap at shared boundary': {
        'previous_geometry_valid_to': '2026-05-02',
      },
      'impossible previous end date': {
        'previous_geometry_valid_to': '2026-04-31',
      },
      'zero previous version': {'previous_geometry_row_version': 0},
      'invalid previous timestamp': {'previous_geometry_updated_at': 'invalid'},
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () async {
        final payload = validPayload()..addAll(entry.value);

        await expectProtocolError(payload);
      });
    }
  });
  group('correctBedGeometry invalid corrected payload', () {
    Map<String, dynamic> validPayload() {
      return {
        'status': 'corrected',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
        'geometry_id': '66666666-6666-4666-8666-666666666666',
        'width_cm': 110,
        'length_cm': 700,
        'valid_from': '2026-06-01',
        'valid_to': null,
        'geometry_row_version': 4,
        'geometry_updated_at': '2026-08-30T16:00:00+00:00',
        'correction_id': '88888888-8888-4888-8888-888888888888',
        'correction_created_at': '2026-08-30T16:00:01+00:00',
      };
    }

    Future<void> expectProtocolError(Map<String, dynamic> payload) async {
      final repository = BedRepository.withProviders(
        _unusedLoader,
        (functionName, parameters) async => payload,
        _lease,
      );

      await expectLater(
        repository.correctBedGeometry(
          bedId: '55555555-5555-4555-8555-555555555555',
          geometryId: '66666666-6666-4666-8666-666666666666',
          expectedRowVersion: 7,
          widthCm: 110,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
          reason: 'Correzione delle misure registrate',
        ),
        throwsA(isA<BedWriteProtocolException>()),
      );
    }

    for (final key in validPayload().keys.where((key) => key != 'status')) {
      test('rejects missing $key', () async {
        final payload = validPayload()..remove(key);

        await expectProtocolError(payload);
      });
    }

    final invalidCases = <String, Map<String, dynamic>>{
      'empty bed id': {'bed_id': ''},
      'blank garden id': {'garden_id': '   '},
      'empty geometry id': {'geometry_id': ''},
      'empty correction id': {'correction_id': ''},
      'zero bed version': {'row_version': 0},
      'zero geometry version': {'geometry_row_version': 0},
      'zero width': {'width_cm': 0},
      'negative length': {'length_cm': -1},
      'invalid bed timestamp': {'updated_at': 'invalid'},
      'invalid geometry timestamp': {'geometry_updated_at': 'invalid'},
      'invalid correction timestamp': {'correction_created_at': 'invalid'},
      'null correction timestamp': {'correction_created_at': null},
      'impossible start date': {'valid_from': '2026-06-31'},
      'timestamp instead of start date': {'valid_from': '2026-06-01T00:00:00Z'},
      'impossible end date': {'valid_to': '2026-08-32'},
      'empty interval': {'valid_to': '2026-06-01'},
      'inverted interval': {'valid_to': '2026-05-31'},
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () async {
        final payload = validPayload()..addAll(entry.value);

        await expectProtocolError(payload);
      });
    }
  });
  group('correctBedGeometry invalid responses', () {
    Future<void> expectProtocolError(Object? response) async {
      var rpcCalls = 0;

      final repository = BedRepository.withProviders(_unusedLoader, (
        functionName,
        parameters,
      ) async {
        rpcCalls += 1;
        return response;
      }, _lease);

      await expectLater(
        repository.correctBedGeometry(
          bedId: '55555555-5555-4555-8555-555555555555',
          geometryId: '66666666-6666-4666-8666-666666666666',
          expectedRowVersion: 7,
          widthCm: 110,
          lengthCm: 700,
          validFrom: DateTime(2026, 6, 1),
          reason: 'Correzione delle misure registrate',
        ),
        throwsA(isA<BedWriteProtocolException>()),
      );

      expect(rpcCalls, 1);
    }

    final invalidEnvelopes = <String, Object?>{
      'null response': null,
      'string response': 'corrected',
      'list response': <Object?>[],
      'missing status': <String, dynamic>{},
      'null status': <String, dynamic>{'status': null},
      'non-string status': <String, dynamic>{'status': 1},
      'unknown status': <String, dynamic>{'status': 'unexpected'},
      'status from another operation': <String, dynamic>{'status': 'changed'},
      'non-string map key': <Object, Object?>{1: 'corrected'},
    };

    for (final entry in invalidEnvelopes.entries) {
      test('rejects ${entry.key}', () async {
        await expectProtocolError(entry.value);
      });
    }

    final payloads = <String, Map<String, dynamic>>{
      'unchanged': {
        'status': 'unchanged',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'garden_id': _gardenId,
        'row_version': 7,
        'updated_at': '2026-08-30T16:00:00+00:00',
        'geometry_id': '66666666-6666-4666-8666-666666666666',
        'geometry_row_version': 3,
        'geometry_updated_at': '2026-08-29T15:00:00+00:00',
      },
      'version_conflict': {
        'status': 'version_conflict',
        'bed_id': '55555555-5555-4555-8555-555555555555',
        'expected_row_version': 7,
        'current_row_version': 8,
        'updated_at': '2026-08-30T16:00:00+00:00',
      },
    };

    for (final entry in payloads.entries) {
      for (final field in entry.value.entries.where(
        (field) => field.key != 'status',
      )) {
        test('rejects ${entry.key} missing ${field.key}', () async {
          final payload = Map<String, dynamic>.from(entry.value)
            ..remove(field.key);

          await expectProtocolError(payload);
        });

        test('rejects ${entry.key} invalid ${field.key}', () async {
          final Object invalidValue;

          if (field.value is int) {
            invalidValue = 0;
          } else if (field.key.endsWith('_at')) {
            invalidValue = 'invalid';
          } else {
            invalidValue = '   ';
          }

          final payload = Map<String, dynamic>.from(entry.value)
            ..[field.key] = invalidValue;

          await expectProtocolError(payload);
        });
      }
    }
  });
}
