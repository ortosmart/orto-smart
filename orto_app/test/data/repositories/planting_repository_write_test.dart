import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/planting_write_result.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/data/repositories/planting_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';
const _seasonId = '33333333-3333-4333-8333-333333333333';
const _bedId = '44444444-4444-4444-8444-444444444444';
const _cropId = '55555555-5555-4555-8555-555555555555';
const _cultivarId = '66666666-6666-4666-8666-666666666666';
const _plantingId = '77777777-7777-4777-8777-777777777777';
const _clientInstanceId = '88888888-8888-4888-8888-888888888888';
const _sessionId = '99999999-9999-4999-8999-999999999999';
const _fakeToken = 'token-planting-esclusivamente-fittizio';

const _identity = AppSessionIdentity(
  clientInstanceId: _clientInstanceId,
  sessionId: _sessionId,
);

ProfileEditLockLease _lease() {
  return ProfileEditLockLease(
    profileId: _profileId,
    identity: _identity,
    lockToken: _fakeToken,
    expiresAt: DateTime.utc(2026, 9, 16, 16),
    rowVersion: 1,
  );
}

class _RpcRecorder {
  dynamic response;
  int callCount = 0;
  String? functionName;
  Map<String, dynamic>? parameters;

  Future<dynamic> call(
    String functionName,
    Map<String, dynamic> parameters,
  ) async {
    callCount += 1;
    this.functionName = functionName;
    this.parameters = Map<String, dynamic>.from(parameters);
    return response;
  }
}

Future<List<Map<String, dynamic>>> _unusedLoader(String bedId) async {
  throw StateError('Loader not expected');
}

PlantingRepository _repository(_RpcRecorder rpc, {bool withLease = true}) {
  return PlantingRepository.withProviders(
    _unusedLoader,
    rpc.call,
    withLease ? _lease : null,
  );
}

Future<CreatePlantingResult> _create(PlantingRepository repository) {
  return repository.createPlanting(
    gardenId: _gardenId,
    seasonId: _seasonId,
    bedId: _bedId,
    cropId: _cropId,
    cultivarId: _cultivarId,
    startMethod: 'direct_rows',
    startDate: DateTime.utc(2026, 9, 16, 18, 30),
    startPositionCm: 120,
    lengthCm: 200,
    plantSpacingCm: 30,
    rowSpacingCm: 40,
    rowsCount: 2,
    occupiedWidthCm: 40,
    plantsCount: 6,
    seedQuantityG: 12.5,
    notes: 'Semina di prova',
  );
}

Future<UpdatePlantingResult> _update(PlantingRepository repository) {
  return repository.updatePlanting(
    plantingId: _plantingId,
    expectedRowVersion: 3,
    seasonId: _seasonId,
    cropId: _cropId,
    cultivarId: _cultivarId,
    startMethod: 'direct_rows',
    startDate: DateTime.utc(2026, 9, 16, 20),
    startPositionCm: 150,
    lengthCm: 220,
    plantSpacingCm: 30,
    rowSpacingCm: 45,
    rowsCount: 2,
    occupiedWidthCm: 45,
    plantsCount: 7,
    seedQuantityG: 14.0,
    notes: 'Piantagione aggiornata',
  );
}

