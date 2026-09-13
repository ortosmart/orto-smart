import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/crop_variety_write_result.dart';
import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';
import '../models/crop_variety.dart';

typedef CropVarietyListLoader =
    Future<List<Map<String, dynamic>>> Function({
      String? cropId,
      bool activeOnly,
    });

typedef CropVarietyRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

typedef CropVarietyWriteAuthorityProvider = ProfileEditLockLease Function();

class CropVarietyRepository {
  final CropVarietyListLoader _loadVarieties;
  final CropVarietyRpcInvoker _invokeRpc;
  final CropVarietyWriteAuthorityProvider? _requireLeaseForWrite;

  factory CropVarietyRepository({
    SupabaseClient? supabase,
    CropVarietyWriteAuthorityProvider? requireLeaseForWrite,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return CropVarietyRepository.withProviders(
      ({String? cropId, bool activeOnly = true}) async {
        dynamic query = client.from('crop_varieties').select();

        if (cropId != null) {
          query = query.eq('crop_id', cropId);
        }

        if (activeOnly) {
          query = query.eq('is_active', true);
        }

        query = query.order('crop_id').order('name');

        final response = await query;

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

  CropVarietyRepository.withProviders(
    this._loadVarieties,
    this._invokeRpc, [
    this._requireLeaseForWrite,
  ]);

  CropVarietyRepository.withLoader(CropVarietyListLoader loadVarieties)
    : _loadVarieties = loadVarieties,
      _invokeRpc = _unavailableRpcInvoker,
      _requireLeaseForWrite = null;

  Future<List<CropVariety>> getVarietiesByCrop(
    String cropId, {
    bool activeOnly = true,
  }) async {
    final response = await _loadVarieties(
      cropId: cropId,
      activeOnly: activeOnly,
    );

    return response.map(CropVariety.fromMap).toList();
  }

  Future<List<CropVariety>> getAllVarieties({bool activeOnly = true}) async {
    final response = await _loadVarieties(cropId: null, activeOnly: activeOnly);

    return response.map(CropVariety.fromMap).toList();
  }

  Future<CreateCropVarietyResult> createCropVariety({
    required String cropId,
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

    final response = await _invokeRpc('create_crop_variety', {
      'target_profile_id': lease.profileId,
      'target_crop_id': cropId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      ..._varietyParameters(
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
      'created' => CropVarietyCreated(
        cropVarietyId: _requiredNonEmptyString(payload, 'crop_variety_id'),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        name: _requiredNonEmptyString(payload, 'name'),
        scientificName: _optionalString(payload, 'scientific_name'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateCropVarietyForbidden(),
      'write_forbidden' => const CreateCropVarietyWriteForbidden(),
      'not_found' => const CreateCropVarietyNotFound(),
      'invalid_input' => const CreateCropVarietyInvalidInput(),
      'duplicate_name' => const CreateCropVarietyDuplicateName(),
      'blocked_by_inactive_crop' => CreateCropVarietyBlockedByInactiveCrop(
        crop: _inactiveCropReference(payload),
      ),
      _ => throw const CropVarietyWriteProtocolException(),
    };
  }

  Future<UpdateCropVarietyResult> updateCropVariety({
    required String cropVarietyId,
    required int expectedRowVersion,
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

    final response = await _invokeRpc('update_crop_variety', {
      'target_profile_id': lease.profileId,
      'target_crop_variety_id': cropVarietyId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      ..._varietyParameters(
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
      'updated' => CropVarietyUpdated(
        cropVarietyId: _requiredNonEmptyString(payload, 'crop_variety_id'),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        name: _requiredNonEmptyString(payload, 'name'),
        scientificName: _optionalString(payload, 'scientific_name'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateCropVarietyUnchanged(
        cropVarietyId: _requiredNonEmptyString(payload, 'crop_variety_id'),
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => UpdateCropVarietyVersionConflict(
        cropVarietyId: _requiredNonEmptyString(payload, 'crop_variety_id'),
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
      'forbidden' => const UpdateCropVarietyForbidden(),
      'write_forbidden' => const UpdateCropVarietyWriteForbidden(),
      'not_found' => const UpdateCropVarietyNotFound(),
      'invalid_input' => const UpdateCropVarietyInvalidInput(),
      'duplicate_name' => const UpdateCropVarietyDuplicateName(),
      _ => throw const CropVarietyWriteProtocolException(),
    };
  }

  Future<SetCropVarietyActiveResult> setCropVarietyActive({
    required String cropVarietyId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('set_crop_variety_active', {
      'target_profile_id': lease.profileId,
      'target_crop_variety_id': cropVarietyId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'variety_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => CropVarietyActiveUpdated(
        cropVarietyId: _requiredNonEmptyString(payload, 'crop_variety_id'),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetCropVarietyActiveUnchanged(
        cropVarietyId: _requiredNonEmptyString(payload, 'crop_variety_id'),
        cropId: _requiredNonEmptyString(payload, 'crop_id'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => SetCropVarietyActiveVersionConflict(
        cropVarietyId: _requiredNonEmptyString(payload, 'crop_variety_id'),
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
      'forbidden' => const SetCropVarietyActiveForbidden(),
      'write_forbidden' => const SetCropVarietyActiveWriteForbidden(),
      'not_found' => const SetCropVarietyActiveNotFound(),
      'invalid_input' => const SetCropVarietyActiveInvalidInput(),
      'blocked_by_inactive_crop' => SetCropVarietyActiveBlockedByInactiveCrop(
        cropVarietyId: _requiredNonEmptyString(payload, 'crop_variety_id'),
        crop: _inactiveCropReference(payload),
      ),
      _ => throw const CropVarietyWriteProtocolException(),
    };
  }

  ProfileEditLockLease _requireWriteLease() {
    final provider = _requireLeaseForWrite;

    if (provider == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    return provider();
  }

  Map<String, dynamic> _varietyParameters({
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
      'variety_name': name,
      'variety_scientific_name': scientificName,
      'variety_description': description,
      'variety_default_start_method': defaultStartMethod,
      'variety_row_spacing_cm': rowSpacingCm,
      'variety_plant_spacing_cm': plantSpacingCm,
      'variety_sowing_depth_cm': sowingDepthCm,
      'variety_germination_days': germinationDays,
      'variety_harvest_days': harvestDays,
      'variety_min_temperature': minTemperature,
      'variety_optimal_temperature': optimalTemperature,
      'variety_water_requirement': waterRequirement,
      'variety_water_requirement_value': waterRequirementValue,
      'variety_water_requirement_basis': waterRequirementBasis,
      'variety_water_interval_days': waterIntervalDays,
      'variety_productivity': productivity,
      'variety_expected_yield_min': expectedYieldMin,
      'variety_expected_yield_avg': expectedYieldAvg,
      'variety_expected_yield_max': expectedYieldMax,
      'variety_expected_yield_unit': expectedYieldUnit,
      'variety_yield_source_name': yieldSourceName,
      'variety_yield_source_url': yieldSourceUrl,
      'variety_yield_source_year': yieldSourceYear,
      'variety_yield_notes': yieldNotes,
    };
  }

  InactiveCropReference _inactiveCropReference(Map<String, dynamic> payload) {
    return InactiveCropReference(
      cropId: _requiredNonEmptyString(payload, 'crop_id'),
      cropName: _requiredNonEmptyString(payload, 'crop_name'),
    );
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const CropVarietyWriteProtocolException();
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const CropVarietyWriteProtocolException();
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const CropVarietyWriteProtocolException();
    }

    return value;
  }

  String? _optionalString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw const CropVarietyWriteProtocolException();
    }

    return value;
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const CropVarietyWriteProtocolException();
    }

    return value;
  }

  bool _requiredBoolean(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const CropVarietyWriteProtocolException();
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const CropVarietyWriteProtocolException();
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const CropVarietyWriteProtocolException();
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
