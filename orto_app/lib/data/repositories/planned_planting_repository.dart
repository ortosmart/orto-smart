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
      'missing_bed_geometry' =>
        const CreatePlannedPlantingMissingBedGeometry(),
      'outside_bed_geometry' =>
        const CreatePlannedPlantingOutsideBedGeometry(),
      _ => throw const FormatException(
        'Stato RPC creazione pianificazione sconosciuto.',
      ),
    };
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
