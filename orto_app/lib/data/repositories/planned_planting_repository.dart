import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/planned_planting_write_result.dart';
import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';

typedef PlannedPlantingRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

typedef PlannedPlantingWriteAuthorityProvider = ProfileEditLockLease Function();

class PlannedPlantingRepository {
  final PlannedPlantingRpcInvoker _invokeRpc;
  final PlannedPlantingWriteAuthorityProvider? _requireLeaseForWrite;

  factory PlannedPlantingRepository({
    SupabaseClient? supabase,
    required PlannedPlantingWriteAuthorityProvider requireLeaseForWrite,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return PlannedPlantingRepository.withProviders(
      (functionName, parameters) =>
          client.rpc(functionName, params: parameters),
      requireLeaseForWrite,
    );
  }

  PlannedPlantingRepository.withProviders(
    this._invokeRpc,
    this._requireLeaseForWrite,
  );

  Future<CreatePlannedPlantingResult> createPlannedPlanting({
    required String gardenId,
    required String seasonId,
    required String bedId,
    required String cropId,
    String? cultivarId,
    required String startMethod,
    required DateTime startDate,
    required DateTime endDate,
    required int startPositionCm,
    required int lengthCm,
    required int occupiedWidthCm,
    int? plantSpacingCm,
    int? rowSpacingCm,
    int? rowsCount,
    int? plantsCount,
    num? seedQuantityG,
    String? notes,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('create_planned_planting', {
      'target_profile_id': lease.profileId,
      'target_garden_id': gardenId,
      'target_season_id': seasonId,
      'target_bed_id': bedId,
      'target_crop_id': cropId,
      'target_cultivar_id': cultivarId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'planting_start_method': startMethod,
      'planting_start_date': _dateOnly(startDate),
      'planting_end_date': _dateOnly(endDate),
      'planting_start_position_cm': startPositionCm,
      'planting_length_cm': lengthCm,
      'planting_occupied_width_cm': occupiedWidthCm,
      'planting_plant_spacing_cm': plantSpacingCm,
      'planting_row_spacing_cm': rowSpacingCm,
      'planting_rows_count': rowsCount,
      'planting_plants_count': plantsCount,
      'planting_seed_quantity_g': seedQuantityG,
      'planting_notes': notes,
    });

    if (response is! Map) {
      throw const FormatException('Risposta RPC pianificazione non valida.');
    }

    final payload = Map<String, dynamic>.from(response);

    return switch (payload['status']) {
      'created' => _createdPlannedPlanting(payload),
      'forbidden' => const CreatePlannedPlantingForbidden(),
      'write_forbidden' => const CreatePlannedPlantingWriteForbidden(),
      'not_found' => const CreatePlannedPlantingNotFound(),
      'invalid_input' => const CreatePlannedPlantingInvalidInput(),
      'blocked_by_inactive_garden' =>
        const CreatePlannedPlantingInactiveGarden(),
      'blocked_by_inactive_bed' => const CreatePlannedPlantingInactiveBed(),
      'blocked_by_inactive_crop' => const CreatePlannedPlantingInactiveCrop(),
      'blocked_by_inactive_cultivar' =>
        const CreatePlannedPlantingInactiveCultivar(),
      'missing_bed_geometry' => const CreatePlannedPlantingMissingBedGeometry(),
      'outside_bed_geometry' => const CreatePlannedPlantingOutsideBedGeometry(),
      _ => throw const FormatException(
        'Stato RPC creazione pianificazione sconosciuto.',
      ),
    };
  }

  Future<ConfirmPlannedPlantingResult> confirmPlannedPlanting({
    required String plannedPlantingId,
    required int expectedRowVersion,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('confirm_planned_planting', {
      'target_profile_id': lease.profileId,
      'target_planned_planting_id': plannedPlantingId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
    });

    if (response is! Map) {
      throw const FormatException(
        'Risposta RPC conferma pianificazione non valida.',
      );
    }

    final payload = Map<String, dynamic>.from(response);

    return switch (payload['status']) {
      'confirmed' => _confirmedPlannedPlanting(payload),
      'forbidden' => const ConfirmPlannedPlantingForbidden(),
      'write_forbidden' => const ConfirmPlannedPlantingWriteForbidden(),
      'not_found' => const ConfirmPlannedPlantingNotFound(),
      'version_conflict' => const ConfirmPlannedPlantingVersionConflict(),
      'inactive_garden' => const ConfirmPlannedPlantingInactiveGarden(),
      'inactive_bed' => const ConfirmPlannedPlantingInactiveBed(),
      'blocked_by_lifecycle' =>
        const ConfirmPlannedPlantingBlockedByLifecycle(),
      'missing_bed_geometry' =>
        const ConfirmPlannedPlantingMissingBedGeometry(),
      'outside_bed_geometry' =>
        const ConfirmPlannedPlantingOutsideBedGeometry(),
      'overlap' => _confirmPlannedPlantingOverlap(payload),
      _ => throw const FormatException(
        'Stato RPC conferma pianificazione sconosciuto.',
      ),
    };
  }

  static ConfirmPlannedPlantingConfirmed _confirmedPlannedPlanting(
    Map<String, dynamic> payload,
  ) {
    final plannedPlantingId = payload['planned_planting_id'];
    final rowVersion = payload['row_version'];

    if (plannedPlantingId is! String ||
        plannedPlantingId.isEmpty ||
        rowVersion is! int ||
        rowVersion < 1) {
      throw const FormatException(
        'Risposta conferma pianificazione incompleta.',
      );
    }

    return ConfirmPlannedPlantingConfirmed(
      plannedPlantingId: plannedPlantingId,
      rowVersion: rowVersion,
    );
  }

  static ConfirmPlannedPlantingOverlap _confirmPlannedPlantingOverlap(
    Map<String, dynamic> payload,
  ) {
    final bedId = payload['bed_id'];

    if (bedId is! String || bedId.isEmpty) {
      throw const FormatException(
        'Risposta sovrapposizione conferma incompleta.',
      );
    }

    return ConfirmPlannedPlantingOverlap(bedId: bedId);
  }

  Future<CancelPlannedPlantingResult> cancelPlannedPlanting({
    required String plannedPlantingId,
    required int expectedRowVersion,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('cancel_planned_planting', {
      'target_profile_id': lease.profileId,
      'target_planned_planting_id': plannedPlantingId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
    });

    if (response is! Map) {
      throw const FormatException(
        'Risposta RPC annullamento pianificazione non valida.',
      );
    }

    final payload = Map<String, dynamic>.from(response);

    return switch (payload['status']) {
      'cancelled' => _cancelledPlannedPlanting(payload),
      'forbidden' => const CancelPlannedPlantingForbidden(),
      'write_forbidden' => const CancelPlannedPlantingWriteForbidden(),
      'not_found' => const CancelPlannedPlantingNotFound(),
      'version_conflict' => const CancelPlannedPlantingVersionConflict(),
      'blocked_by_lifecycle' => const CancelPlannedPlantingBlockedByLifecycle(),
      _ => throw const FormatException(
        'Stato RPC annullamento pianificazione sconosciuto.',
      ),
    };
  }

  static CancelPlannedPlantingCancelled _cancelledPlannedPlanting(
    Map<String, dynamic> payload,
  ) {
    final plannedPlantingId = payload['planned_planting_id'];
    final rowVersion = payload['row_version'];

    if (plannedPlantingId is! String ||
        plannedPlantingId.isEmpty ||
        rowVersion is! int ||
        rowVersion < 1) {
      throw const FormatException(
        'Risposta annullamento pianificazione incompleta.',
      );
    }

    return CancelPlannedPlantingCancelled(
      plannedPlantingId: plannedPlantingId,
      rowVersion: rowVersion,
    );
  }

  Future<UpdatePlannedPlantingResult> updatePlannedPlanting({
    required String plannedPlantingId,
    required int expectedRowVersion,
    required String bedId,
    required String cropId,
    String? cultivarId,
    required String startMethod,
    required DateTime startDate,
    required DateTime endDate,
    required int startPositionCm,
    required int lengthCm,
    required int occupiedWidthCm,
    int? plantSpacingCm,
    int? rowSpacingCm,
    int? rowsCount,
    int? plantsCount,
    num? seedQuantityG,
    String? notes,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('update_planned_planting', {
      'target_profile_id': lease.profileId,
      'target_planned_planting_id': plannedPlantingId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'planting_bed_id': bedId,
      'planting_crop_id': cropId,
      'planting_cultivar_id': cultivarId,
      'planting_start_method': startMethod,
      'planting_start_date': _dateOnly(startDate),
      'planting_end_date': _dateOnly(endDate),
      'planting_start_position_cm': startPositionCm,
      'planting_length_cm': lengthCm,
      'planting_occupied_width_cm': occupiedWidthCm,
      'planting_plant_spacing_cm': plantSpacingCm,
      'planting_row_spacing_cm': rowSpacingCm,
      'planting_rows_count': rowsCount,
      'planting_plants_count': plantsCount,
      'planting_seed_quantity_g': seedQuantityG,
      'planting_notes': notes,
    });

    if (response is! Map) {
      throw const FormatException(
        'Risposta RPC aggiornamento pianificazione non valida.',
      );
    }

    final payload = Map<String, dynamic>.from(response);

    return switch (payload['status']) {
      'updated' => _updatedPlannedPlanting(payload),
      'forbidden' => const UpdatePlannedPlantingForbidden(),
      'write_forbidden' => const UpdatePlannedPlantingWriteForbidden(),
      'not_found' => const UpdatePlannedPlantingNotFound(),
      'invalid_input' => const UpdatePlannedPlantingInvalidInput(),
      'version_conflict' => const UpdatePlannedPlantingVersionConflict(),
      'blocked_by_lifecycle' => const UpdatePlannedPlantingBlockedByLifecycle(),
      'blocked_by_inactive_garden' =>
        const UpdatePlannedPlantingInactiveGarden(),
      'blocked_by_inactive_bed' => const UpdatePlannedPlantingInactiveBed(),
      'blocked_by_inactive_crop' => const UpdatePlannedPlantingInactiveCrop(),
      'blocked_by_inactive_cultivar' =>
        const UpdatePlannedPlantingInactiveCultivar(),
      'missing_bed_geometry' => const UpdatePlannedPlantingMissingBedGeometry(),
      'outside_bed_geometry' => const UpdatePlannedPlantingOutsideBedGeometry(),
      'overlap' => _overlappingPlannedPlanting(payload),
      _ => throw const FormatException(
        'Stato RPC aggiornamento pianificazione sconosciuto.',
      ),
    };
  }

  static UpdatePlannedPlantingUpdated _updatedPlannedPlanting(
    Map<String, dynamic> payload,
  ) {
    final plantingId = payload['planned_planting_id'];
    final rowVersion = payload['row_version'];

    if (plantingId is! String ||
        plantingId.isEmpty ||
        rowVersion is! int ||
        rowVersion < 1) {
      throw const FormatException(
        'Risposta aggiornamento pianificazione incompleta.',
      );
    }

    return UpdatePlannedPlantingUpdated(
      plannedPlantingId: plantingId,
      rowVersion: rowVersion,
    );
  }

  static UpdatePlannedPlantingOverlap _overlappingPlannedPlanting(
    Map<String, dynamic> payload,
  ) {
    final bedId = payload['bed_id'];

    if (bedId is! String || bedId.isEmpty) {
      throw const FormatException(
        'Risposta sovrapposizione pianificazione incompleta.',
      );
    }

    return UpdatePlannedPlantingOverlap(bedId: bedId);
  }

  static CreatePlannedPlantingCreated _createdPlannedPlanting(
    Map<String, dynamic> payload,
  ) {
    final planId = payload['season_plan_id'];
    final plantingId = payload['planned_planting_id'];
    final rowVersion = payload['row_version'];

    if (planId is! String ||
        planId.isEmpty ||
        plantingId is! String ||
        plantingId.isEmpty ||
        rowVersion is! int ||
        rowVersion < 1) {
      throw const FormatException(
        'Risposta creazione pianificazione incompleta.',
      );
    }

    return CreatePlannedPlantingCreated(
      seasonPlanId: planId,
      plannedPlantingId: plantingId,
      rowVersion: rowVersion,
    );
  }

  ProfileEditLockLease _requireWriteLease() {
    final provider = _requireLeaseForWrite;

    if (provider == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    return provider();
  }

  static String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
