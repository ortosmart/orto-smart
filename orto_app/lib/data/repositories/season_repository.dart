import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';
import '../../core/write_authority/season_write_result.dart';
import '../models/season.dart';

typedef ActiveSeasonLoader = Future<Map<String, dynamic>> Function();

typedef SeasonWriteAuthorityProvider = ProfileEditLockLease Function();

typedef SeasonRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class SeasonRepository {
  final ActiveSeasonLoader _loadActiveSeason;
  final SeasonRpcInvoker _invokeRpc;
  final SeasonWriteAuthorityProvider? _requireLeaseForWrite;

  factory SeasonRepository({
    SupabaseClient? supabase,
    SeasonWriteAuthorityProvider? requireLeaseForWrite,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return SeasonRepository.withProviders(
      () async {
        final response = await client
            .from('seasons')
            .select()
            .eq('is_active', true)
            .limit(1)
            .single();

        return Map<String, dynamic>.from(response);
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
      requireLeaseForWrite,
    );
  }

  SeasonRepository.withProviders(
    this._loadActiveSeason,
    this._invokeRpc, [
    this._requireLeaseForWrite,
  ]);

  Future<Season> getActiveSeason() async {
    final response = await _loadActiveSeason();

    return Season.fromMap(response);
  }

  Future<CreateSeasonResult> createSeason({
    required String gardenId,
    required int year,
    required String name,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('create_season', {
      'target_profile_id': lease.profileId,
      'target_garden_id': gardenId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'season_year': year,
      'season_name': name,
      'season_start_date': _dateOnly(startDate),
      'season_end_date': endDate == null ? null : _dateOnly(endDate),
      'season_notes': notes,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => SeasonCreated(
        seasonId: _requiredNonEmptyString(payload, 'season_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        year: _requiredInteger(payload, 'year'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateSeasonForbidden(),
      'write_forbidden' => const CreateSeasonWriteForbidden(),
      'not_found' => const CreateSeasonNotFound(),
      'invalid_input' => const CreateSeasonInvalidInput(),
      'duplicate_year' => const CreateSeasonDuplicateYear(),
      _ => throw const SeasonWriteProtocolException(),
    };
  }

  Future<UpdateSeasonResult> updateSeason({
    required String seasonId,
    required int expectedRowVersion,
    required int year,
    required String name,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('update_season', {
      'target_profile_id': lease.profileId,
      'target_season_id': seasonId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'season_year': year,
      'season_name': name,
      'season_start_date': _dateOnly(startDate),
      'season_end_date': endDate == null ? null : _dateOnly(endDate),
      'season_notes': notes,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => SeasonUpdated(
        seasonId: _requiredNonEmptyString(payload, 'season_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        year: _requiredInteger(payload, 'year'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateSeasonUnchanged(
        seasonId: _requiredNonEmptyString(payload, 'season_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => UpdateSeasonVersionConflict(
        seasonId: _requiredNonEmptyString(payload, 'season_id'),
        expectedRowVersion: _requiredPositiveInteger(
          payload,
          'expected_row_version',
        ),
        currentRowVersion: _requiredPositiveInteger(
          payload,
          'current_row_version',
        ),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'forbidden' => const UpdateSeasonForbidden(),
      'write_forbidden' => const UpdateSeasonWriteForbidden(),
      'not_found' => const UpdateSeasonNotFound(),
      'invalid_input' => const UpdateSeasonInvalidInput(),
      'duplicate_year' => const UpdateSeasonDuplicateYear(),
      _ => throw const SeasonWriteProtocolException(),
    };
  }

  Future<ActivateSeasonResult> activateSeason({
    required String seasonId,
    required int expectedRowVersion,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('activate_season', {
      'target_profile_id': lease.profileId,
      'target_season_id': seasonId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'activated' => SeasonActivated(
        seasonId: _requiredNonEmptyString(payload, 'season_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
        deactivatedSeason: _optionalDeactivatedSeason(payload),
      ),
      'unchanged' => ActivateSeasonUnchanged(
        seasonId: _requiredNonEmptyString(payload, 'season_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => ActivateSeasonVersionConflict(
        seasonId: _requiredNonEmptyString(payload, 'season_id'),
        expectedRowVersion: _requiredPositiveInteger(
          payload,
          'expected_row_version',
        ),
        currentRowVersion: _requiredPositiveInteger(
          payload,
          'current_row_version',
        ),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'forbidden' => const ActivateSeasonForbidden(),
      'write_forbidden' => const ActivateSeasonWriteForbidden(),
      'not_found' => const ActivateSeasonNotFound(),
      'invalid_input' => const ActivateSeasonInvalidInput(),
      _ => throw const SeasonWriteProtocolException(),
    };
  }

  ProfileEditLockLease _requireWriteLease() {
    final provider = _requireLeaseForWrite;

    if (provider == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    return provider();
  }

  DeactivatedSeason? _optionalDeactivatedSeason(Map<String, dynamic> payload) {
    const keys = [
      'deactivated_season_id',
      'deactivated_row_version',
      'deactivated_updated_at',
    ];

    final hasAnyField = keys.any(payload.containsKey);

    if (!hasAnyField) {
      return null;
    }

    if (!keys.every(payload.containsKey)) {
      throw const SeasonWriteProtocolException();
    }

    return DeactivatedSeason(
      seasonId: _requiredNonEmptyString(payload, 'deactivated_season_id'),
      rowVersion: _requiredPositiveInteger(payload, 'deactivated_row_version'),
      updatedAt: _requiredDateTime(payload, 'deactivated_updated_at'),
    );
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const SeasonWriteProtocolException();
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const SeasonWriteProtocolException();
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const SeasonWriteProtocolException();
    }

    return value;
  }

  int _requiredInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int) {
      throw const SeasonWriteProtocolException();
    }

    return value;
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const SeasonWriteProtocolException();
    }

    return value;
  }

  bool _requiredBoolean(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const SeasonWriteProtocolException();
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const SeasonWriteProtocolException();
    }

    final parsedValue = DateTime.tryParse(value);

    if (parsedValue == null) {
      throw const SeasonWriteProtocolException();
    }

    return parsedValue.toUtc();
  }

  String _dateOnly(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
