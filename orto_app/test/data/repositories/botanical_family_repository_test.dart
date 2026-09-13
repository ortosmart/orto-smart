import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/botanical_family_write_result.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/data/repositories/botanical_family_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _familyId = '22222222-2222-4222-8222-222222222222';
const _cropId = '33333333-3333-4333-8333-333333333333';
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
  bool activeOnly = true,
}) async {
  throw StateError('Loader not expected');
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
        final repository = BotanicalFamilyRepository.withProviders(
          _unusedLoader,
          rpc.call,
        );

        await expectLater(
          repository.createBotanicalFamily(name: 'Solanaceae'),
          throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
        );

        expect(rpc.callCount, 0);
      },
    );
  });

  group('createBotanicalFamily', () {
    test('invokes RPC and maps created', () async {
      rpc.response = {
        'status': 'created',
        'botanical_family_id': _familyId,
        'profile_id': _profileId,
        'name': 'Solanaceae',
        'scientific_name': 'Solanaceae',
        'is_active': true,
        'row_version': 1,
        'created_at': '2026-09-13T15:30:00+00:00',
      };

      final repository = BotanicalFamilyRepository.withProviders(
        _unusedLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.createBotanicalFamily(
        name: 'Solanaceae',
        scientificName: 'Solanaceae',
        description: 'Famiglia botanica',
      );

      expect(result, isA<BotanicalFamilyCreated>());

      final created = result as BotanicalFamilyCreated;

      expect(created.botanicalFamilyId, _familyId);
      expect(created.profileId, _profileId);
      expect(created.name, 'Solanaceae');
      expect(created.scientificName, 'Solanaceae');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);

      expect(rpc.functionName, 'create_botanical_family');
      expect(rpc.parameters, {
        'target_profile_id': _profileId,
        'target_client_id': _clientInstanceId,
        'target_session_id': _sessionId,
        'lock_token': _fakeToken,
        'family_name': 'Solanaceae',
        'family_scientific_name': 'Solanaceae',
        'family_description': 'Famiglia botanica',
      });
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<CreateBotanicalFamilyForbidden>(),
      'write_forbidden': isA<CreateBotanicalFamilyWriteForbidden>(),
      'invalid_input': isA<CreateBotanicalFamilyInvalidInput>(),
      'duplicate_name': isA<CreateBotanicalFamilyDuplicateName>(),
      'duplicate_scientific_name':
          isA<CreateBotanicalFamilyDuplicateScientificName>(),
    };

    for (final entry in statusCases.entries) {
      test('maps ${entry.key}', () async {
        rpc.response = {'status': entry.key};

        final repository = BotanicalFamilyRepository.withProviders(
          _unusedLoader,
          rpc.call,
          _lease,
        );

        final result = await repository.createBotanicalFamily(
          name: 'Solanaceae',
        );

        expect(result, entry.value);
      });
    }
  });

  group('updateBotanicalFamily', () {
    test('maps updated', () async {
      rpc.response = {
        'status': 'updated',
        'botanical_family_id': _familyId,
        'profile_id': _profileId,
        'name': 'Solanaceae aggiornate',
        'scientific_name': null,
        'row_version': 4,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final repository = BotanicalFamilyRepository.withProviders(
        _unusedLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.updateBotanicalFamily(
        botanicalFamilyId: _familyId,
        expectedRowVersion: 3,
        name: 'Solanaceae aggiornate',
      );

      expect(result, isA<BotanicalFamilyUpdated>());

      final updated = result as BotanicalFamilyUpdated;
      expect(updated.rowVersion, 4);

      expect(rpc.functionName, 'update_botanical_family');
      expect(rpc.parameters!['expected_row_version'], 3);
    });

    test('maps unchanged', () async {
      rpc.response = {
        'status': 'unchanged',
        'botanical_family_id': _familyId,
        'row_version': 3,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final repository = BotanicalFamilyRepository.withProviders(
        _unusedLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.updateBotanicalFamily(
        botanicalFamilyId: _familyId,
        expectedRowVersion: 3,
        name: 'Solanaceae',
      );

      expect(result, isA<UpdateBotanicalFamilyUnchanged>());
    });

    test('maps version conflict', () async {
      rpc.response = {
        'status': 'version_conflict',
        'botanical_family_id': _familyId,
        'expected_row_version': 3,
        'current_row_version': 4,
        'updated_at': '2026-09-13T15:40:00+00:00',
      };

      final repository = BotanicalFamilyRepository.withProviders(
        _unusedLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.updateBotanicalFamily(
        botanicalFamilyId: _familyId,
        expectedRowVersion: 3,
        name: 'Solanaceae',
      );

      expect(result, isA<UpdateBotanicalFamilyVersionConflict>());
    });
  });

  group('setBotanicalFamilyActive', () {
    test('maps blocked_by_active_crops including references', () async {
      rpc.response = {
        'status': 'blocked_by_active_crops',
        'botanical_family_id': _familyId,
        'active_crops': [
          {'crop_id': _cropId, 'name': 'Pomodoro'},
        ],
      };

      final repository = BotanicalFamilyRepository.withProviders(
        _unusedLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.setBotanicalFamilyActive(
        botanicalFamilyId: _familyId,
        expectedRowVersion: 2,
        isActive: false,
      );

      expect(result, isA<SetBotanicalFamilyActiveBlockedByActiveCrops>());

      final blocked = result as SetBotanicalFamilyActiveBlockedByActiveCrops;

      expect(blocked.botanicalFamilyId, _familyId);
      expect(blocked.activeCrops, hasLength(1));
      expect(blocked.activeCrops.single.cropId, _cropId);
      expect(blocked.activeCrops.single.name, 'Pomodoro');

      expect(rpc.functionName, 'set_botanical_family_active');
      expect(rpc.parameters!['family_is_active'], isFalse);
    });
  });

  group('protocol validation', () {
    test('rejects unknown status', () async {
      rpc.response = {'status': 'unexpected'};

      final repository = BotanicalFamilyRepository.withProviders(
        _unusedLoader,
        rpc.call,
        _lease,
      );

      await expectLater(
        repository.createBotanicalFamily(name: 'Solanaceae'),
        throwsA(isA<BotanicalFamilyWriteProtocolException>()),
      );
    });

    test('rejects malformed active_crops payload', () async {
      rpc.response = {
        'status': 'blocked_by_active_crops',
        'botanical_family_id': _familyId,
        'active_crops': [
          {'crop_id': _cropId},
        ],
      };

      final repository = BotanicalFamilyRepository.withProviders(
        _unusedLoader,
        rpc.call,
        _lease,
      );

      await expectLater(
        repository.setBotanicalFamilyActive(
          botanicalFamilyId: _familyId,
          expectedRowVersion: 2,
          isActive: false,
        ),
        throwsA(isA<BotanicalFamilyWriteProtocolException>()),
      );
    });
  });
}
