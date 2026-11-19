import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/planned_planting_write_result.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/data/repositories/planned_planting_repository.dart';

Future<CreatePlannedPlantingResult> _createPlannedPlanting(
  PlannedPlantingRepository repository,
) {
  return repository.createPlannedPlanting(
    gardenId: '44444444-4444-4444-8444-444444444444',
    seasonId: '55555555-5555-4555-8555-555555555555',
    bedId: '66666666-6666-4666-8666-666666666666',
    cropId: '77777777-7777-4777-8777-777777777777',
    startMethod: 'direct_rows',
    startDate: DateTime.utc(2026, 11, 18),
    endDate: DateTime.utc(2027, 2, 18),
    startPositionCm: 0,
    lengthCm: 100,
    occupiedWidthCm: 40,
  );
}

Future<UpdatePlannedPlantingResult> _updatePlannedPlanting(
  PlannedPlantingRepository repository,
) {
  return repository.updatePlannedPlanting(
    plannedPlantingId: '33333333-3333-4333-8333-333333333333',
    expectedRowVersion: 1,
    bedId: '66666666-6666-4666-8666-666666666666',
    cropId: '77777777-7777-4777-8777-777777777777',
    startMethod: 'direct_rows',
    startDate: DateTime.utc(2026, 11, 18),
    endDate: DateTime.utc(2027, 2, 18),
    startPositionCm: 0,
    lengthCm: 100,
    occupiedWidthCm: 40,
  );
}

