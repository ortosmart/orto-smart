import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/planting_write_result.dart';
import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';
import '../models/planting.dart';

typedef PlantingListLoader =
    Future<List<Map<String, dynamic>>> Function(String bedId);

typedef PlantingRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

typedef PlantingWriteAuthorityProvider = ProfileEditLockLease Function();

Future<dynamic> _unavailablePlantingRpcInvoker(
  String functionName,
  Map<String, dynamic> parameters,
) {
  return Future<dynamic>.error(
    const ProfileWriteAuthorityUnavailableException(),
  );
}

class PlantingRepository {
  final PlantingListLoader _loadPlantings;
  final PlantingRpcInvoker _invokeRpc;
  final PlantingWriteAuthorityProvider? _requireLeaseForWrite;

  factory PlantingRepository({
    SupabaseClient? supabase,
    PlantingWriteAuthorityProvider? requireLeaseForWrite,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return PlantingRepository.withProviders(
      (bedId) async {
        final response = await client
            .from('plantings')
            .select('''
              id,
              profile_id,
              garden_id,
              season_id,
              bed_id,
              crop_id,
              variety_id,
              start_method,
              start_date,
              end_date,
              start_position_cm,
              length_cm,
              plant_spacing_cm,
              row_spacing_cm,
              rows_count,
              occupied_width_cm,
              plants_count,
              seed_quantity_g,
              status,
              notes,
              created_at,
              updated_at,
              row_version
            ''')
            .eq('bed_id', bedId)
            .order('start_position_cm', ascending: true)
            .order('start_date', ascending: true);

        return (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
      requireLeaseForWrite,
    );
  }

  PlantingRepository.withProviders(
    this._loadPlantings,
    this._invokeRpc, [
    this._requireLeaseForWrite,
  ]);

  PlantingRepository.withLoader(PlantingListLoader loadPlantings)
    : _loadPlantings = loadPlantings,
      _invokeRpc = _unavailablePlantingRpcInvoker,
      _requireLeaseForWrite = null;

  Future<List<Planting>> getPlantingsByBed(String bedId) async {
    if (bedId.trim().isEmpty) {
      throw ArgumentError.value(bedId, 'bedId', 'Bed ID must not be empty');
    }

    final response = await _loadPlantings(bedId);
    final plantings = response.map(Planting.fromMap).toList();

    if (plantings.any((planting) => planting.bedId != bedId)) {
      throw const FormatException(
        'Planting does not belong to the requested Bed',
      );
    }

    return plantings;
  }

  Future<CreatePlantingResult> createPlanting({
    required String gardenId,
    required String seasonId,
    required String bedId,
    required String cropId,
    String? varietyId,
    required String startMethod,
    required DateTime startDate,
    required int startPositionCm,
    required int lengthCm,
    int? plantSpacingCm,
    int? rowSpacingCm,
    int? rowsCount,
    required int occupiedWidthCm,
    int? plantsCount,
    double? seedQuantityG,
    String? notes,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('create_planting', {
      'target_profile_id': lease.profileId,
      'target_garden_id': gardenId,
      'target_season_id': seasonId,
      'target_bed_id': bedId,
      'target_crop_id': cropId,
      'target_variety_id': varietyId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'planting_start_method': startMethod,
      'planting_start_date': _dateOnly(startDate),
      'planting_start_position_cm': startPositionCm,
      'planting_length_cm': lengthCm,
      'planting_plant_spacing_cm': plantSpacingCm,
      'planting_row_spacing_cm': rowSpacingCm,
      'planting_rows_count': rowsCount,
      'planting_occupied_width_cm': occupiedWidthCm,
      'planting_plants_count': plantsCount,
      'planting_seed_quantity_g': seedQuantityG,
      'planting_notes': notes,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => _createdPlanting(payload),
      'forbidden' => const CreatePlantingForbidden(),
      'write_forbidden' => const CreatePlantingWriteForbidden(),
      'not_found' => const CreatePlantingNotFound(),
      'invalid_input' => const CreatePlantingInvalidInput(),
      'blocked_by_inactive_garden' =>
        const CreatePlantingBlockedByInactiveGarden(),
      'blocked_by_inactive_bed' => const CreatePlantingBlockedByInactiveBed(),
      'blocked_by_inactive_crop' => const CreatePlantingBlockedByInactiveCrop(),
      'blocked_by_inactive_variety' =>
        const CreatePlantingBlockedByInactiveVariety(),
      'outside_bed_geometry' => const CreatePlantingOutsideBedGeometry(),
      'overlap' => const CreatePlantingOverlap(),
      _ => throw const PlantingWriteProtocolException(),
    };
  }

  Future<UpdatePlantingResult> updatePlanting({
    required String plantingId,
    required int expectedRowVersion,
    required String seasonId,
    required String cropId,
    String? varietyId,
    required String startMethod,
    required DateTime startDate,
    required int startPositionCm,
    required int lengthCm,
    int? plantSpacingCm,
    int? rowSpacingCm,
    int? rowsCount,
    required int occupiedWidthCm,
    int? plantsCount,
    double? seedQuantityG,
    String? notes,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('update_planting', {
      'target_profile_id': lease.profileId,
      'target_planting_id': plantingId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'planting_season_id': seasonId,
      'planting_crop_id': cropId,
      'planting_variety_id': varietyId,
      'planting_start_method': startMethod,
      'planting_start_date': _dateOnly(startDate),
      'planting_start_position_cm': startPositionCm,
      'planting_length_cm': lengthCm,
      'planting_plant_spacing_cm': plantSpacingCm,
      'planting_row_spacing_cm': rowSpacingCm,
      'planting_rows_count': rowsCount,
      'planting_occupied_width_cm': occupiedWidthCm,
      'planting_plants_count': plantsCount,
      'planting_seed_quantity_g': seedQuantityG,
      'planting_notes': notes,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => _updatedPlanting(payload),
      'unchanged' => UpdatePlantingUnchanged(
        plantingId: _requiredNonEmptyString(payload, 'planting_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => UpdatePlantingVersionConflict(
        plantingId: _requiredNonEmptyString(payload, 'planting_id'),
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
      'forbidden' => const UpdatePlantingForbidden(),
      'write_forbidden' => const UpdatePlantingWriteForbidden(),
      'not_found' => const UpdatePlantingNotFound(),
      'invalid_input' => const UpdatePlantingInvalidInput(),
      'blocked_by_inactive_crop' => const UpdatePlantingBlockedByInactiveCrop(),
      'blocked_by_inactive_variety' =>
        const UpdatePlantingBlockedByInactiveVariety(),
      'start_method_locked' => const UpdatePlantingStartMethodLocked(),
      'start_date_locked' => const UpdatePlantingStartDateLocked(),
      'outside_bed_geometry' => const UpdatePlantingOutsideBedGeometry(),
      'overlap' => const UpdatePlantingOverlap(),
      _ => throw const PlantingWriteProtocolException(),
    };
  }

  Future<SetPlantingStatusResult> setPlantingStatus({
    required String plantingId,
    required int expectedRowVersion,
    required String status,
    DateTime? endDate,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('set_planting_status', {
      'target_profile_id': lease.profileId,
      'target_planting_id': plantingId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'target_status': status,
      'target_end_date': endDate == null ? null : _dateOnly(endDate),
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => _updatedPlantingStatus(payload),
      'unchanged' => SetPlantingStatusUnchanged(
        plantingId: _requiredNonEmptyString(payload, 'planting_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => SetPlantingStatusVersionConflict(
        plantingId: _requiredNonEmptyString(payload, 'planting_id'),
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
      'invalid_transition' => SetPlantingStatusInvalidTransition(
        plantingId: _requiredNonEmptyString(payload, 'planting_id'),
        currentStatus: _requiredPlantingStatus(payload, 'current_status'),
        targetStatus: _requiredPlantingStatus(payload, 'target_status'),
      ),
      'forbidden' => const SetPlantingStatusForbidden(),
      'write_forbidden' => const SetPlantingStatusWriteForbidden(),
      'not_found' => const SetPlantingStatusNotFound(),
      'invalid_input' => const SetPlantingStatusInvalidInput(),
      _ => throw const PlantingWriteProtocolException(),
    };
  }

  PlantingCreated _createdPlanting(Map<String, dynamic> payload) {
    if (!payload.containsKey('end_date') || payload['end_date'] != null) {
      throw const PlantingWriteProtocolException();
    }

    return PlantingCreated(
      plantingId: _requiredNonEmptyString(payload, 'planting_id'),
      profileId: _requiredNonEmptyString(payload, 'profile_id'),
      gardenId: _requiredNonEmptyString(payload, 'garden_id'),
      seasonId: _requiredNonEmptyString(payload, 'season_id'),
      bedId: _requiredNonEmptyString(payload, 'bed_id'),
      cropId: _requiredNonEmptyString(payload, 'crop_id'),
      varietyId: _optionalNonEmptyString(payload, 'variety_id'),
      startMethod: _requiredStartMethod(payload, 'start_method'),
      startDate: _requiredDate(payload, 'start_date'),
      endDate: null,
      startPositionCm: _requiredNonNegativeInteger(
        payload,
        'start_position_cm',
      ),
      lengthCm: _requiredPositiveInteger(payload, 'length_cm'),
      occupiedWidthCm: _requiredPositiveInteger(payload, 'occupied_width_cm'),
      status: _requiredPlantingStatus(payload, 'status_value'),
      rowVersion: _requiredPositiveInteger(payload, 'row_version'),
      createdAt: _requiredDateTime(payload, 'created_at'),
    );
  }

  PlantingUpdated _updatedPlanting(Map<String, dynamic> payload) {
    return PlantingUpdated(
      plantingId: _requiredNonEmptyString(payload, 'planting_id'),
      gardenId: _requiredNonEmptyString(payload, 'garden_id'),
      bedId: _requiredNonEmptyString(payload, 'bed_id'),
      seasonId: _requiredNonEmptyString(payload, 'season_id'),
      cropId: _requiredNonEmptyString(payload, 'crop_id'),
      varietyId: _optionalNonEmptyString(payload, 'variety_id'),
      startMethod: _requiredStartMethod(payload, 'start_method'),
      startDate: _requiredDate(payload, 'start_date'),
      startPositionCm: _requiredNonNegativeInteger(
        payload,
        'start_position_cm',
      ),
      lengthCm: _requiredPositiveInteger(payload, 'length_cm'),
      occupiedWidthCm: _requiredPositiveInteger(payload, 'occupied_width_cm'),
      status: _requiredPlantingStatus(payload, 'status_value'),
      rowVersion: _requiredPositiveInteger(payload, 'row_version'),
      updatedAt: _requiredDateTime(payload, 'updated_at'),
    );
  }

  PlantingStatusUpdated _updatedPlantingStatus(Map<String, dynamic> payload) {
    final status = _requiredPlantingStatus(payload, 'status_value');
    final endDate = _requiredNullableDate(payload, 'end_date');
    final terminal = status == 'finished' || status == 'removed';

    if ((terminal && endDate == null) || (!terminal && endDate != null)) {
      throw const PlantingWriteProtocolException();
    }

    return PlantingStatusUpdated(
      plantingId: _requiredNonEmptyString(payload, 'planting_id'),
      gardenId: _requiredNonEmptyString(payload, 'garden_id'),
      previousStatus: _requiredPlantingStatus(payload, 'previous_status'),
      status: status,
      startDate: _requiredDate(payload, 'start_date'),
      endDate: endDate,
      rowVersion: _requiredPositiveInteger(payload, 'row_version'),
      updatedAt: _requiredDateTime(payload, 'updated_at'),
    );
  }

  ProfileEditLockLease _requireWriteLease() {
    final provider = _requireLeaseForWrite;

    if (provider == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    return provider();
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const PlantingWriteProtocolException();
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const PlantingWriteProtocolException();
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const PlantingWriteProtocolException();
    }

    return value;
  }

  String? _optionalNonEmptyString(Map<String, dynamic> payload, String key) {
    if (!payload.containsKey(key)) {
      throw const PlantingWriteProtocolException();
    }

    final value = payload[key];

    if (value == null) {
      return null;
    }

    if (value is! String || value.trim().isEmpty) {
      throw const PlantingWriteProtocolException();
    }

    return value;
  }

  String _requiredStartMethod(Map<String, dynamic> payload, String key) {
    final value = _requiredNonEmptyString(payload, key);

    if (!Planting.allowedStartMethods.contains(value)) {
      throw const PlantingWriteProtocolException();
    }

    return value;
  }

  String _requiredPlantingStatus(Map<String, dynamic> payload, String key) {
    final value = _requiredNonEmptyString(payload, key);

    if (!Planting.allowedStatuses.contains(value)) {
      throw const PlantingWriteProtocolException();
    }

    return value;
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const PlantingWriteProtocolException();
    }

    return value;
  }

  int _requiredNonNegativeInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 0) {
      throw const PlantingWriteProtocolException();
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const PlantingWriteProtocolException();
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const PlantingWriteProtocolException();
    }

    return parsed.toUtc();
  }

  DateTime _requiredDate(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw const PlantingWriteProtocolException();
    }

    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(5, 7));
    final day = int.parse(value.substring(8, 10));
    final date = DateTime.utc(year, month, day);

    if (year < 1 ||
        date.year != year ||
        date.month != month ||
        date.day != day) {
      throw const PlantingWriteProtocolException();
    }

    return date;
  }

  DateTime? _requiredNullableDate(Map<String, dynamic> payload, String key) {
    if (!payload.containsKey(key)) {
      throw const PlantingWriteProtocolException();
    }

    if (payload[key] == null) {
      return null;
    }

    return _requiredDate(payload, key);
  }

  String _dateOnly(DateTime value) {
    if (value.year < 1 || value.year > 9999) {
      throw ArgumentError.value(value, 'value', 'Unsupported civil date');
    }

    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
