import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/crop_variety_write_result.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/data/repositories/crop_variety_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _cropId = '22222222-2222-4222-8222-222222222222';
const _varietyId = '33333333-3333-4333-8333-333333333333';
const _clientInstanceId = '44444444-4444-4444-8444-444444444444';
const _sessionId = '55555555-5555-4555-8555-555555555555';
const _fakeToken = 'token-esclusivamente-fittizio';

const _identity = AppSessionIdentity(
  clientInstanceId: _clientInstanceId,
  sessionId: _sessionId,
);

ProfileEditLockLease _lease() {
  return ProfileEditLockLease(
    profileId: _profileId,
    identity: _identity,
    lockToken: _fakeToken,
    expiresAt: DateTime.utc(2026, 9, 13, 18),
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

Future<List<Map<String, dynamic>>> _unusedLoader({
  String? cropId,
  bool activeOnly = true,
}) async {
  throw StateError('Loader not expected');
}

CropVarietyRepository _repository(_RpcRecorder rpc, {bool withLease = true}) {
  return CropVarietyRepository.withProviders(
    _unusedLoader,
    rpc.call,
    withLease ? _lease : null,
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
          repository.createCropVariety(cropId: _cropId, name: 'San Marzano'),
          throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
        );

        expect(rpc.callCount, 0);
      },
    );
  });

  group('createCropVariety', () {
    test('invokes create_crop_variety and maps created', () async {
      rpc.response = {
        'status': 'created',
        'crop_variety_id': _varietyId,
        'profile_id': _profileId,
        'crop_id': _cropId,
        'name': 'San Marzano',
        'scientific_name': 'Solanum lycopersicum var. San Marzano',
        'is_active': true,
        'row_version': 1,
        'created_at': '2026-09-13T15:30:00+00:00',
      };

      final result = await _repository(rpc).createCropVariety(
        cropId: _cropId,
        name: 'San Marzano',
        scientificName: 'Solanum lycopersicum var. San Marzano',
        description: 'Varietà di prova',
        defaultStartMethod: 'nursery_then_transplant',
        rowSpacingCm: 80,
        plantSpacingCm: 40,
        sowingDepthCm: 1.5,
        germinationDays: 8,
        harvestDays: 90,
        minTemperature: 10,
        optimalTemperature: 24,
        waterRequirement: 'Regolare',
        waterRequirementValue: 2.5,
        waterRequirementBasis: 'per_plant',
        waterIntervalDays: 2,
        productivity: 'Alta',
        expectedYieldMin: 3,
        expectedYieldAvg: 4.5,
        expectedYieldMax: 6,
        expectedYieldUnit: 'kg_per_plant',
        yieldSourceName: 'Fonte',
        yieldSourceUrl: 'https://example.test/san-marzano',
        yieldSourceYear: 2026,
        yieldNotes: 'Note',
      );

      expect(result, isA<CropVarietyCreated>());

      final created = result as CropVarietyCreated;

      expect(created.cropVarietyId, _varietyId);
      expect(created.profileId, _profileId);
      expect(created.cropId, _cropId);
      expect(created.name, 'San Marzano');
      expect(created.scientificName, 'Solanum lycopersicum var. San Marzano');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);

      expect(rpc.functionName, 'create_crop_variety');

      expect(rpc.parameters!['target_profile_id'], _profileId);
      expect(rpc.parameters!['target_crop_id'], _cropId);
      expect(rpc.parameters!['target_client_id'], _clientInstanceId);
      expect(rpc.parameters!['target_session_id'], _sessionId);
      expect(rpc.parameters!['lock_token'], _fakeToken);

      expect(rpc.parameters!['variety_name'], 'San Marzano');
      expect(
        rpc.parameters!['variety_default_start_method'],
        'nursery_then_transplant',
      );
      expect(rpc.parameters!['variety_water_requirement_value'], 2.5);
      expect(rpc.parameters!['variety_expected_yield_avg'], 4.5);
      expect(rpc.parameters!['variety_yield_source_year'], 2026);
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<CreateCropVarietyForbidden>(),
      'write_forbidden': isA<CreateCropVarietyWriteForbidden>(),
      'not_found': isA<CreateCropVarietyNotFound>(),
      'invalid_input': isA<CreateCropVarietyInvalidInput>(),
      'duplicate_name': isA<CreateCropVarietyDuplicateName>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key}', () async {
        rpc.response = {'status': entry.key};

        final result = await _repository(
          rpc,
        ).createCropVariety(cropId: _cropId, name: 'San Marzano');

        expect(result, entry.value);
      });
    }

    test('maps blocked_by_inactive_crop', () async {
      rpc.response = {
        'status': 'blocked_by_inactive_crop',
        'crop_id': _cropId,
        'crop_name': 'Pomodoro',
      };

      final result = await _repository(
        rpc,
      ).createCropVariety(cropId: _cropId, name: 'San Marzano');

      expect(result, isA<CreateCropVarietyBlockedByInactiveCrop>());

      final blocked = result as CreateCropVarietyBlockedByInactiveCrop;

      expect(blocked.crop.cropId, _cropId);
      expect(blocked.crop.cropName, 'Pomodoro');
    });
  });

  group('updateCropVariety', () {
    test('maps updated', () async {
      rpc.response = {
        'status': 'updated',
        'crop_variety_id': _varietyId,
        'profile_id': _profileId,
        'crop_id': _cropId,
        'name': 'San Marzano aggiornato',
        'scientific_name': null,
        'row_version': 4,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final result = await _repository(rpc).updateCropVariety(
        cropVarietyId: _varietyId,
        expectedRowVersion: 3,
        name: 'San Marzano aggiornato',
      );

      expect(result, isA<CropVarietyUpdated>());

      final updated = result as CropVarietyUpdated;

      expect(updated.cropVarietyId, _varietyId);
      expect(updated.cropId, _cropId);
      expect(updated.rowVersion, 4);

      expect(rpc.functionName, 'update_crop_variety');
      expect(rpc.parameters!['target_crop_variety_id'], _varietyId);
      expect(rpc.parameters!['expected_row_version'], 3);
    });

    test('maps unchanged', () async {
      rpc.response = {
        'status': 'unchanged',
        'crop_variety_id': _varietyId,
        'crop_id': _cropId,
        'row_version': 3,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final result = await _repository(rpc).updateCropVariety(
        cropVarietyId: _varietyId,
        expectedRowVersion: 3,
        name: 'San Marzano',
      );

      expect(result, isA<UpdateCropVarietyUnchanged>());
    });

    test('maps version_conflict', () async {
      rpc.response = {
        'status': 'version_conflict',
        'crop_variety_id': _varietyId,
        'expected_row_version': 3,
        'current_row_version': 4,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final result = await _repository(rpc).updateCropVariety(
        cropVarietyId: _varietyId,
        expectedRowVersion: 3,
        name: 'San Marzano',
      );

      expect(result, isA<UpdateCropVarietyVersionConflict>());
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<UpdateCropVarietyForbidden>(),
      'write_forbidden': isA<UpdateCropVarietyWriteForbidden>(),
      'not_found': isA<UpdateCropVarietyNotFound>(),
      'invalid_input': isA<UpdateCropVarietyInvalidInput>(),
      'duplicate_name': isA<UpdateCropVarietyDuplicateName>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key}', () async {
        rpc.response = {'status': entry.key};

        final result = await _repository(rpc).updateCropVariety(
          cropVarietyId: _varietyId,
          expectedRowVersion: 3,
          name: 'San Marzano',
        );

        expect(result, entry.value);
      });
    }
  });

  group('setCropVarietyActive', () {
    test('maps updated', () async {
      rpc.response = {
        'status': 'updated',
        'crop_variety_id': _varietyId,
        'profile_id': _profileId,
        'crop_id': _cropId,
        'is_active': false,
        'row_version': 5,
        'updated_at': '2026-09-13T15:50:00+00:00',
      };

      final result = await _repository(rpc).setCropVarietyActive(
        cropVarietyId: _varietyId,
        expectedRowVersion: 4,
        isActive: false,
      );

      expect(result, isA<CropVarietyActiveUpdated>());
      expect(rpc.functionName, 'set_crop_variety_active');
      expect(rpc.parameters!['variety_is_active'], isFalse);
    });

    test('maps unchanged', () async {
      rpc.response = {
        'status': 'unchanged',
        'crop_variety_id': _varietyId,
        'crop_id': _cropId,
        'is_active': false,
        'row_version': 4,
        'updated_at': '2026-09-13T15:50:00+00:00',
      };

      final result = await _repository(rpc).setCropVarietyActive(
        cropVarietyId: _varietyId,
        expectedRowVersion: 4,
        isActive: false,
      );

      expect(result, isA<SetCropVarietyActiveUnchanged>());
    });

    test('maps version_conflict', () async {
      rpc.response = {
        'status': 'version_conflict',
        'crop_variety_id': _varietyId,
        'expected_row_version': 4,
        'current_row_version': 5,
        'updated_at': '2026-09-13T15:50:00+00:00',
      };

      final result = await _repository(rpc).setCropVarietyActive(
        cropVarietyId: _varietyId,
        expectedRowVersion: 4,
        isActive: true,
      );

      expect(result, isA<SetCropVarietyActiveVersionConflict>());
    });

    test('maps blocked_by_inactive_crop', () async {
      rpc.response = {
        'status': 'blocked_by_inactive_crop',
        'crop_variety_id': _varietyId,
        'crop_id': _cropId,
        'crop_name': 'Pomodoro',
      };

      final result = await _repository(rpc).setCropVarietyActive(
        cropVarietyId: _varietyId,
        expectedRowVersion: 4,
        isActive: true,
      );

      expect(result, isA<SetCropVarietyActiveBlockedByInactiveCrop>());

      final blocked = result as SetCropVarietyActiveBlockedByInactiveCrop;

      expect(blocked.cropVarietyId, _varietyId);
      expect(blocked.crop.cropId, _cropId);
      expect(blocked.crop.cropName, 'Pomodoro');
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<SetCropVarietyActiveForbidden>(),
      'write_forbidden': isA<SetCropVarietyActiveWriteForbidden>(),
      'not_found': isA<SetCropVarietyActiveNotFound>(),
      'invalid_input': isA<SetCropVarietyActiveInvalidInput>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key}', () async {
        rpc.response = {'status': entry.key};

        final result = await _repository(rpc).setCropVarietyActive(
          cropVarietyId: _varietyId,
          expectedRowVersion: 4,
          isActive: true,
        );

        expect(result, entry.value);
      });
    }
  });

  group('protocol validation', () {
    test('rejects unknown status', () async {
      rpc.response = {'status': 'unexpected'};

      await expectLater(
        _repository(
          rpc,
        ).createCropVariety(cropId: _cropId, name: 'San Marzano'),
        throwsA(isA<CropVarietyWriteProtocolException>()),
      );
    });

    test('rejects malformed blocked_by_inactive_crop', () async {
      rpc.response = {'status': 'blocked_by_inactive_crop', 'crop_id': _cropId};

      await expectLater(
        _repository(
          rpc,
        ).createCropVariety(cropId: _cropId, name: 'San Marzano'),
        throwsA(isA<CropVarietyWriteProtocolException>()),
      );
    });
  });
}
