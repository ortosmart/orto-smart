import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/crop_write_result.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/data/repositories/crop_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _familyId = '22222222-2222-4222-8222-222222222222';
const _cropId = '33333333-3333-4333-8333-333333333333';
const _varietyId = '44444444-4444-4444-8444-444444444444';
const _clientInstanceId = '55555555-5555-4555-8555-555555555555';
const _sessionId = '66666666-6666-4666-8666-666666666666';
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
  bool activeOnly = true,
}) async {
  throw StateError('Loader not expected');
}

CropRepository _repository(_RpcRecorder rpc, {bool withLease = true}) {
  return CropRepository.withProviders(
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
          repository.createCrop(botanicalFamilyId: _familyId, name: 'Pomodoro'),
          throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
        );

        expect(rpc.callCount, 0);
      },
    );
  });

  group('createCrop', () {
    test('invokes create_crop and maps created', () async {
      rpc.response = {
        'status': 'created',
        'crop_id': _cropId,
        'profile_id': _profileId,
        'botanical_family_id': _familyId,
        'name': 'Pomodoro',
        'scientific_name': 'Solanum lycopersicum',
        'is_active': true,
        'row_version': 1,
        'created_at': '2026-09-13T15:30:00+00:00',
      };

      final repository = _repository(rpc);

      final result = await repository.createCrop(
        botanicalFamilyId: _familyId,
        name: 'Pomodoro',
        scientificName: 'Solanum lycopersicum',
        description: 'Coltura di prova',
        defaultStartMethod: 'nursery_then_transplant',
        rowSpacingCm: 80,
        plantSpacingCm: 40,
        sowingDepthCm: 1.5,
        germinationDays: 8,
        harvestDays: 90,
        minTemperature: 10,
        optimalTemperature: 24,
        rotationSeasons: 3,
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
        yieldSourceUrl: 'https://example.test/pomodoro',
        yieldSourceYear: 2026,
        yieldNotes: 'Note',
      );

      expect(result, isA<CropCreated>());

      final created = result as CropCreated;

      expect(created.cropId, _cropId);
      expect(created.profileId, _profileId);
      expect(created.botanicalFamilyId, _familyId);
      expect(created.name, 'Pomodoro');
      expect(created.scientificName, 'Solanum lycopersicum');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);

      expect(rpc.functionName, 'create_crop');

      expect(rpc.parameters!['target_profile_id'], _profileId);
      expect(rpc.parameters!['target_botanical_family_id'], _familyId);
      expect(rpc.parameters!['target_client_id'], _clientInstanceId);
      expect(rpc.parameters!['target_session_id'], _sessionId);
      expect(rpc.parameters!['lock_token'], _fakeToken);

      expect(rpc.parameters!['crop_name'], 'Pomodoro');
      expect(
        rpc.parameters!['crop_default_start_method'],
        'nursery_then_transplant',
      );
      expect(rpc.parameters!['crop_rotation_seasons'], 3);
      expect(rpc.parameters!['crop_water_requirement_value'], 2.5);
      expect(rpc.parameters!['crop_expected_yield_avg'], 4.5);
      expect(rpc.parameters!['crop_yield_source_year'], 2026);
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<CreateCropForbidden>(),
      'write_forbidden': isA<CreateCropWriteForbidden>(),
      'not_found': isA<CreateCropNotFound>(),
      'invalid_input': isA<CreateCropInvalidInput>(),
      'duplicate_name': isA<CreateCropDuplicateName>(),
      'duplicate_scientific_name': isA<CreateCropDuplicateScientificName>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key}', () async {
        rpc.response = {'status': entry.key};

        final result = await _repository(
          rpc,
        ).createCrop(botanicalFamilyId: _familyId, name: 'Pomodoro');

        expect(result, entry.value);
      });
    }

    test('maps blocked_by_inactive_botanical_family', () async {
      rpc.response = {
        'status': 'blocked_by_inactive_botanical_family',
        'botanical_family_id': _familyId,
        'botanical_family_name': 'Solanaceae',
      };

      final result = await _repository(
        rpc,
      ).createCrop(botanicalFamilyId: _familyId, name: 'Pomodoro');

      expect(result, isA<CreateCropBlockedByInactiveBotanicalFamily>());

      final blocked = result as CreateCropBlockedByInactiveBotanicalFamily;

      expect(blocked.botanicalFamily.botanicalFamilyId, _familyId);
      expect(blocked.botanicalFamily.botanicalFamilyName, 'Solanaceae');
    });
  });

  group('updateCrop', () {
    test('maps updated', () async {
      rpc.response = {
        'status': 'updated',
        'crop_id': _cropId,
        'profile_id': _profileId,
        'botanical_family_id': _familyId,
        'name': 'Pomodoro aggiornato',
        'scientific_name': null,
        'row_version': 4,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final result = await _repository(rpc).updateCrop(
        cropId: _cropId,
        expectedRowVersion: 3,
        botanicalFamilyId: _familyId,
        name: 'Pomodoro aggiornato',
      );

      expect(result, isA<CropUpdated>());

      final updated = result as CropUpdated;
      expect(updated.rowVersion, 4);

      expect(rpc.functionName, 'update_crop');
      expect(rpc.parameters!['target_crop_id'], _cropId);
      expect(rpc.parameters!['expected_row_version'], 3);
      expect(rpc.parameters!['target_botanical_family_id'], _familyId);
    });

    test('maps unchanged', () async {
      rpc.response = {
        'status': 'unchanged',
        'crop_id': _cropId,
        'botanical_family_id': _familyId,
        'row_version': 3,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final result = await _repository(rpc).updateCrop(
        cropId: _cropId,
        expectedRowVersion: 3,
        botanicalFamilyId: _familyId,
        name: 'Pomodoro',
      );

      expect(result, isA<UpdateCropUnchanged>());
    });

    test('maps version_conflict', () async {
      rpc.response = {
        'status': 'version_conflict',
        'crop_id': _cropId,
        'expected_row_version': 3,
        'current_row_version': 4,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final result = await _repository(rpc).updateCrop(
        cropId: _cropId,
        expectedRowVersion: 3,
        botanicalFamilyId: _familyId,
        name: 'Pomodoro',
      );

      expect(result, isA<UpdateCropVersionConflict>());
    });

    test('maps blocked_by_inactive_botanical_family', () async {
      rpc.response = {
        'status': 'blocked_by_inactive_botanical_family',
        'botanical_family_id': _familyId,
        'botanical_family_name': 'Solanaceae',
      };

      final result = await _repository(rpc).updateCrop(
        cropId: _cropId,
        expectedRowVersion: 3,
        botanicalFamilyId: _familyId,
        name: 'Pomodoro',
      );

      expect(result, isA<UpdateCropBlockedByInactiveBotanicalFamily>());
    });
  });

  group('setCropActive', () {
    test('maps updated', () async {
      rpc.response = {
        'status': 'updated',
        'crop_id': _cropId,
        'profile_id': _profileId,
        'botanical_family_id': _familyId,
        'is_active': false,
        'row_version': 5,
        'updated_at': '2026-09-13T15:50:00+00:00',
      };

      final result = await _repository(
        rpc,
      ).setCropActive(cropId: _cropId, expectedRowVersion: 4, isActive: false);

      expect(result, isA<CropActiveUpdated>());
      expect(rpc.functionName, 'set_crop_active');
      expect(rpc.parameters!['crop_is_active'], isFalse);
    });

    test('maps blocked_by_inactive_botanical_family', () async {
      rpc.response = {
        'status': 'blocked_by_inactive_botanical_family',
        'crop_id': _cropId,
        'botanical_family_id': _familyId,
        'botanical_family_name': 'Solanaceae',
      };

      final result = await _repository(
        rpc,
      ).setCropActive(cropId: _cropId, expectedRowVersion: 4, isActive: true);

      expect(result, isA<SetCropActiveBlockedByInactiveBotanicalFamily>());
    });

    test('maps blocked_by_active_crop_varieties', () async {
      rpc.response = {
        'status': 'blocked_by_active_crop_varieties',
        'crop_id': _cropId,
        'active_crop_varieties': [
          {'crop_variety_id': _varietyId, 'name': 'San Marzano'},
        ],
      };

      final result = await _repository(
        rpc,
      ).setCropActive(cropId: _cropId, expectedRowVersion: 4, isActive: false);

      expect(result, isA<SetCropActiveBlockedByActiveCropVarieties>());

      final blocked = result as SetCropActiveBlockedByActiveCropVarieties;

      expect(blocked.cropId, _cropId);
      expect(blocked.activeCropVarieties, hasLength(1));
      expect(blocked.activeCropVarieties.single.cropVarietyId, _varietyId);
      expect(blocked.activeCropVarieties.single.name, 'San Marzano');
    });
  });

  group('protocol validation', () {
    test('rejects unknown status', () async {
      rpc.response = {'status': 'unexpected'};

      await expectLater(
        _repository(
          rpc,
        ).createCrop(botanicalFamilyId: _familyId, name: 'Pomodoro'),
        throwsA(isA<CropWriteProtocolException>()),
      );
    });

    test('rejects malformed active_crop_varieties', () async {
      rpc.response = {
        'status': 'blocked_by_active_crop_varieties',
        'crop_id': _cropId,
        'active_crop_varieties': [
          {'crop_variety_id': _varietyId},
        ],
      };

      await expectLater(
        _repository(rpc).setCropActive(
          cropId: _cropId,
          expectedRowVersion: 4,
          isActive: false,
        ),
        throwsA(isA<CropWriteProtocolException>()),
      );
    });
  });
}