void main() {
  late _RpcRecorder rpc;

  setUp(() {
    rpc = _RpcRecorder();
  });

  group('write authority gate', () {
    test(
      'rejects create before invoking RPC when lease is unavailable',
      () async {
        final repository = _repository(rpc, withLease: false);

        await expectLater(
          _create(repository),
          throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
        );

        expect(rpc.callCount, 0);
      },
    );
  });

  group('createPlanting', () {
    test('invokes create_planting and maps created', () async {
      rpc.response = {
        'status': 'created',
        'planting_id': _plantingId,
        'profile_id': _profileId,
        'garden_id': _gardenId,
        'season_id': _seasonId,
        'bed_id': _bedId,
        'crop_id': _cropId,
        'cultivar_id': _cultivarId,
        'start_method': 'direct_rows',
        'start_date': '2026-09-16',
        'end_date': null,
        'start_position_cm': 120,
        'length_cm': 200,
        'occupied_width_cm': 40,
        'status_value': 'sown',
        'row_version': 1,
        'created_at': '2026-09-16T12:00:00+00:00',
      };

      final result = await _create(_repository(rpc));

      expect(result, isA<PlantingCreated>());

      final created = result as PlantingCreated;

      expect(created.plantingId, _plantingId);
      expect(created.profileId, _profileId);
      expect(created.gardenId, _gardenId);
      expect(created.seasonId, _seasonId);
      expect(created.bedId, _bedId);
      expect(created.cropId, _cropId);
      expect(created.cultivarId, _cultivarId);
      expect(created.startMethod, 'direct_rows');
      expect(created.startDate, DateTime.utc(2026, 9, 16));
      expect(created.endDate, isNull);
      expect(created.startPositionCm, 120);
      expect(created.lengthCm, 200);
      expect(created.occupiedWidthCm, 40);
      expect(created.status, 'sown');
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 9, 16, 12));

      expect(rpc.functionName, 'create_planting');

      expect(rpc.parameters!['target_profile_id'], _profileId);
      expect(rpc.parameters!['target_garden_id'], _gardenId);
      expect(rpc.parameters!['target_season_id'], _seasonId);
      expect(rpc.parameters!['target_bed_id'], _bedId);
      expect(rpc.parameters!['target_crop_id'], _cropId);
      expect(rpc.parameters!['target_cultivar_id'], _cultivarId);
      expect(rpc.parameters!['target_client_id'], _clientInstanceId);
      expect(rpc.parameters!['target_session_id'], _sessionId);
      expect(rpc.parameters!['lock_token'], _fakeToken);

      expect(rpc.parameters!['planting_start_method'], 'direct_rows');
      expect(rpc.parameters!['planting_start_date'], '2026-09-16');
      expect(rpc.parameters!['planting_start_position_cm'], 120);
      expect(rpc.parameters!['planting_length_cm'], 200);
      expect(rpc.parameters!['planting_plant_spacing_cm'], 30);
      expect(rpc.parameters!['planting_row_spacing_cm'], 40);
      expect(rpc.parameters!['planting_rows_count'], 2);
      expect(rpc.parameters!['planting_occupied_width_cm'], 40);
      expect(rpc.parameters!['planting_plants_count'], 6);
      expect(rpc.parameters!['planting_seed_quantity_g'], 12.5);
      expect(rpc.parameters!['planting_notes'], 'Semina di prova');
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<CreatePlantingForbidden>(),
      'write_forbidden': isA<CreatePlantingWriteForbidden>(),
      'not_found': isA<CreatePlantingNotFound>(),
      'invalid_input': isA<CreatePlantingInvalidInput>(),
      'blocked_by_inactive_garden':
          isA<CreatePlantingBlockedByInactiveGarden>(),
      'blocked_by_inactive_bed': isA<CreatePlantingBlockedByInactiveBed>(),
      'blocked_by_inactive_crop': isA<CreatePlantingBlockedByInactiveCrop>(),
      'blocked_by_inactive_cultivar':
          isA<CreatePlantingBlockedByInactiveCultivar>(),
      'outside_bed_geometry': isA<CreatePlantingOutsideBedGeometry>(),
      'overlap': isA<CreatePlantingOverlap>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key}', () async {
        rpc.response = {'status': entry.key};

        final result = await _create(_repository(rpc));

        expect(result, entry.value);
      });
    }
  });

  group('updatePlanting', () {
    test('invokes update_planting and maps updated', () async {
      rpc.response = {
        'status': 'updated',
        'planting_id': _plantingId,
        'garden_id': _gardenId,
        'bed_id': _bedId,
        'season_id': _seasonId,
        'crop_id': _cropId,
        'cultivar_id': _cultivarId,
        'start_method': 'direct_rows',
        'start_date': '2026-09-16',
        'start_position_cm': 150,
        'length_cm': 220,
        'occupied_width_cm': 45,
        'status_value': 'sown',
        'row_version': 4,
        'updated_at': '2026-09-16T12:30:00+00:00',
      };

      final result = await _update(_repository(rpc));

      expect(result, isA<PlantingUpdated>());

      final updated = result as PlantingUpdated;

      expect(updated.plantingId, _plantingId);
      expect(updated.rowVersion, 4);
      expect(updated.startPositionCm, 150);
      expect(updated.lengthCm, 220);
      expect(updated.occupiedWidthCm, 45);
      expect(updated.status, 'sown');

      expect(rpc.functionName, 'update_planting');
      expect(rpc.parameters!['target_profile_id'], _profileId);
      expect(rpc.parameters!['target_planting_id'], _plantingId);
      expect(rpc.parameters!['expected_row_version'], 3);
      expect(rpc.parameters!['target_client_id'], _clientInstanceId);
      expect(rpc.parameters!['target_session_id'], _sessionId);
      expect(rpc.parameters!['lock_token'], _fakeToken);
      expect(rpc.parameters!['planting_season_id'], _seasonId);
      expect(rpc.parameters!['planting_crop_id'], _cropId);
      expect(rpc.parameters!['planting_cultivar_id'], _cultivarId);
      expect(rpc.parameters!['planting_start_method'], 'direct_rows');
      expect(rpc.parameters!['planting_start_date'], '2026-09-16');
      expect(rpc.parameters!['planting_start_position_cm'], 150);
      expect(rpc.parameters!['planting_length_cm'], 220);
      expect(rpc.parameters!['planting_rows_count'], 2);
      expect(rpc.parameters!['planting_occupied_width_cm'], 45);
    });

    test('maps unchanged', () async {
      rpc.response = {
        'status': 'unchanged',
        'planting_id': _plantingId,
        'row_version': 3,
        'updated_at': '2026-09-16T12:30:00+00:00',
      };

      final result = await _update(_repository(rpc));

      expect(result, isA<UpdatePlantingUnchanged>());
    });

    test('maps version_conflict', () async {
      rpc.response = {
        'status': 'version_conflict',
        'planting_id': _plantingId,
        'expected_row_version': 3,
        'current_row_version': 4,
        'updated_at': '2026-09-16T12:30:00+00:00',
      };

      final result = await _update(_repository(rpc));

      expect(result, isA<UpdatePlantingVersionConflict>());

      final conflict = result as UpdatePlantingVersionConflict;

      expect(conflict.expectedRowVersion, 3);
      expect(conflict.currentRowVersion, 4);
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<UpdatePlantingForbidden>(),
      'write_forbidden': isA<UpdatePlantingWriteForbidden>(),
      'not_found': isA<UpdatePlantingNotFound>(),
      'invalid_input': isA<UpdatePlantingInvalidInput>(),
      'blocked_by_inactive_crop': isA<UpdatePlantingBlockedByInactiveCrop>(),
      'blocked_by_inactive_cultivar':
          isA<UpdatePlantingBlockedByInactiveCultivar>(),
      'start_method_locked': isA<UpdatePlantingStartMethodLocked>(),
      'start_date_locked': isA<UpdatePlantingStartDateLocked>(),
      'outside_bed_geometry': isA<UpdatePlantingOutsideBedGeometry>(),
      'overlap': isA<UpdatePlantingOverlap>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key}', () async {
        rpc.response = {'status': entry.key};

        final result = await _update(_repository(rpc));

        expect(result, entry.value);
      });
    }
  });

  group('setPlantingStatus', () {
    test('invokes set_planting_status and maps terminal updated', () async {
      rpc.response = {
        'status': 'updated',
        'planting_id': _plantingId,
        'garden_id': _gardenId,
        'previous_status': 'harvested',
        'status_value': 'finished',
        'start_date': '2026-09-16',
        'end_date': '2026-10-20',
        'row_version': 5,
        'updated_at': '2026-10-20T14:00:00+00:00',
      };

      final result = await _repository(rpc).setPlantingStatus(
        plantingId: _plantingId,
        expectedRowVersion: 4,
        status: 'finished',
        endDate: DateTime.utc(2026, 10, 20, 18),
      );

      expect(result, isA<PlantingStatusUpdated>());

      final updated = result as PlantingStatusUpdated;

      expect(updated.previousStatus, 'harvested');
      expect(updated.status, 'finished');
      expect(updated.startDate, DateTime.utc(2026, 9, 16));
      expect(updated.endDate, DateTime.utc(2026, 10, 20));
      expect(updated.rowVersion, 5);

      expect(rpc.functionName, 'set_planting_status');
      expect(rpc.parameters!['target_profile_id'], _profileId);
      expect(rpc.parameters!['target_planting_id'], _plantingId);
      expect(rpc.parameters!['expected_row_version'], 4);
      expect(rpc.parameters!['target_client_id'], _clientInstanceId);
      expect(rpc.parameters!['target_session_id'], _sessionId);
      expect(rpc.parameters!['lock_token'], _fakeToken);
      expect(rpc.parameters!['target_status'], 'finished');
      expect(rpc.parameters!['target_end_date'], '2026-10-20');
    });

    test('maps active updated with null end date', () async {
      rpc.response = {
        'status': 'updated',
        'planting_id': _plantingId,
        'garden_id': _gardenId,
        'previous_status': 'sown',
        'status_value': 'growing',
        'start_date': '2026-09-16',
        'end_date': null,
        'row_version': 2,
        'updated_at': '2026-09-20T10:00:00+00:00',
      };

      final result = await _repository(rpc).setPlantingStatus(
        plantingId: _plantingId,
        expectedRowVersion: 1,
        status: 'growing',
      );

      expect(result, isA<PlantingStatusUpdated>());
      expect((result as PlantingStatusUpdated).endDate, isNull);
      expect(rpc.parameters!['target_end_date'], isNull);
    });

    test('maps unchanged', () async {
      rpc.response = {
        'status': 'unchanged',
        'planting_id': _plantingId,
        'row_version': 4,
        'updated_at': '2026-09-20T10:00:00+00:00',
      };

      final result = await _repository(rpc).setPlantingStatus(
        plantingId: _plantingId,
        expectedRowVersion: 4,
        status: 'harvested',
      );

      expect(result, isA<SetPlantingStatusUnchanged>());
    });

    test('maps version_conflict', () async {
      rpc.response = {
        'status': 'version_conflict',
        'planting_id': _plantingId,
        'expected_row_version': 4,
        'current_row_version': 5,
        'updated_at': '2026-09-20T10:00:00+00:00',
      };

      final result = await _repository(rpc).setPlantingStatus(
        plantingId: _plantingId,
        expectedRowVersion: 4,
        status: 'harvested',
      );

      expect(result, isA<SetPlantingStatusVersionConflict>());
    });

    test('maps invalid_transition', () async {
      rpc.response = {
        'status': 'invalid_transition',
        'planting_id': _plantingId,
        'current_status': 'finished',
        'target_status': 'growing',
      };

      final result = await _repository(rpc).setPlantingStatus(
        plantingId: _plantingId,
        expectedRowVersion: 5,
        status: 'growing',
      );

      expect(result, isA<SetPlantingStatusInvalidTransition>());

      final invalid = result as SetPlantingStatusInvalidTransition;

      expect(invalid.plantingId, _plantingId);
      expect(invalid.currentStatus, 'finished');
      expect(invalid.targetStatus, 'growing');
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<SetPlantingStatusForbidden>(),
      'write_forbidden': isA<SetPlantingStatusWriteForbidden>(),
      'not_found': isA<SetPlantingStatusNotFound>(),
      'invalid_input': isA<SetPlantingStatusInvalidInput>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key}', () async {
        rpc.response = {'status': entry.key};

        final result = await _repository(rpc).setPlantingStatus(
          plantingId: _plantingId,
          expectedRowVersion: 4,
          status: 'harvested',
        );

        expect(result, entry.value);
      });
    }
  });

  group('protocol validation', () {
    test('rejects unknown status', () async {
      rpc.response = {'status': 'unexpected'};

      await expectLater(
        _create(_repository(rpc)),
        throwsA(isA<PlantingWriteProtocolException>()),
      );
    });

    test('rejects malformed created payload', () async {
      rpc.response = {'status': 'created', 'planting_id': _plantingId};

      await expectLater(
        _create(_repository(rpc)),
        throwsA(isA<PlantingWriteProtocolException>()),
      );
    });

    test('rejects terminal status without end date', () async {
      rpc.response = {
        'status': 'updated',
        'planting_id': _plantingId,
        'garden_id': _gardenId,
        'previous_status': 'harvested',
        'status_value': 'finished',
        'start_date': '2026-09-16',
        'end_date': null,
        'row_version': 5,
        'updated_at': '2026-10-20T14:00:00+00:00',
      };

      await expectLater(
        _repository(rpc).setPlantingStatus(
          plantingId: _plantingId,
          expectedRowVersion: 4,
          status: 'finished',
          endDate: DateTime.utc(2026, 10, 20),
        ),
        throwsA(isA<PlantingWriteProtocolException>()),
      );
    });

    test('rejects active status with end date', () async {
      rpc.response = {
        'status': 'updated',
        'planting_id': _plantingId,
        'garden_id': _gardenId,
        'previous_status': 'sown',
        'status_value': 'growing',
        'start_date': '2026-09-16',
        'end_date': '2026-10-20',
        'row_version': 2,
        'updated_at': '2026-09-20T10:00:00+00:00',
      };

      await expectLater(
        _repository(rpc).setPlantingStatus(
          plantingId: _plantingId,
          expectedRowVersion: 1,
          status: 'growing',
        ),
        throwsA(isA<PlantingWriteProtocolException>()),
      );
    });
  });
}
