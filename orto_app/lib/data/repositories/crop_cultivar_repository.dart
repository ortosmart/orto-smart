import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/crop_cultivar_write_result.dart';
import '../models/crop_cultivar.dart';

typedef CropCultivarListLoader =
    Future<List<Map<String, dynamic>>> Function({
      String? cropId,
      bool activeOnly,
    });

typedef CropCultivarRpcInvoker =
    Future<dynamic> Function(String functionName, Map<String, dynamic> params);

class CropCultivarRepository {
  final CropCultivarListLoader _loadCultivars;
  final CropCultivarRpcInvoker _invokeRpc;

  factory CropCultivarRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return CropCultivarRepository.withProviders(
      loadCultivars: ({String? cropId, bool activeOnly = true}) async {
        dynamic query = client.from('crop_cultivar_catalog_read').select();
        if (cropId != null) query = query.eq('crop_id', cropId);
        if (activeOnly) query = query.eq('is_active', true);

        final response = await query.order('crop_id').order('canonical_name');
        return (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      },
      invokeRpc: (functionName, params) {
        return client.rpc(functionName, params: params);
      },
    );
  }

  CropCultivarRepository.withProviders({
    required CropCultivarListLoader loadCultivars,
    required CropCultivarRpcInvoker invokeRpc,
  }) : this._internal(loadCultivars, invokeRpc);

  CropCultivarRepository._internal(this._loadCultivars, this._invokeRpc);

  CropCultivarRepository.withLoader(CropCultivarListLoader loadCultivars)
    : this.withProviders(
        loadCultivars: loadCultivars,
        invokeRpc: (functionName, params) {
          throw UnsupportedError(
            'RPC invocation is not configured for this repository.',
          );
        },
      );

  Future<List<CropCultivar>> getCultivarsByCrop(
    String cropId, {
    bool activeOnly = true,
  }) async {
    final response = await _loadCultivars(
      cropId: cropId,
      activeOnly: activeOnly,
    );
    return response.map(CropCultivar.fromMap).toList();
  }

  Future<List<CropCultivar>> getAllCultivars({bool activeOnly = true}) async {
    final response = await _loadCultivars(cropId: null, activeOnly: activeOnly);
    return response.map(CropCultivar.fromMap).toList();
  }

  Future<CreateCropCultivarResult> createCultivar({
    required String cropId,
    required String canonicalName,
    required String verificationStatus,
    String? description,
  }) async {
    final response = _responseMap(
      await _invokeRpc('create_crop_cultivar', {
        'target_crop_id': cropId,
        'cultivar_canonical_name': canonicalName,
        'cultivar_verification_status': verificationStatus,
        'cultivar_description': description,
      }),
    );

    final status = _requiredNonEmptyString(response, 'status');

    switch (status) {
      case 'created':
        return CropCultivarCreated(
          cropCultivarId: _requiredNonEmptyString(response, 'crop_cultivar_id'),
          rowVersion: _requiredPositiveInteger(response, 'row_version'),
          createdAt: _requiredDateTime(response, 'created_at'),
          updatedAt: _requiredDateTime(response, 'updated_at'),
        );

      case 'forbidden':
        return const CreateCropCultivarForbidden();

      case 'invalid_input':
        return const CreateCropCultivarInvalidInput();

      case 'crop_not_found':
        return const CreateCropCultivarCropNotFound();

      case 'dependency_inactive':
        return const CreateCropCultivarDependencyInactive();

      case 'duplicate_canonical_name':
        return const CreateCropCultivarDuplicateCanonicalName();

      default:
        throw CropCultivarWriteProtocolException(
          'Unknown create_crop_cultivar status: $status',
        );
    }
  }

  Future<UpdateCropCultivarResult> updateCultivar({
    required String cropCultivarId,
    required int expectedRowVersion,
    required String cropId,
    required String canonicalName,
    required String verificationStatus,
    String? description,
  }) async {
    final response = _responseMap(
      await _invokeRpc('update_crop_cultivar', {
        'target_crop_cultivar_id': cropCultivarId,
        'expected_row_version': expectedRowVersion,
        'target_crop_id': cropId,
        'cultivar_canonical_name': canonicalName,
        'cultivar_verification_status': verificationStatus,
        'cultivar_description': description,
      }),
    );

    final status = _requiredNonEmptyString(response, 'status');

    switch (status) {
      case 'updated':
        return CropCultivarUpdated(
          cropCultivarId: _requiredNonEmptyString(response, 'crop_cultivar_id'),
          rowVersion: _requiredPositiveInteger(response, 'row_version'),
          updatedAt: _requiredDateTime(response, 'updated_at'),
        );

      case 'unchanged':
        return UpdateCropCultivarUnchanged(
          cropCultivarId: _requiredNonEmptyString(response, 'crop_cultivar_id'),
          rowVersion: _requiredPositiveInteger(response, 'row_version'),
          updatedAt: _requiredDateTime(response, 'updated_at'),
        );

      case 'version_conflict':
        return _updateVersionConflict(response);

      case 'forbidden':
        return const UpdateCropCultivarForbidden();

      case 'invalid_input':
        return const UpdateCropCultivarInvalidInput();

      case 'not_found':
        return const UpdateCropCultivarNotFound();

      case 'crop_not_found':
        return const UpdateCropCultivarCropNotFound();

      case 'dependency_inactive':
        return const UpdateCropCultivarDependencyInactive();

      case 'duplicate_canonical_name':
        return const UpdateCropCultivarDuplicateCanonicalName();

      case 'identity_in_use':
        return const UpdateCropCultivarIdentityInUse();

      default:
        throw CropCultivarWriteProtocolException(
          'Unknown update_crop_cultivar status: $status',
        );
    }
  }