void main() {
  test(
    'restituisce aggiornamento tipizzato e parametri RPC corretti',
    () async {
      const identity = AppSessionIdentity(
        clientInstanceId: '88888888-8888-4888-8888-888888888888',
        sessionId: '99999999-9999-4999-8999-999999999999',
      );

      final lease = ProfileEditLockLease(
        profileId: '11111111-1111-4111-8111-111111111111',
        identity: identity,
        lockToken: 'token-esclusivamente-test',
        expiresAt: DateTime.utc(2026, 11, 18, 18),
        rowVersion: 1,
      );

      var rpcCalls = 0;
      String? rpcName;
      Map<String, dynamic>? rpcParameters;

      final repository = PlannedPlantingRepository.withProviders((
        functionName,
        parameters,
      ) async {
        rpcCalls++;
        rpcName = functionName;
        rpcParameters = Map<String, dynamic>.from(parameters);

        return {
          'status': 'updated',
          'planned_planting_id': '33333333-3333-4333-8333-333333333333',
          'row_version': 2,
        };
      }, () => lease);

      final result = await _updatePlannedPlanting(repository);

      expect(rpcCalls, 1);
      expect(rpcName, 'update_planned_planting');
      expect(result, isA<UpdatePlannedPlantingUpdated>());

      final updated = result as UpdatePlannedPlantingUpdated;
      expect(updated.plannedPlantingId, '33333333-3333-4333-8333-333333333333');
      expect(updated.rowVersion, 2);

      final params = rpcParameters!;
      expect(params['target_profile_id'], lease.profileId);
      expect(
        params['target_planned_planting_id'],
        '33333333-3333-4333-8333-333333333333',
      );
      expect(params['expected_row_version'], 1);
      expect(params['target_client_id'], identity.clientInstanceId);
      expect(params['target_session_id'], identity.sessionId);
      expect(params['lock_token'], lease.lockToken);
      expect(params['planting_bed_id'], '66666666-6666-4666-8666-666666666666');
      expect(
        params['planting_crop_id'],
        '77777777-7777-4777-8777-777777777777',
      );
      expect(params['planting_start_method'], 'direct_rows');
      expect(params['planting_start_date'], '2026-11-18');
      expect(params['planting_end_date'], '2027-02-18');
      expect(params['planting_start_position_cm'], 0);
      expect(params['planting_length_cm'], 100);
      expect(params['planting_occupied_width_cm'], 40);
      expect(params.length, 21);
    },
  );

  test('blocca aggiornamento senza Write Authority', () async {
    var rpcCalls = 0;

    final repository = PlannedPlantingRepository.withProviders((
      functionName,
      parameters,
    ) async {
      rpcCalls++;
      return {'status': 'updated'};
    }, null);

    await expectLater(
      _updatePlannedPlanting(repository),
      throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
    );

    expect(rpcCalls, 0);
  });

  test('blocca la creazione senza Write Authority', () async {
    var rpcCalls = 0;

    final repository = PlannedPlantingRepository.withProviders((
      functionName,
      parameters,
    ) async {
      rpcCalls++;
      return {'status': 'created'};
    }, null);

    await expectLater(
      repository.createPlannedPlanting(
        gardenId: 'garden-test',
        seasonId: 'season-test',
        bedId: 'bed-test',
        cropId: 'crop-test',
        startMethod: 'direct_rows',
        startDate: DateTime.utc(2026, 11, 18),
        endDate: DateTime.utc(2027, 2, 18),
        startPositionCm: 0,
        lengthCm: 100,
        occupiedWidthCm: 40,
      ),
      throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
    );

    expect(rpcCalls, 0);
  });
  test('restituisce il risultato tipizzato della creazione', () async {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    final lease = ProfileEditLockLease(
      profileId: '11111111-1111-4111-8111-111111111111',
      identity: identity,
      lockToken: 'token-esclusivamente-test',
      expiresAt: DateTime.utc(2026, 11, 18, 18),
      rowVersion: 1,
    );

    var rpcCalls = 0;
    String? rpcName;
    Map<String, dynamic>? rpcParameters;

    final repository = PlannedPlantingRepository.withProviders((
      functionName,
      parameters,
    ) async {
      rpcCalls++;
      rpcName = functionName;
      rpcParameters = Map<String, dynamic>.from(parameters);

      return {
        'status': 'created',
        'season_plan_id': '22222222-2222-4222-8222-222222222222',
        'planned_planting_id': '33333333-3333-4333-8333-333333333333',
        'row_version': 1,
      };
    }, () => lease);

    final result = await repository.createPlannedPlanting(
      gardenId: '44444444-4444-4444-8444-444444444444',
      seasonId: '55555555-5555-4555-8555-555555555555',
      bedId: '66666666-6666-4666-8666-666666666666',
      cropId: '77777777-7777-4777-8777-777777777777',
      startMethod: 'direct_rows',
      startDate: DateTime.utc(2026, 11, 18),
      endDate: DateTime.utc(2027, 2, 18),
      startPositionCm: 0,
      lengthCm: 100,
      occupiedWidthCm: 40,
    );

    expect(rpcCalls, 1);
    expect(rpcName, 'create_planned_planting');
    expect(result, isA<CreatePlannedPlantingCreated>());

    final created = result as CreatePlannedPlantingCreated;
    expect(created.seasonPlanId, '22222222-2222-4222-8222-222222222222');
    expect(created.plannedPlantingId, '33333333-3333-4333-8333-333333333333');
    expect(created.rowVersion, 1);
    expect(rpcParameters, isNotNull);

    final params = rpcParameters!;

    expect(params['target_profile_id'], '11111111-1111-4111-8111-111111111111');
    expect(params['target_client_id'], '88888888-8888-4888-8888-888888888888');
    expect(params['target_session_id'], '99999999-9999-4999-8999-999999999999');
    expect(params['lock_token'], 'token-esclusivamente-test');

    expect(params['target_garden_id'], '44444444-4444-4444-8444-444444444444');
    expect(params['target_season_id'], '55555555-5555-4555-8555-555555555555');
    expect(params['target_bed_id'], '66666666-6666-4666-8666-666666666666');
    expect(params['target_crop_id'], '77777777-7777-4777-8777-777777777777');

    expect(params['planting_start_method'], 'direct_rows');
    expect(params['planting_start_date'], '2026-11-18');
    expect(params['planting_end_date'], '2027-02-18');
    expect(params['planting_start_position_cm'], 0);
    expect(params['planting_length_cm'], 100);
    expect(params['planting_occupied_width_cm'], 40);

    expect(params.length, 21);
  });
  group('stati di errore update_planned_planting', () {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    final cases = <String, Type>{
      'forbidden': UpdatePlannedPlantingForbidden,
      'write_forbidden': UpdatePlannedPlantingWriteForbidden,
      'not_found': UpdatePlannedPlantingNotFound,
      'invalid_input': UpdatePlannedPlantingInvalidInput,
      'version_conflict': UpdatePlannedPlantingVersionConflict,
      'blocked_by_lifecycle': UpdatePlannedPlantingBlockedByLifecycle,
      'blocked_by_inactive_garden': UpdatePlannedPlantingInactiveGarden,
      'blocked_by_inactive_bed': UpdatePlannedPlantingInactiveBed,
      'blocked_by_inactive_crop': UpdatePlannedPlantingInactiveCrop,
      'blocked_by_inactive_cultivar': UpdatePlannedPlantingInactiveCultivar,
      'missing_bed_geometry': UpdatePlannedPlantingMissingBedGeometry,
      'outside_bed_geometry': UpdatePlannedPlantingOutsideBedGeometry,
    };

    for (final entry in cases.entries) {
      test('converte lo stato ${entry.key}', () async {
        final lease = ProfileEditLockLease(
          profileId: '11111111-1111-4111-8111-111111111111',
          identity: identity,
          lockToken: 'token-esclusivamente-test',
          expiresAt: DateTime.utc(2026, 11, 18, 18),
          rowVersion: 1,
        );

        var rpcCalls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          rpcCalls++;
          expect(functionName, 'update_planned_planting');
          return {'status': entry.key};
        }, () => lease);

        final result = await _updatePlannedPlanting(repository);

        expect(result.runtimeType, entry.value);
        expect(rpcCalls, 1);
      });
    }
  });
  test('update_planned_planting converte overlap con bed_id', () async {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    final lease = ProfileEditLockLease(
      profileId: '11111111-1111-4111-8111-111111111111',
      identity: identity,
      lockToken: 'token-esclusivamente-test',
      expiresAt: DateTime.utc(2026, 11, 18, 18),
      rowVersion: 1,
    );

    const expectedBedId = '66666666-6666-4666-8666-666666666666';
    var rpcCalls = 0;

    final repository = PlannedPlantingRepository.withProviders((
      functionName,
      parameters,
    ) async {
      rpcCalls++;
      expect(functionName, 'update_planned_planting');

      return {'status': 'overlap', 'bed_id': expectedBedId};
    }, () => lease);

    final result = await _updatePlannedPlanting(repository);

    expect(result, isA<UpdatePlannedPlantingOverlap>());
    expect((result as UpdatePlannedPlantingOverlap).bedId, expectedBedId);
    expect(rpcCalls, 1);
  });
  group('stati di errore create_planned_planting', () {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    final cases = <String, Type>{
      'forbidden': CreatePlannedPlantingForbidden,
      'write_forbidden': CreatePlannedPlantingWriteForbidden,
      'not_found': CreatePlannedPlantingNotFound,
      'invalid_input': CreatePlannedPlantingInvalidInput,
      'blocked_by_inactive_garden': CreatePlannedPlantingInactiveGarden,
      'blocked_by_inactive_bed': CreatePlannedPlantingInactiveBed,
      'blocked_by_inactive_crop': CreatePlannedPlantingInactiveCrop,
      'blocked_by_inactive_cultivar': CreatePlannedPlantingInactiveCultivar,
      'missing_bed_geometry': CreatePlannedPlantingMissingBedGeometry,
      'outside_bed_geometry': CreatePlannedPlantingOutsideBedGeometry,
    };

    for (final entry in cases.entries) {
      test('converte lo stato ${entry.key}', () async {
        final lease = ProfileEditLockLease(
          profileId: '11111111-1111-4111-8111-111111111111',
          identity: identity,
          lockToken: 'token-esclusivamente-test',
          expiresAt: DateTime.utc(2026, 11, 18, 18),
          rowVersion: 1,
        );

        var rpcCalls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          rpcCalls++;
          return {'status': entry.key};
        }, () => lease);

        final result = await _createPlannedPlanting(repository);

        expect(result.runtimeType, entry.value);
        expect(rpcCalls, 1);
      });
    }
  });
  group('risposte update_planned_planting non valide', () {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    final invalidResponses = <dynamic>[
      null,
      'risposta non valida',
      {'status': 'unknown_status'},
      {'status': 'updated'},
      {'status': 'updated', 'planned_planting_id': '', 'row_version': 2},
      {'status': 'updated', 'planned_planting_id': 123, 'row_version': 2},
      {
        'status': 'updated',
        'planned_planting_id': '33333333-3333-4333-8333-333333333333',
        'row_version': 0,
      },
      {
        'status': 'updated',
        'planned_planting_id': '33333333-3333-4333-8333-333333333333',
        'row_version': '2',
      },
      {'status': 'overlap'},
      {'status': 'overlap', 'bed_id': ''},
      {'status': 'overlap', 'bed_id': 123},
    ];

    for (var index = 0; index < invalidResponses.length; index++) {
      test('rifiuta risposta aggiornamento non valida ${index + 1}', () async {
        final lease = ProfileEditLockLease(
          profileId: '11111111-1111-4111-8111-111111111111',
          identity: identity,
          lockToken: 'token-esclusivamente-test',
          expiresAt: DateTime.utc(2026, 11, 18, 18),
          rowVersion: 1,
        );

        var rpcCalls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          rpcCalls++;
          expect(functionName, 'update_planned_planting');
          return invalidResponses[index];
        }, () => lease);

        await expectLater(
          _updatePlannedPlanting(repository),
          throwsA(isA<FormatException>()),
        );

        expect(rpcCalls, 1);
      });
    }
  });

  group('risposte RPC non valide', () {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    final invalidResponses = <dynamic>[
      null,
      'risposta non valida',
      {'status': 'unknown_status'},
      {'status': 'created'},
      {
        'status': 'created',
        'season_plan_id': '22222222-2222-4222-8222-222222222222',
        'planned_planting_id': '33333333-3333-4333-8333-333333333333',
        'row_version': 0,
      },
    ];

    for (var index = 0; index < invalidResponses.length; index++) {
      test('rifiuta risposta non valida ${index + 1}', () async {
        final lease = ProfileEditLockLease(
          profileId: '11111111-1111-4111-8111-111111111111',
          identity: identity,
          lockToken: 'token-esclusivamente-test',
          expiresAt: DateTime.utc(2026, 11, 18, 18),
          rowVersion: 1,
        );

        var rpcCalls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          rpcCalls++;
          return invalidResponses[index];
        }, () => lease);

        await expectLater(
          _createPlannedPlanting(repository),
          throwsA(isA<FormatException>()),
        );

        expect(rpcCalls, 1);
      });
    }
  });
  group('conferma pianificazione', () {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    const plannedPlantingId = '33333333-3333-4333-8333-333333333333';

    ProfileEditLockLease makeLease() => ProfileEditLockLease(
      profileId: '11111111-1111-4111-8111-111111111111',
      identity: identity,
      lockToken: 'token-esclusivamente-test',
      expiresAt: DateTime.utc(2026, 11, 18, 18),
      rowVersion: 1,
    );

    Future<ConfirmPlannedPlantingResult> confirm(
      PlannedPlantingRepository repository,
    ) => repository.confirmPlannedPlanting(
      plannedPlantingId: plannedPlantingId,
      expectedRowVersion: 1,
    );

    test('conferma riuscita e sei parametri RPC corretti', () async {
      var calls = 0;
      String? rpcName;
      Map<String, dynamic>? rpcParameters;

      final repository = PlannedPlantingRepository.withProviders((
        functionName,
        parameters,
      ) async {
        calls++;
        rpcName = functionName;
        rpcParameters = Map<String, dynamic>.from(parameters);
        return {
          'status': 'confirmed',
          'planned_planting_id': plannedPlantingId,
          'row_version': 2,
        };
      }, makeLease);

      final result = await confirm(repository);

      expect(calls, 1);
      expect(rpcName, 'confirm_planned_planting');
      expect(rpcParameters, {
        'target_profile_id': '11111111-1111-4111-8111-111111111111',
        'target_planned_planting_id': plannedPlantingId,
        'expected_row_version': 1,
        'target_client_id': identity.clientInstanceId,
        'target_session_id': identity.sessionId,
        'lock_token': 'token-esclusivamente-test',
      });

      expect(result, isA<ConfirmPlannedPlantingConfirmed>());
      final confirmed = result as ConfirmPlannedPlantingConfirmed;
      expect(confirmed.plannedPlantingId, plannedPlantingId);
      expect(confirmed.rowVersion, 2);
    });

    final errorCases = <String, Type>{
      'forbidden': ConfirmPlannedPlantingForbidden,
      'write_forbidden': ConfirmPlannedPlantingWriteForbidden,
      'not_found': ConfirmPlannedPlantingNotFound,
      'version_conflict': ConfirmPlannedPlantingVersionConflict,
      'inactive_garden': ConfirmPlannedPlantingInactiveGarden,
      'inactive_bed': ConfirmPlannedPlantingInactiveBed,
      'blocked_by_lifecycle': ConfirmPlannedPlantingBlockedByLifecycle,
      'missing_bed_geometry': ConfirmPlannedPlantingMissingBedGeometry,
      'outside_bed_geometry': ConfirmPlannedPlantingOutsideBedGeometry,
    };

    for (final entry in errorCases.entries) {
      test('gestisce stato ${entry.key}', () async {
        var calls = 0;
        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          calls++;
          expect(functionName, 'confirm_planned_planting');
          return {'status': entry.key};
        }, makeLease);

        final result = await confirm(repository);
        expect(result.runtimeType, entry.value);
        expect(calls, 1);
      });
    }

    test('gestisce overlap con identificativo aiuola', () async {
      const bedId = '66666666-6666-4666-8666-666666666666';

      final repository = PlannedPlantingRepository.withProviders(
        (functionName, parameters) async => {
          'status': 'overlap',
          'bed_id': bedId,
        },
        makeLease,
      );

      final result = await confirm(repository);
      expect(result, isA<ConfirmPlannedPlantingOverlap>());
      expect((result as ConfirmPlannedPlantingOverlap).bedId, bedId);
    });

    test('blocca scrittura senza Write Authority', () async {
      var calls = 0;

      final repository = PlannedPlantingRepository.withProviders((
        functionName,
        parameters,
      ) async {
        calls++;
        return {'status': 'confirmed'};
      }, null);

      await expectLater(
        confirm(repository),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
      expect(calls, 0);
    });

    final invalidResponses = <dynamic>[
      null,
      'risposta non valida',
      {'status': 'unknown_status'},
      {'status': 'confirmed'},
      {
        'status': 'confirmed',
        'planned_planting_id': plannedPlantingId,
        'row_version': 0,
      },
      {'status': 'overlap'},
    ];

    for (var index = 0; index < invalidResponses.length; index++) {
      test('rifiuta risposta conferma non valida ${index + 1}', () async {
        var calls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          calls++;
          return invalidResponses[index];
        }, makeLease);

        await expectLater(confirm(repository), throwsA(isA<FormatException>()));
        expect(calls, 1);
      });
    }
  });

  group('annullamento pianificazione', () {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    const plannedPlantingId = '33333333-3333-4333-8333-333333333333';

    ProfileEditLockLease makeLease() => ProfileEditLockLease(
      profileId: '11111111-1111-4111-8111-111111111111',
      identity: identity,
      lockToken: 'token-esclusivamente-test',
      expiresAt: DateTime.utc(2026, 11, 18, 18),
      rowVersion: 1,
    );

    Future<CancelPlannedPlantingResult> cancel(
      PlannedPlantingRepository repository,
    ) => repository.cancelPlannedPlanting(
      plannedPlantingId: plannedPlantingId,
      expectedRowVersion: 1,
    );

    test('annullamento riuscito e sei parametri RPC corretti', () async {
      var calls = 0;
      String? rpcName;
      Map<String, dynamic>? rpcParameters;

      final repository = PlannedPlantingRepository.withProviders((
        functionName,
        parameters,
      ) async {
        calls++;
        rpcName = functionName;
        rpcParameters = Map<String, dynamic>.from(parameters);
        return {
          'status': 'cancelled',
          'planned_planting_id': plannedPlantingId,
          'row_version': 2,
        };
      }, makeLease);

      final result = await cancel(repository);

      expect(calls, 1);
      expect(rpcName, 'cancel_planned_planting');
      expect(rpcParameters, {
        'target_profile_id': '11111111-1111-4111-8111-111111111111',
        'target_planned_planting_id': plannedPlantingId,
        'expected_row_version': 1,
        'target_client_id': identity.clientInstanceId,
        'target_session_id': identity.sessionId,
        'lock_token': 'token-esclusivamente-test',
      });

      expect(result, isA<CancelPlannedPlantingCancelled>());
      final cancelled = result as CancelPlannedPlantingCancelled;
      expect(cancelled.plannedPlantingId, plannedPlantingId);
      expect(cancelled.rowVersion, 2);
    });

    final errorCases = <String, Type>{
      'forbidden': CancelPlannedPlantingForbidden,
      'write_forbidden': CancelPlannedPlantingWriteForbidden,
      'not_found': CancelPlannedPlantingNotFound,
      'version_conflict': CancelPlannedPlantingVersionConflict,
      'blocked_by_lifecycle': CancelPlannedPlantingBlockedByLifecycle,
    };

    for (final entry in errorCases.entries) {
      test('gestisce stato ${entry.key}', () async {
        var calls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          calls++;
          expect(functionName, 'cancel_planned_planting');
          return {'status': entry.key};
        }, makeLease);

        final result = await cancel(repository);
        expect(result.runtimeType, entry.value);
        expect(calls, 1);
      });
    }

    test('blocca scrittura senza Write Authority', () async {
      var calls = 0;

      final repository = PlannedPlantingRepository.withProviders((
        functionName,
        parameters,
      ) async {
        calls++;
        return {'status': 'cancelled'};
      }, null);

      await expectLater(
        cancel(repository),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
      expect(calls, 0);
    });

    final invalidResponses = <dynamic>[
      null,
      'risposta non valida',
      {'status': 'unknown_status'},
      {'status': 'cancelled'},
      {'status': 'cancelled', 'planned_planting_id': '', 'row_version': 2},
      {
        'status': 'cancelled',
        'planned_planting_id': plannedPlantingId,
        'row_version': 0,
      },
    ];

    for (var index = 0; index < invalidResponses.length; index++) {
      test('rifiuta risposta annullamento non valida ${index + 1}', () async {
        var calls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          calls++;
          return invalidResponses[index];
        }, makeLease);

        await expectLater(cancel(repository), throwsA(isA<FormatException>()));
        expect(calls, 1);
      });
    }
  });

  group('esecuzione pianificazione', () {
    const identity = AppSessionIdentity(
      clientInstanceId: '88888888-8888-4888-8888-888888888888',
      sessionId: '99999999-9999-4999-8999-999999999999',
    );

    const plannedPlantingId = '33333333-3333-4333-8333-333333333333';
    const plantingId = '44444444-4444-4444-8444-444444444444';
    const bedId = '66666666-6666-4666-8666-666666666666';

    ProfileEditLockLease makeLease() => ProfileEditLockLease(
      profileId: '11111111-1111-4111-8111-111111111111',
      identity: identity,
      lockToken: 'token-esclusivamente-test',
      expiresAt: DateTime.utc(2026, 11, 19, 18),
      rowVersion: 1,
    );

    Future<ExecutePlannedPlantingResult> execute(
      PlannedPlantingRepository repository,
    ) => repository.executePlannedPlanting(
      plannedPlantingId: plannedPlantingId,
      expectedRowVersion: 1,
      effectiveStartDate: DateTime(2026, 11, 19),
    );

    test('esecuzione riuscita e sette parametri RPC corretti', () async {
      var calls = 0;
      String? rpcName;
      Map<String, dynamic>? rpcParameters;

      final repository = PlannedPlantingRepository.withProviders((
        functionName,
        parameters,
      ) async {
        calls++;
        rpcName = functionName;
        rpcParameters = Map<String, dynamic>.from(parameters);
        return {
          'status': 'executed',
          'planned_planting_id': plannedPlantingId,
          'planting_id': plantingId,
          'effective_start_date': '2026-11-19',
          'row_version': 2,
        };
      }, makeLease);

      final result = await execute(repository);

      expect(calls, 1);
      expect(rpcName, 'execute_planned_planting');
      expect(rpcParameters, {
        'target_profile_id': '11111111-1111-4111-8111-111111111111',
        'target_planned_planting_id': plannedPlantingId,
        'expected_row_version': 1,
        'target_client_id': identity.clientInstanceId,
        'target_session_id': identity.sessionId,
        'lock_token': 'token-esclusivamente-test',
        'effective_start_date': '2026-11-19',
      });

      expect(result, isA<ExecutePlannedPlantingExecuted>());
      final executed = result as ExecutePlannedPlantingExecuted;
      expect(executed.plannedPlantingId, plannedPlantingId);
      expect(executed.plantingId, plantingId);
      expect(executed.effectiveStartDate, DateTime(2026, 11, 19));
      expect(executed.rowVersion, 2);
    });

    final errorCases = <String, Type>{
      'forbidden': ExecutePlannedPlantingForbidden,
      'write_forbidden': ExecutePlannedPlantingWriteForbidden,
      'not_found': ExecutePlannedPlantingNotFound,
      'invalid_input': ExecutePlannedPlantingInvalidInput,
      'version_conflict': ExecutePlannedPlantingVersionConflict,
      'blocked_by_lifecycle': ExecutePlannedPlantingBlockedByLifecycle,
      'blocked_by_inactive_garden': ExecutePlannedPlantingInactiveGarden,
      'blocked_by_inactive_bed': ExecutePlannedPlantingInactiveBed,
      'blocked_by_inactive_crop': ExecutePlannedPlantingInactiveCrop,
      'blocked_by_inactive_cultivar': ExecutePlannedPlantingInactiveCultivar,
      'outside_bed_geometry': ExecutePlannedPlantingOutsideBedGeometry,
    };

    for (final entry in errorCases.entries) {
      test('gestisce stato ${entry.key}', () async {
        var calls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          calls++;
          expect(functionName, 'execute_planned_planting');
          return {'status': entry.key};
        }, makeLease);

        final result = await execute(repository);
        expect(result.runtimeType, entry.value);
        expect(calls, 1);
      });
    }

    for (final status in ['overlap', 'blocked_by_confirmed_plans']) {
      test('gestisce $status con identificativo aiuola', () async {
        final repository = PlannedPlantingRepository.withProviders(
          (functionName, parameters) async => {
            'status': status,
            'bed_id': bedId,
          },
          makeLease,
        );

        final result = await execute(repository);

        if (status == 'overlap') {
          expect(result, isA<ExecutePlannedPlantingOverlap>());
          expect((result as ExecutePlannedPlantingOverlap).bedId, bedId);
        } else {
          expect(result, isA<ExecutePlannedPlantingBlockedByConfirmedPlans>());
          expect(
            (result as ExecutePlannedPlantingBlockedByConfirmedPlans).bedId,
            bedId,
          );
        }
      });
    }

    test('blocca scrittura senza Write Authority', () async {
      var calls = 0;

      final repository = PlannedPlantingRepository.withProviders((
        functionName,
        parameters,
      ) async {
        calls++;
        return {'status': 'executed'};
      }, null);

      await expectLater(
        execute(repository),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
      expect(calls, 0);
    });

    final invalidResponses = <dynamic>[
      null,
      'risposta non valida',
      {'status': 'unknown_status'},
      {'status': 'executed'},
      {
        'status': 'executed',
        'planned_planting_id': plannedPlantingId,
        'planting_id': '',
        'effective_start_date': '2026-11-19',
        'row_version': 2,
      },
      {
        'status': 'executed',
        'planned_planting_id': plannedPlantingId,
        'planting_id': plantingId,
        'effective_start_date': '2026-02-30',
        'row_version': 2,
      },
      {
        'status': 'executed',
        'planned_planting_id': plannedPlantingId,
        'planting_id': plantingId,
        'effective_start_date': '2026-11-19',
        'row_version': 0,
      },
      {'status': 'overlap'},
      {'status': 'blocked_by_confirmed_plans'},
    ];

    for (var index = 0; index < invalidResponses.length; index++) {
      test('rifiuta risposta esecuzione non valida ${index + 1}', () async {
        var calls = 0;

        final repository = PlannedPlantingRepository.withProviders((
          functionName,
          parameters,
        ) async {
          calls++;
          return invalidResponses[index];
        }, makeLease);

        await expectLater(execute(repository), throwsA(isA<FormatException>()));
        expect(calls, 1);
      });
    }
  });
}
