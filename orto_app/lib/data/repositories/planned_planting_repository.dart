import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/planned_planting.dart';

import '../../core/write_authority/mutation_operation_contract.dart';
import '../../core/write_authority/planned_planting_write_result.dart';
import '../../core/write_authority/seasonal_planning_mutation_service.dart';
import '../../core/write_authority/seasonal_planning_mutation_transport.dart';
import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';

typedef PlannedPlantingRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

typedef PlannedPlantingWriteAuthorityProvider = ProfileEditLockLease Function();

typedef PlannedPlantingListLoader =
    Future<List<Map<String, dynamic>>> Function(String seasonId);

class PlannedPlantingRepository {
  final PlannedPlantingRpcInvoker _invokeRpc;
  final PlannedPlantingListLoader? _loadPlannedPlantings;
  final PlannedPlantingWriteAuthorityProvider? _requireLeaseForWrite;
  final SeasonalPlanningMutationService? _mutationService;
  final Future<void> Function(MutationRequestSnapshot)? _refreshAfterMutation;

  factory PlannedPlantingRepository({
    SupabaseClient? supabase,
    required PlannedPlantingWriteAuthorityProvider requireLeaseForWrite,
    SeasonalPlanningMutationService? mutationService,
    Future<void> Function(MutationRequestSnapshot)? refreshAfterMutation,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return PlannedPlantingRepository.withProviders(
      (functionName, parameters) =>
          client.rpc(functionName, params: parameters),
      requireLeaseForWrite,
      mutationService: mutationService,
      refreshAfterMutation: refreshAfterMutation,
      loadPlannedPlantings: (seasonId) async {
        final rows = await client
            .from('planned_plantings')
            .select('''
              id, season_plan_id, profile_id, garden_id, season_id,
              bed_id, crop_id, cultivar_id, start_method,
              planned_start_date, planned_end_date,
              start_position_cm, length_cm, occupied_width_cm,
              plant_spacing_cm, row_spacing_cm, rows_count,
              plants_count, seed_quantity_g, status,
              executed_planting_id, notes, created_at,
              updated_at, row_version
            ''')
            .eq('season_id', seasonId)
            .order('planned_start_date', ascending: true)
            .order('start_position_cm', ascending: true)
            .order('id', ascending: true);
        return rows.map((row) => Map<String, dynamic>.from(row)).toList();
      },
    );
  }

  factory PlannedPlantingRepository.readOnly({SupabaseClient? supabase}) {
    return PlannedPlantingRepository(
      supabase: supabase,
      requireLeaseForWrite: () =>
          throw const ProfileWriteAuthorityUnavailableException(),
    );
  }

  PlannedPlantingRepository.withProviders(
    this._invokeRpc,
    this._requireLeaseForWrite, {
    this._loadPlannedPlantings,
    this._mutationService,
    this._refreshAfterMutation,
  });

  Future<bool> canStartMutation() async {
    try {
      final lease = _requireWriteLease();
      final service = _mutationService;
      if (service == null) return true;
      if (!await service.canStartMutation(lease.profileId)) return false;
      final current = _requireWriteLease();
      return current.profileId == lease.profileId &&
          current.identity.clientInstanceId ==
              lease.identity.clientInstanceId &&
          current.identity.sessionId == lease.identity.sessionId &&
          current.lockToken == lease.lockToken;
    } on ProfileWriteAuthorityUnavailableException {
      return false;
    }
  }

  PlannedPlantingRepository forSeasonMutations(String seasonId) {
    final service = _mutationService;
    if (service == null) return this;

    return PlannedPlantingRepository.withProviders(
      _invokeRpc,
      _requireLeaseForWrite,
      loadPlannedPlantings: _loadPlannedPlantings,
      mutationService: service,
      refreshAfterMutation: (snapshot) async {
        final requestedSeason = snapshot.parameters['target_season_id'];
        if (requestedSeason != null && requestedSeason != seasonId) {
          throw StateError('Planning mutation belongs to a different season.');
        }
        await getPlannedPlantingsBySeason(seasonId);
      },
    );
  }

  PlannedPlantingRepository asReadOnly() {
    return PlannedPlantingRepository.withProviders(
      (_, _) async => throw const ProfileWriteAuthorityUnavailableException(),
      null,
      loadPlannedPlantings: _loadPlannedPlantings,
    );
  }

  Future<MutationOperationReceipt?> recoverPendingMutationForSeason(
    String seasonId,
  ) async {
    final service = _mutationService;
    if (service == null) return null;

    final profileId = _requireWriteLease().profileId.toLowerCase();
    return service.recoverTerminalFromJournal(
      profileId: profileId,
      transport: SeasonalPlanningMutationTransport(_invokeRpc),
      refresh: (snapshot) async {
        final requestedSeason = snapshot.parameters['target_season_id'];
        if (requestedSeason != null && requestedSeason != seasonId) {
          throw StateError('Operazione registrata per un’altra stagione.');
        }

        final plantings = await getPlannedPlantingsBySeason(seasonId);
        if (requestedSeason == null) {
          final plantingId = snapshot.parameters['target_planned_planting_id'];
          final belongsToSeason = plantings.any(
            (planting) =>
                planting.id == plantingId &&
                planting.profileId.toLowerCase() == profileId,
          );
          if (!belongsToSeason) {
            throw StateError(
              'Pianificazione non trovata nella stagione aperta.',
            );
          }
        }
      },
    );
  }

  Future<List<PlannedPlanting>> getPlannedPlantingsBySeason(
    String seasonId,
  ) async {
    if (seasonId.trim().isEmpty) {
      throw ArgumentError.value(seasonId, 'seasonId');
    }

    final loader = _loadPlannedPlantings;
    if (loader == null) {
      throw StateError('Loader delle pianificazioni non configurato.');
    }

    final rows = await loader(seasonId);
    final plantings = rows.map(PlannedPlanting.fromMap).toList();

    if (plantings.any((planting) => planting.seasonId != seasonId)) {
      throw const FormatException(
        'Risposta pianificazioni non coerente con la stagione richiesta.',
      );
    }

    return plantings;
  }

  Future<CreatePlannedPlantingResult> createPlannedPlanting({
    required String gardenId,
    required String seasonId,
    required String bedId,
    required String cropId,
    String? cultivarId,
    required String startMethod,
    required DateTime startDate,
    required DateTime? endDate,
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

    final response = await _invokeMutation('create_planned_planting', {
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
      'planting_end_date': endDate == null ? null : _dateOnly(endDate),
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

    final response = await _invokeMutation('confirm_planned_planting', {
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

    final response = await _invokeMutation('cancel_planned_planting', {
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

  Future<ExecutePlannedPlantingResult> executePlannedPlanting({
    required String plannedPlantingId,
    required int expectedRowVersion,
    required DateTime effectiveStartDate,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeMutation('execute_planned_planting', {
      'target_profile_id': lease.profileId,
      'target_planned_planting_id': plannedPlantingId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'effective_start_date': _dateOnly(effectiveStartDate),
    });

    if (response is! Map) {
      throw const FormatException(
        'Risposta RPC esecuzione pianificazione non valida.',
      );
    }

    final payload = Map<String, dynamic>.from(response);

    return switch (payload['status']) {
      'executed' => _executedPlannedPlanting(payload),
      'forbidden' => const ExecutePlannedPlantingForbidden(),
      'write_forbidden' => const ExecutePlannedPlantingWriteForbidden(),
      'not_found' => const ExecutePlannedPlantingNotFound(),
      'invalid_input' => const ExecutePlannedPlantingInvalidInput(),
      'version_conflict' => const ExecutePlannedPlantingVersionConflict(),
      'blocked_by_lifecycle' =>
        const ExecutePlannedPlantingBlockedByLifecycle(),
      'blocked_by_inactive_garden' =>
        const ExecutePlannedPlantingInactiveGarden(),
      'blocked_by_inactive_bed' => const ExecutePlannedPlantingInactiveBed(),
      'blocked_by_inactive_crop' => const ExecutePlannedPlantingInactiveCrop(),
      'blocked_by_inactive_cultivar' =>
        const ExecutePlannedPlantingInactiveCultivar(),
      'outside_bed_geometry' =>
        const ExecutePlannedPlantingOutsideBedGeometry(),
      'overlap' => _executePlannedPlantingOverlap(payload),
      'blocked_by_confirmed_plans' =>
        _executePlannedPlantingBlockedByConfirmedPlans(payload),
      _ => throw const FormatException(
        'Stato RPC esecuzione pianificazione sconosciuto.',
      ),
    };
  }

  static ExecutePlannedPlantingExecuted _executedPlannedPlanting(
    Map<String, dynamic> payload,
  ) {
    final plannedPlantingId = payload['planned_planting_id'];
    final plantingId = payload['planting_id'];
    final effectiveStartDate = payload['effective_start_date'];
    final rowVersion = payload['row_version'];

    if (plannedPlantingId is! String ||
        plannedPlantingId.isEmpty ||
        plantingId is! String ||
        plantingId.isEmpty ||
        effectiveStartDate is! String ||
        rowVersion is! int ||
        rowVersion < 1) {
      throw const FormatException(
        'Risposta esecuzione pianificazione incompleta.',
      );
    }

    final parsedDate = DateTime.tryParse(effectiveStartDate);
    if (parsedDate == null || _dateOnly(parsedDate) != effectiveStartDate) {
      throw const FormatException(
        'Data effettiva esecuzione pianificazione non valida.',
      );
    }

    return ExecutePlannedPlantingExecuted(
      plannedPlantingId: plannedPlantingId,
      plantingId: plantingId,
      effectiveStartDate: parsedDate,
      rowVersion: rowVersion,
    );
  }

  static ExecutePlannedPlantingOverlap _executePlannedPlantingOverlap(
    Map<String, dynamic> payload,
  ) {
    final bedId = payload['bed_id'];

    if (bedId is! String || bedId.isEmpty) {
      throw const FormatException(
        'Risposta sovrapposizione esecuzione incompleta.',
      );
    }

    return ExecutePlannedPlantingOverlap(bedId: bedId);
  }

  static ExecutePlannedPlantingBlockedByConfirmedPlans
  _executePlannedPlantingBlockedByConfirmedPlans(Map<String, dynamic> payload) {
    final bedId = payload['bed_id'];

    if (bedId is! String || bedId.isEmpty) {
      throw const FormatException(
        'Risposta prenotazioni confermate incompleta.',
      );
    }

    return ExecutePlannedPlantingBlockedByConfirmedPlans(bedId: bedId);
  }

  Future<UpdatePlannedPlantingResult> updatePlannedPlanting({
    required String plannedPlantingId,
    required int expectedRowVersion,
    required String bedId,
    required String cropId,
    String? cultivarId,
    required String startMethod,
    required DateTime startDate,
    required DateTime? endDate,
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

    final response = await _invokeMutation('update_planned_planting', {
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
      'planting_end_date': endDate == null ? null : _dateOnly(endDate),
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

  Future<dynamic> _invokeMutation(
    String functionName,
    Map<String, dynamic> parameters,
  ) async {
    final service = _mutationService;
    if (service == null) {
      return _invokeRpc(functionName, parameters);
    }

    final operationType = MutationOperationType.values.singleWhere(
      (type) => type.wireValue == functionName,
    );
    final refresh = _refreshAfterMutation;
    if (refresh == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }
    final transport = SeasonalPlanningMutationTransport(_invokeRpc);
    final result = await service.submit(
      operationType: operationType,
      parameters: Map<String, Object?>.of(parameters)
        ..remove('target_profile_id')
        ..remove('target_client_id')
        ..remove('target_session_id')
        ..remove('lock_token'),
      transport: transport,
      requireLease: _requireWriteLease,
    );
    final receipt = await service.finalizeTerminal(
      snapshot: result.snapshot,
      expectedFingerprint: result.fingerprint,
      transport: transport,
      refresh: () => refresh(result.snapshot),
    );
    return receipt.resultPayload;
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
