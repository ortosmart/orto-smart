import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/crop_write_result.dart';
import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';
import '../models/crop.dart';

typedef CropListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef CropRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

typedef CropWriteAuthorityProvider = ProfileEditLockLease Function();

class CropRepository {
  final CropListLoader _loadCrops;
  final CropRpcInvoker _invokeRpc;
  final CropWriteAuthorityProvider? _requireLeaseForWrite;

  factory CropRepository({
    SupabaseClient? supabase,
    CropWriteAuthorityProvider? requireLeaseForWrite,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return CropRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('crops').select('''
          *,
          botanical_families (
            name
          )
          ''');

        if (activeOnly) {
          query = query.eq('is_active', true);
        }

        query = query.order('name');

        final response = await query;

        return (response as List).map((item) {
          final map = Map<String, dynamic>.from(item as Map);

          final botanicalFamily = map['botanical_families'];

          if (botanicalFamily is Map) {
            map['botanical_family_name'] = botanicalFamily['name'] as String?;
          }

          map.remove('botanical_families');

          return map;
        }).toList();
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
      requireLeaseForWrite,
    );
  }

  CropRepository.withProviders(
    this._loadCrops,
    this._invokeRpc, [
    this._requireLeaseForWrite,
  ]);

  CropRepository.withLoader(CropListLoader loadCrops)
    : _loadCrops = loadCrops,
      _invokeRpc = _unavailableRpcInvoker,
      _requireLeaseForWrite = null;

  Future<List<Crop>> getCrops({bool activeOnly = true}) async {
    final response = await _loadCrops(activeOnly: activeOnly);

    return response.map(Crop.fromMap).toList();
  }

