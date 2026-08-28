import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/season_write_result.dart';
import 'package:orto_app/data/repositories/season_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';
const _seasonId = '33333333-3333-4333-8333-333333333333';
const _clientInstanceId = '44444444-4444-4444-8444-444444444444';
const _sessionId = '55555555-5555-4555-8555-555555555555';
const _fakeToken = 'token-esclusivamente-fittizio';

const _identity = AppSessionIdentity(
  clientInstanceId: _clientInstanceId,
  sessionId: _sessionId,
);

ProfileEditLockLease _lease({int rowVersion = 1}) {
  return ProfileEditLockLease(
    profileId: _profileId,
    identity: _identity,
    lockToken: _fakeToken,
    expiresAt: DateTime.utc(2026, 8, 28, 14),
    rowVersion: rowVersion,
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

Future<Map<String, dynamic>> _unusedActiveSeasonLoader() {
  throw StateError('Active Season loader not expected');
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
        final repository = SeasonRepository.withProviders(
          _unusedActiveSeasonLoader,
          rpc.call,
        );

        await expectLater(
          repository.createSeason(
            gardenId: _gardenId,
            year: 2026,
            name: 'Stagione 2026',
            startDate: DateTime(2026, 1, 1),
          ),
          throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
        );

        expect(rpc.callCount, 0);
        expect(rpc.functionName, isNull);
        expect(rpc.parameters, isNull);
      },
    );
  });
  group('createSeason', () {
    test(
      'invokes create_season and maps a complete created response',
      () async {
        rpc.response = {
          'status': 'created',
          'season_id': _seasonId,
          'garden_id': _gardenId,
          'year': 2026,
          'is_active': false,
          'row_version': 1,
          'created_at': '2026-08-28T12:30:00+00:00',
        };

        final lease = _lease();
        final repository = SeasonRepository.withProviders(
          _unusedActiveSeasonLoader,
          rpc.call,
          () => lease,
        );

        final result = await repository.createSeason(
          gardenId: _gardenId,
          year: 2026,
          name: 'Stagione 2026',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 12, 31),
          notes: 'Prima stagione autoritativa',
        );

        expect(result, isA<SeasonCreated>());

        final created = result as SeasonCreated;

        expect(created.seasonId, _seasonId);
        expect(created.gardenId, _gardenId);
        expect(created.year, 2026);
        expect(created.isActive, isFalse);
        expect(created.rowVersion, 1);
        expect(created.createdAt, DateTime.utc(2026, 8, 28, 12, 30));

        expect(rpc.callCount, 1);
        expect(rpc.functionName, 'create_season');
        expect(rpc.parameters, {
          'target_profile_id': _profileId,
          'target_garden_id': _gardenId,
          'target_client_id': _clientInstanceId,
          'target_session_id': _sessionId,
          'lock_token': _fakeToken,
          'season_year': 2026,
          'season_name': 'Stagione 2026',
          'season_start_date': '2026-01-01',
          'season_end_date': '2026-12-31',
          'season_notes': 'Prima stagione autoritativa',
        });
      },
    );
  });
  group('createSeason status mapping', () {
    final statusCases = <String, Matcher>{
      'forbidden': isA<CreateSeasonForbidden>(),
      'write_forbidden': isA<CreateSeasonWriteForbidden>(),
      'not_found': isA<CreateSeasonNotFound>(),
      'invalid_input': isA<CreateSeasonInvalidInput>(),
      'duplicate_year': isA<CreateSeasonDuplicateYear>(),
    };

    for (final statusCase in statusCases.entries) {
      test('maps ${statusCase.key}', () async {
        rpc.response = {'status': statusCase.key};

        final repository = SeasonRepository.withProviders(
          _unusedActiveSeasonLoader,
          rpc.call,
          _lease,
        );

        final result = await repository.createSeason(
          gardenId: _gardenId,
          year: 2026,
          name: 'Stagione 2026',
          startDate: DateTime(2026, 1, 1),
        );

        expect(result, statusCase.value);
      });
    }

    test('rejects an unknown status', () async {
      rpc.response = {'status': 'unexpected'};

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      await expectLater(
        repository.createSeason(
          gardenId: _gardenId,
          year: 2026,
          name: 'Stagione 2026',
          startDate: DateTime(2026, 1, 1),
        ),
        throwsA(isA<SeasonWriteProtocolException>()),
      );
    });

    test('rejects an incomplete created response', () async {
      rpc.response = {
        'status': 'created',
        'season_id': _seasonId,
        'garden_id': _gardenId,
        'year': 2026,
        'is_active': false,
        'row_version': 1,
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      await expectLater(
        repository.createSeason(
          gardenId: _gardenId,
          year: 2026,
          name: 'Stagione 2026',
          startDate: DateTime(2026, 1, 1),
        ),
        throwsA(isA<SeasonWriteProtocolException>()),
      );
    });
  });
  group('updateSeason', () {
    test('invokes update_season and maps updated', () async {
      rpc.response = {
        'status': 'updated',
        'season_id': _seasonId,
        'garden_id': _gardenId,
        'year': 2027,
        'row_version': 4,
        'updated_at': '2026-08-28T12:45:00+00:00',
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.updateSeason(
        seasonId: _seasonId,
        expectedRowVersion: 3,
        year: 2027,
        name: 'Stagione 2027',
        startDate: DateTime(2027, 1, 2),
        endDate: DateTime(2027, 11, 30),
        notes: 'Aggiornata',
      );

      expect(result, isA<SeasonUpdated>());

      final updated = result as SeasonUpdated;

      expect(updated.seasonId, _seasonId);
      expect(updated.gardenId, _gardenId);
      expect(updated.year, 2027);
      expect(updated.rowVersion, 4);
      expect(updated.updatedAt, DateTime.utc(2026, 8, 28, 12, 45));

      expect(rpc.callCount, 1);
      expect(rpc.functionName, 'update_season');
      expect(rpc.parameters, {
        'target_profile_id': _profileId,
        'target_season_id': _seasonId,
        'expected_row_version': 3,
        'target_client_id': _clientInstanceId,
        'target_session_id': _sessionId,
        'lock_token': _fakeToken,
        'season_year': 2027,
        'season_name': 'Stagione 2027',
        'season_start_date': '2027-01-02',
        'season_end_date': '2027-11-30',
        'season_notes': 'Aggiornata',
      });
    });

    test('maps version_conflict with both row versions', () async {
      rpc.response = {
        'status': 'version_conflict',
        'season_id': _seasonId,
        'expected_row_version': 3,
        'current_row_version': 5,
        'updated_at': '2026-08-28T12:50:00+00:00',
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.updateSeason(
        seasonId: _seasonId,
        expectedRowVersion: 3,
        year: 2027,
        name: 'Stagione 2027',
        startDate: DateTime(2027, 1, 2),
      );

      expect(result, isA<UpdateSeasonVersionConflict>());

      final conflict = result as UpdateSeasonVersionConflict;

      expect(conflict.seasonId, _seasonId);
      expect(conflict.expectedRowVersion, 3);
      expect(conflict.currentRowVersion, 5);
      expect(conflict.updatedAt, DateTime.utc(2026, 8, 28, 12, 50));
    });
  });
  group('updateSeason status mapping', () {
    test('maps unchanged without inventing a new row version', () async {
      rpc.response = {
        'status': 'unchanged',
        'season_id': _seasonId,
        'garden_id': _gardenId,
        'row_version': 3,
        'updated_at': '2026-08-28T12:55:00+00:00',
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.updateSeason(
        seasonId: _seasonId,
        expectedRowVersion: 3,
        year: 2026,
        name: 'Stagione 2026',
        startDate: DateTime(2026, 1, 1),
      );

      expect(result, isA<UpdateSeasonUnchanged>());

      final unchanged = result as UpdateSeasonUnchanged;

      expect(unchanged.seasonId, _seasonId);
      expect(unchanged.gardenId, _gardenId);
      expect(unchanged.rowVersion, 3);
      expect(unchanged.updatedAt, DateTime.utc(2026, 8, 28, 12, 55));
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<UpdateSeasonForbidden>(),
      'write_forbidden': isA<UpdateSeasonWriteForbidden>(),
      'not_found': isA<UpdateSeasonNotFound>(),
      'invalid_input': isA<UpdateSeasonInvalidInput>(),
      'duplicate_year': isA<UpdateSeasonDuplicateYear>(),
    };

    for (final statusCase in statusCases.entries) {
      test('maps ${statusCase.key}', () async {
        rpc.response = {'status': statusCase.key};

        final repository = SeasonRepository.withProviders(
          _unusedActiveSeasonLoader,
          rpc.call,
          _lease,
        );

        final result = await repository.updateSeason(
          seasonId: _seasonId,
          expectedRowVersion: 3,
          year: 2026,
          name: 'Stagione 2026',
          startDate: DateTime(2026, 1, 1),
        );

        expect(result, statusCase.value);
      });
    }

    test('rejects a non-map response', () async {
      rpc.response = 'updated';

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      await expectLater(
        repository.updateSeason(
          seasonId: _seasonId,
          expectedRowVersion: 3,
          year: 2026,
          name: 'Stagione 2026',
          startDate: DateTime(2026, 1, 1),
        ),
        throwsA(isA<SeasonWriteProtocolException>()),
      );
    });
  });
  group('activateSeason', () {
    test('maps activated with the atomically deactivated season', () async {
      rpc.response = {
        'status': 'activated',
        'season_id': _seasonId,
        'garden_id': _gardenId,
        'row_version': 4,
        'updated_at': '2026-08-28T13:00:00+00:00',
        'deactivated_season_id': '66666666-6666-4666-8666-666666666666',
        'deactivated_row_version': 8,
        'deactivated_updated_at': '2026-08-28T13:00:00+00:00',
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.activateSeason(
        seasonId: _seasonId,
        expectedRowVersion: 3,
      );

      expect(result, isA<SeasonActivated>());

      final activated = result as SeasonActivated;

      expect(activated.seasonId, _seasonId);
      expect(activated.gardenId, _gardenId);
      expect(activated.rowVersion, 4);
      expect(activated.updatedAt, DateTime.utc(2026, 8, 28, 13));

      final deactivated = activated.deactivatedSeason;

      expect(deactivated, isNotNull);
      expect(deactivated!.seasonId, '66666666-6666-4666-8666-666666666666');
      expect(deactivated.rowVersion, 8);
      expect(deactivated.updatedAt, DateTime.utc(2026, 8, 28, 13));

      expect(rpc.callCount, 1);
      expect(rpc.functionName, 'activate_season');
      expect(rpc.parameters, {
        'target_profile_id': _profileId,
        'target_season_id': _seasonId,
        'expected_row_version': 3,
        'target_client_id': _clientInstanceId,
        'target_session_id': _sessionId,
        'lock_token': _fakeToken,
      });
    });

    test('maps activated without a previously active season', () async {
      rpc.response = {
        'status': 'activated',
        'season_id': _seasonId,
        'garden_id': _gardenId,
        'row_version': 2,
        'updated_at': '2026-08-28T13:05:00+00:00',
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.activateSeason(
        seasonId: _seasonId,
        expectedRowVersion: 1,
      );

      expect(result, isA<SeasonActivated>());
      expect((result as SeasonActivated).deactivatedSeason, isNull);
    });

    test('rejects partial deactivated season data', () async {
      rpc.response = {
        'status': 'activated',
        'season_id': _seasonId,
        'garden_id': _gardenId,
        'row_version': 4,
        'updated_at': '2026-08-28T13:10:00+00:00',
        'deactivated_season_id': '66666666-6666-4666-8666-666666666666',
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      await expectLater(
        repository.activateSeason(seasonId: _seasonId, expectedRowVersion: 3),
        throwsA(isA<SeasonWriteProtocolException>()),
      );
    });
  });
  group('activateSeason status mapping', () {
    test('maps unchanged', () async {
      rpc.response = {
        'status': 'unchanged',
        'season_id': _seasonId,
        'garden_id': _gardenId,
        'row_version': 4,
        'updated_at': '2026-08-28T13:15:00+00:00',
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.activateSeason(
        seasonId: _seasonId,
        expectedRowVersion: 4,
      );

      expect(result, isA<ActivateSeasonUnchanged>());

      final unchanged = result as ActivateSeasonUnchanged;

      expect(unchanged.seasonId, _seasonId);
      expect(unchanged.gardenId, _gardenId);
      expect(unchanged.rowVersion, 4);
      expect(unchanged.updatedAt, DateTime.utc(2026, 8, 28, 13, 15));
    });

    test('maps version_conflict', () async {
      rpc.response = {
        'status': 'version_conflict',
        'season_id': _seasonId,
        'expected_row_version': 3,
        'current_row_version': 5,
        'updated_at': '2026-08-28T13:20:00+00:00',
      };

      final repository = SeasonRepository.withProviders(
        _unusedActiveSeasonLoader,
        rpc.call,
        _lease,
      );

      final result = await repository.activateSeason(
        seasonId: _seasonId,
        expectedRowVersion: 3,
      );

      expect(result, isA<ActivateSeasonVersionConflict>());

      final conflict = result as ActivateSeasonVersionConflict;

      expect(conflict.seasonId, _seasonId);
      expect(conflict.expectedRowVersion, 3);
      expect(conflict.currentRowVersion, 5);
      expect(conflict.updatedAt, DateTime.utc(2026, 8, 28, 13, 20));
    });

    final statusCases = <String, Matcher>{
      'forbidden': isA<ActivateSeasonForbidden>(),
      'write_forbidden': isA<ActivateSeasonWriteForbidden>(),
      'not_found': isA<ActivateSeasonNotFound>(),
      'invalid_input': isA<ActivateSeasonInvalidInput>(),
    };

    for (final statusCase in statusCases.entries) {
      test('maps ${statusCase.key}', () async {
        rpc.response = {'status': statusCase.key};

        final repository = SeasonRepository.withProviders(
          _unusedActiveSeasonLoader,
          rpc.call,
          _lease,
        );

        final result = await repository.activateSeason(
          seasonId: _seasonId,
          expectedRowVersion: 3,
        );

        expect(result, statusCase.value);
      });
    }
  });

  group('getActiveSeason', () {
    test('maps row_version into the Season model', () async {
      final repository = SeasonRepository.withProviders(
        () async => {
          'id': _seasonId,
          'garden_id': _gardenId,
          'year': 2026,
          'name': 'Stagione 2026',
          'start_date': '2026-01-01',
          'end_date': '2026-12-31',
          'is_active': true,
          'notes': 'Attiva',
          'row_version': 7,
        },
        rpc.call,
      );

      final season = await repository.getActiveSeason();

      expect(season.id, _seasonId);
      expect(season.gardenId, _gardenId);
      expect(season.year, 2026);
      expect(season.name, 'Stagione 2026');
      expect(season.startDate, DateTime(2026, 1, 1));
      expect(season.endDate, DateTime(2026, 12, 31));
      expect(season.isActive, isTrue);
      expect(season.notes, 'Attiva');
      expect(season.rowVersion, 7);
      expect(rpc.callCount, 0);
    });
  });
}