  Future<SetCropCultivarActiveResult> setCultivarActive({
    required String cropCultivarId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = _responseMap(
      await _invokeRpc('set_crop_cultivar_active', {
        'target_crop_cultivar_id': cropCultivarId,
        'expected_row_version': expectedRowVersion,
        'cultivar_is_active': isActive,
      }),
    );

    final status = _requiredNonEmptyString(response, 'status');

    switch (status) {
      case 'active_changed':
        return CropCultivarActiveChanged(
          cropCultivarId: _requiredNonEmptyString(response, 'crop_cultivar_id'),
          isActive: _requiredBoolean(response, 'is_active'),
          rowVersion: _requiredPositiveInteger(response, 'row_version'),
          updatedAt: _requiredDateTime(response, 'updated_at'),
        );

      case 'unchanged':
        return SetCropCultivarActiveUnchanged(
          cropCultivarId: _requiredNonEmptyString(response, 'crop_cultivar_id'),
          isActive: _requiredBoolean(response, 'is_active'),
          rowVersion: _requiredPositiveInteger(response, 'row_version'),
          updatedAt: _requiredDateTime(response, 'updated_at'),
        );

      case 'version_conflict':
        return _setActiveVersionConflict(response);

      case 'forbidden':
        return const SetCropCultivarActiveForbidden();

      case 'invalid_input':
        return const SetCropCultivarActiveInvalidInput();

      case 'not_found':
        return const SetCropCultivarActiveNotFound();

      case 'dependency_inactive':
        return const SetCropCultivarActiveDependencyInactive();

      default:
        throw CropCultivarWriteProtocolException(
          'Unknown set_crop_cultivar_active status: $status',
        );
    }
  }

  static SetCropCultivarActiveVersionConflict _setActiveVersionConflict(
    Map<String, dynamic> response,
  ) {
    const detailKeys = {
      'crop_cultivar_id',
      'expected_row_version',
      'current_row_version',
      'updated_at',
    };

    final presentDetails = detailKeys.where(response.containsKey).length;

    if (presentDetails == 0) {
      return const SetCropCultivarActiveVersionConflict();
    }

    if (presentDetails != detailKeys.length) {
      throw const CropCultivarWriteProtocolException(
        'set_crop_cultivar_active version_conflict has partial details.',
      );
    }

    return SetCropCultivarActiveVersionConflict(
      cropCultivarId: _requiredNonEmptyString(response, 'crop_cultivar_id'),
      expectedRowVersion: _requiredPositiveInteger(
        response,
        'expected_row_version',
      ),
      currentRowVersion: _requiredPositiveInteger(
        response,
        'current_row_version',
      ),
      updatedAt: _requiredDateTime(response, 'updated_at'),
    );
  }

  static bool _requiredBoolean(Map<String, dynamic> response, String key) {
    final value = response[key];

    if (value is! bool) {
      throw CropCultivarWriteProtocolException(
        'RPC response field "$key" must be a boolean.',
      );
    }

    return value;
  }

  static UpdateCropCultivarVersionConflict _updateVersionConflict(
    Map<String, dynamic> response,
  ) {
    const detailKeys = {
      'crop_cultivar_id',
      'expected_row_version',
      'current_row_version',
      'updated_at',
    };

    final presentDetails = detailKeys.where(response.containsKey).length;

    if (presentDetails == 0) {
      return const UpdateCropCultivarVersionConflict();
    }

    if (presentDetails != detailKeys.length) {
      throw const CropCultivarWriteProtocolException(
        'update_crop_cultivar version_conflict has partial details.',
      );
    }

    return UpdateCropCultivarVersionConflict(
      cropCultivarId: _requiredNonEmptyString(response, 'crop_cultivar_id'),
      expectedRowVersion: _requiredPositiveInteger(
        response,
        'expected_row_version',
      ),
      currentRowVersion: _requiredPositiveInteger(
        response,
        'current_row_version',
      ),
      updatedAt: _requiredDateTime(response, 'updated_at'),
    );
  }

  static Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const CropCultivarWriteProtocolException(
        'RPC response is not a JSON object.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  static String _requiredNonEmptyString(
    Map<String, dynamic> response,
    String key,
  ) {
    final value = response[key];

    if (value is! String || value.trim().isEmpty) {
      throw CropCultivarWriteProtocolException(
        'RPC response field "$key" must be a non-empty string.',
      );
    }

    return value;
  }

  static int _requiredPositiveInteger(
    Map<String, dynamic> response,
    String key,
  ) {
    final value = response[key];

    if (value is! int || value < 1) {
      throw CropCultivarWriteProtocolException(
        'RPC response field "$key" must be a positive integer.',
      );
    }

    return value;
  }

  static DateTime _requiredDateTime(Map<String, dynamic> response, String key) {
    final value = response[key];

    if (value is! String) {
      throw CropCultivarWriteProtocolException(
        'RPC response field "$key" must be a date-time string.',
      );
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw CropCultivarWriteProtocolException(
        'RPC response field "$key" is not a valid date-time.',
      );
    }

    return parsed;
  }
}