  Future<CreateCropResult> createCrop({
    required String botanicalFamilyId,
    required String name,
    String? scientificName,
    String? description,
    String? defaultStartMethod,
    int? rowSpacingCm,
    int? plantSpacingCm,
    double? sowingDepthCm,
    int? germinationDays,
    int? harvestDays,
    int? minTemperature,
    int? optimalTemperature,
    int? rotationSeasons,
    String? waterRequirement,
    double? waterRequirementValue,
    String? waterRequirementBasis,
    int? waterIntervalDays,
    String? productivity,
    double? expectedYieldMin,
    double? expectedYieldAvg,
    double? expectedYieldMax,
    String? expectedYieldUnit,
    String? yieldSourceName,
    String? yieldSourceUrl,
    int? yieldSourceYear,
    String? yieldNotes,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('create_crop', {
      'target_profile_id': lease.profileId,
      'target_botanical_family_id': botanicalFamilyId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      ..._cropParameters(
        name: name,
        scientificName: scientificName,
        description: description,
        defaultStartMethod: defaultStartMethod,
        rowSpacingCm: rowSpacingCm,
        plantSpacingCm: plantSpacingCm,
        sowingDepthCm: sowingDepthCm,
        germinationDays: germinationDays,
        harvestDays: harvestDays,
        minTemperature: minTemperature,
        optimalTemperature: optimalTemperature,
        rotationSeasons: rotationSeasons,
        waterRequirement: waterRequirement,
        waterRequirementValue: waterRequirementValue,
        waterRequirementBasis: waterRequirementBasis,
        waterIntervalDays: waterIntervalDays,
        productivity: productivity,
        expectedYieldMin: expectedYieldMin,
        expectedYieldAvg: expectedYieldAvg,
        expectedYieldMax: expectedYieldMax,
        expectedYieldUnit: expectedYieldUnit,
        yieldSourceName: yieldSourceName,
        yieldSourceUrl: yieldSourceUrl,
        yieldSourceYear: yieldSourceYear,
        yieldNotes: yieldNotes,
      ),
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => CropCreated(
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        name: _requiredNonEmptyString(payload, 'name'),
        scientificName: _optionalString(payload, 'scientific_name'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateCropForbidden(),
      'write_forbidden' => const CreateCropWriteForbidden(),
      'not_found' => const CreateCropNotFound(),
      'invalid_input' => const CreateCropInvalidInput(),
      'duplicate_name' => const CreateCropDuplicateName(),
      'duplicate_scientific_name' => const CreateCropDuplicateScientificName(),
      'blocked_by_inactive_botanical_family' =>
        CreateCropBlockedByInactiveBotanicalFamily(
          botanicalFamily: _inactiveBotanicalFamilyReference(payload),
        ),
      _ => throw const CropWriteProtocolException(),
    };
  }

  Future<UpdateCropResult> updateCrop({
    required String cropId,
    required int expectedRowVersion,
    required String botanicalFamilyId,
    required String name,
    String? scientificName,
    String? description,
    String? defaultStartMethod,
    int? rowSpacingCm,
    int? plantSpacingCm,
    double? sowingDepthCm,
    int? germinationDays,
    int? harvestDays,
    int? minTemperature,
    int? optimalTemperature,
    int? rotationSeasons,
    String? waterRequirement,
    double? waterRequirementValue,
    String? waterRequirementBasis,
    int? waterIntervalDays,
    String? productivity,
    double? expectedYieldMin,
    double? expectedYieldAvg,
    double? expectedYieldMax,
    String? expectedYieldUnit,
    String? yieldSourceName,
    String? yieldSourceUrl,
    int? yieldSourceYear,
    String? yieldNotes,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('update_crop', {
      'target_profile_id': lease.profileId,
      'target_crop_id': cropId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'target_botanical_family_id': botanicalFamilyId,
      ..._cropParameters(
        name: name,
        scientificName: scientificName,
        description: description,
        defaultStartMethod: defaultStartMethod,
        rowSpacingCm: rowSpacingCm,
        plantSpacingCm: plantSpacingCm,
        sowingDepthCm: sowingDepthCm,
        germinationDays: germinationDays,
        harvestDays: harvestDays,
        minTemperature: minTemperature,
        optimalTemperature: optimalTemperature,
        rotationSeasons: rotationSeasons,
        waterRequirement: waterRequirement,
        waterRequirementValue: waterRequirementValue,
        waterRequirementBasis: waterRequirementBasis,
        waterIntervalDays: waterIntervalDays,
        productivity: productivity,
        expectedYieldMin: expectedYieldMin,
        expectedYieldAvg: expectedYieldAvg,
        expectedYieldMax: expectedYieldMax,
        expectedYieldUnit: expectedYieldUnit,
        yieldSourceName: yieldSourceName,
        yieldSourceUrl: yieldSourceUrl,
        yieldSourceYear: yieldSourceYear,
        yieldNotes: yieldNotes,
      ),
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => CropUpdated(
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        name: _requiredNonEmptyString(payload, 'name'),
        scientificName: _optionalString(payload, 'scientific_name'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateCropUnchanged(
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => UpdateCropVersionConflict(
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
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
      'forbidden' => const UpdateCropForbidden(),
      'write_forbidden' => const UpdateCropWriteForbidden(),
      'not_found' => const UpdateCropNotFound(),
      'invalid_input' => const UpdateCropInvalidInput(),
      'duplicate_name' => const UpdateCropDuplicateName(),
      'duplicate_scientific_name' => const UpdateCropDuplicateScientificName(),
      'blocked_by_inactive_botanical_family' =>
        UpdateCropBlockedByInactiveBotanicalFamily(
          botanicalFamily: _inactiveBotanicalFamilyReference(payload),
        ),
      _ => throw const CropWriteProtocolException(),
    };
  }

  Future<SetCropActiveResult> setCropActive({
    required String cropId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('set_crop_active', {
      'target_profile_id': lease.profileId,
      'target_crop_id': cropId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'crop_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => CropActiveUpdated(
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetCropActiveUnchanged(
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => SetCropActiveVersionConflict(
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
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
      'forbidden' => const SetCropActiveForbidden(),
      'write_forbidden' => const SetCropActiveWriteForbidden(),
      'not_found' => const SetCropActiveNotFound(),
      'invalid_input' => const SetCropActiveInvalidInput(),
      'blocked_by_inactive_botanical_family' =>
        SetCropActiveBlockedByInactiveBotanicalFamily(
          cropId: _requiredNonEmptyString(payload, 'crop_id'),
          botanicalFamily: _inactiveBotanicalFamilyReference(payload),
        ),
      'blocked_by_active_crop_varieties' =>
        SetCropActiveBlockedByActiveCropVarieties(
          cropId: _requiredNonEmptyString(payload, 'crop_id'),
          activeCropVarieties: _activeCropVarietyReferences(payload),
        ),
      _ => throw const CropWriteProtocolException(),
    };
  }

  ProfileEditLockLease _requireWriteLease() {
    final provider = _requireLeaseForWrite;

    if (provider == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    return provider();
  }

  Map<String, dynamic> _cropParameters({
    required String name,
    String? scientificName,
    String? description,
    String? defaultStartMethod,
    int? rowSpacingCm,
    int? plantSpacingCm,
    double? sowingDepthCm,
    int? germinationDays,
    int? harvestDays,
    int? minTemperature,
    int? optimalTemperature,
    int? rotationSeasons,
    String? waterRequirement,
    double? waterRequirementValue,
    String? waterRequirementBasis,
    int? waterIntervalDays,
    String? productivity,
    double? expectedYieldMin,
    double? expectedYieldAvg,
    double? expectedYieldMax,
    String? expectedYieldUnit,
    String? yieldSourceName,
    String? yieldSourceUrl,
    int? yieldSourceYear,
    String? yieldNotes,
  }) {
    return {
      'crop_name': name,
      'crop_scientific_name': scientificName,
      'crop_description': description,
      'crop_default_start_method': defaultStartMethod,
      'crop_row_spacing_cm': rowSpacingCm,
      'crop_plant_spacing_cm': plantSpacingCm,
      'crop_sowing_depth_cm': sowingDepthCm,
      'crop_germination_days': germinationDays,
      'crop_harvest_days': harvestDays,
      'crop_min_temperature': minTemperature,
      'crop_optimal_temperature': optimalTemperature,
      'crop_rotation_seasons': rotationSeasons,
      'crop_water_requirement': waterRequirement,
      'crop_water_requirement_value': waterRequirementValue,
      'crop_water_requirement_basis': waterRequirementBasis,
      'crop_water_interval_days': waterIntervalDays,
      'crop_productivity': productivity,
      'crop_expected_yield_min': expectedYieldMin,
      'crop_expected_yield_avg': expectedYieldAvg,
      'crop_expected_yield_max': expectedYieldMax,
      'crop_expected_yield_unit': expectedYieldUnit,
      'crop_yield_source_name': yieldSourceName,
      'crop_yield_source_url': yieldSourceUrl,
      'crop_yield_source_year': yieldSourceYear,
      'crop_yield_notes': yieldNotes,
    };
  }

  InactiveBotanicalFamilyReference _inactiveBotanicalFamilyReference(
    Map<String, dynamic> payload,
  ) {
    return InactiveBotanicalFamilyReference(
      botanicalFamilyId: _requiredNonEmptyString(
        payload,
        'botanical_family_id',
      ),
      botanicalFamilyName: _requiredNonEmptyString(
        payload,
        'botanical_family_name',
      ),
    );
  }

  List<ActiveCropVarietyReference> _activeCropVarietyReferences(
    Map<String, dynamic> payload,
  ) {
    final value = payload['active_crop_varieties'];

    if (value is! List) {
      throw const CropWriteProtocolException();
    }

    return value
        .map((item) {
          if (item is! Map) {
            throw const CropWriteProtocolException();
          }

          final map = Map<String, dynamic>.from(item);

          return ActiveCropVarietyReference(
            cropVarietyId: _requiredNonEmptyString(map, 'crop_variety_id'),
            name: _requiredNonEmptyString(map, 'name'),
          );
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const CropWriteProtocolException();
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const CropWriteProtocolException();
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const CropWriteProtocolException();
    }

    return value;
  }

  String? _optionalString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw const CropWriteProtocolException();
    }

    return value;
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const CropWriteProtocolException();
    }

    return value;
  }

  bool _requiredBoolean(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const CropWriteProtocolException();
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const CropWriteProtocolException();
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const CropWriteProtocolException();
    }

    return parsed.toUtc();
  }

  static Future<dynamic> _unavailableRpcInvoker(
    String functionName,
    Map<String, dynamic> parameters,
  ) {
    throw StateError('RPC invoker not configured');
  }
}
