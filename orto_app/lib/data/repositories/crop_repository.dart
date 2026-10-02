import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/catalog_crop_write_result.dart';
import '../models/crop.dart';

typedef CropListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef CropRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class CropRepository {
  final CropListLoader _loadCrops;
  final CropRpcInvoker _invokeRpc;

  factory CropRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return CropRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('crop_catalog_read').select();
        if (activeOnly) query = query.eq('is_active', true);

        final response = await query.order('canonical_name');
        return (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
    );
  }

  CropRepository.withProviders(this._loadCrops, this._invokeRpc);

  CropRepository.withLoader(CropListLoader loadCrops)
    : this.withProviders(loadCrops, (functionName, parameters) {
        throw UnsupportedError(
          'RPC invocation is not configured for this CropRepository',
        );
      });

  Future<List<Crop>> getCrops({bool activeOnly = true}) async {
    final response = await _loadCrops(activeOnly: activeOnly);
    return response.map(Crop.fromMap).toList();
  }

  Future<CreateCatalogCropResult> createCrop({
    required String taxonId,
    required String canonicalName,
    String? description,
  }) async {
    final response = await _invokeRpc('create_catalog_crop', {
      'target_taxon_id': taxonId,
      'crop_canonical_name': canonicalName,
      'crop_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => CatalogCropCreated(
        catalogCropId: _requiredNonEmptyString(payload, 'catalog_crop_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'forbidden' => const CreateCatalogCropForbidden(),
      'invalid_input' => const CreateCatalogCropInvalidInput(),
      'taxon_not_found' => const CreateCatalogCropTaxonNotFound(),
      'dependency_inactive' => const CreateCatalogCropDependencyInactive(),
      'duplicate_canonical_name' =>
        const CreateCatalogCropDuplicateCanonicalName(),
      _ => throw const CatalogCropWriteProtocolException(
        'Invalid create_catalog_crop response',
      ),
    };
  }

  Future<UpdateCatalogCropResult> updateCrop({
    required String catalogCropId,
    required int expectedRowVersion,
    required String taxonId,
    required String canonicalName,
    String? description,
  }) async {
    final response = await _invokeRpc('update_catalog_crop', {
      'target_catalog_crop_id': catalogCropId,
      'expected_row_version': expectedRowVersion,
      'target_taxon_id': taxonId,
      'crop_canonical_name': canonicalName,
      'crop_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => CatalogCropUpdated(
        catalogCropId: _requiredNonEmptyString(payload, 'catalog_crop_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateCatalogCropUnchanged(
        catalogCropId: _requiredNonEmptyString(payload, 'catalog_crop_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => _updateVersionConflict(payload),
      'forbidden' => const UpdateCatalogCropForbidden(),
      'invalid_input' => const UpdateCatalogCropInvalidInput(),
      'not_found' => const UpdateCatalogCropNotFound(),
      'taxon_not_found' => const UpdateCatalogCropTaxonNotFound(),
      'dependency_inactive' => const UpdateCatalogCropDependencyInactive(),
      'duplicate_canonical_name' =>
        const UpdateCatalogCropDuplicateCanonicalName(),
      _ => throw const CatalogCropWriteProtocolException(
        'Invalid update_catalog_crop response',
      ),
    };
  }

  UpdateCatalogCropVersionConflict _updateVersionConflict(
    Map<String, dynamic> payload,
  ) {
    const detailKeys = [
      'catalog_crop_id',
      'expected_row_version',
      'current_row_version',
      'updated_at',
    ];

    final hasAnyDetail = detailKeys.any(payload.containsKey);

    if (!hasAnyDetail) {
      return const UpdateCatalogCropVersionConflict();
    }

    if (!detailKeys.every(payload.containsKey)) {
      throw const CatalogCropWriteProtocolException(
        'Invalid update_catalog_crop version conflict payload',
      );
    }

    return UpdateCatalogCropVersionConflict(
      catalogCropId: _requiredNonEmptyString(payload, 'catalog_crop_id'),
      expectedRowVersion: _requiredPositiveInteger(
        payload,
        'expected_row_version',
      ),
      currentRowVersion: _requiredPositiveInteger(
        payload,
        'current_row_version',
      ),
      updatedAt: _requiredDateTime(payload, 'updated_at'),
    );
  }

  Future<SetCatalogCropActiveResult> setCropActive({
    required String catalogCropId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = await _invokeRpc('set_catalog_crop_active', {
      'target_catalog_crop_id': catalogCropId,
      'expected_row_version': expectedRowVersion,
      'crop_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'active_changed' => CatalogCropActiveChanged(
        catalogCropId: _requiredNonEmptyString(payload, 'catalog_crop_id'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetCatalogCropActiveUnchanged(
        catalogCropId: _requiredNonEmptyString(payload, 'catalog_crop_id'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => _setActiveVersionConflict(payload),
      'forbidden' => const SetCatalogCropActiveForbidden(),
      'invalid_input' => const SetCatalogCropActiveInvalidInput(),
      'not_found' => const SetCatalogCropActiveNotFound(),
      'dependency_inactive' => const SetCatalogCropActiveDependencyInactive(),
      'active_dependents' => SetCatalogCropActiveDependents(
        dependentType: _requiredNonEmptyString(payload, 'dependent_type'),
        dependentCount: _requiredNonNegativeInteger(payload, 'dependent_count'),
      ),
      _ => throw const CatalogCropWriteProtocolException(
        'Invalid set_catalog_crop_active response',
      ),
    };
  }

  SetCatalogCropActiveVersionConflict _setActiveVersionConflict(
    Map<String, dynamic> payload,
  ) {
    const detailKeys = [
      'catalog_crop_id',
      'expected_row_version',
      'current_row_version',
      'updated_at',
    ];

    final hasAnyDetail = detailKeys.any(payload.containsKey);

    if (!hasAnyDetail) {
      return const SetCatalogCropActiveVersionConflict();
    }

    if (!detailKeys.every(payload.containsKey)) {
      throw const CatalogCropWriteProtocolException(
        'Invalid set_catalog_crop_active version conflict payload',
      );
    }

    return SetCatalogCropActiveVersionConflict(
      catalogCropId: _requiredNonEmptyString(payload, 'catalog_crop_id'),
      expectedRowVersion: _requiredPositiveInteger(
        payload,
        'expected_row_version',
      ),
      currentRowVersion: _requiredPositiveInteger(
        payload,
        'current_row_version',
      ),
      updatedAt: _requiredDateTime(payload, 'updated_at'),
    );
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const CatalogCropWriteProtocolException(
        'Catalog Crop RPC response is not a map',
      );
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const CatalogCropWriteProtocolException(
        'Catalog Crop RPC response contains invalid keys',
      );
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const CatalogCropWriteProtocolException(
        'Invalid Catalog Crop RPC payload',
      );
    }

    return value;
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const CatalogCropWriteProtocolException(
        'Invalid Catalog Crop RPC payload',
      );
    }

    return value;
  }

  int _requiredNonNegativeInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 0) {
      throw const CatalogCropWriteProtocolException(
        'Invalid Catalog Crop RPC payload',
      );
    }

    return value;
  }

  bool _requiredBoolean(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const CatalogCropWriteProtocolException(
        'Invalid Catalog Crop RPC payload',
      );
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const CatalogCropWriteProtocolException(
        'Invalid Catalog Crop RPC payload',
      );
    }

    final parsedValue = DateTime.tryParse(value);

    if (parsedValue == null) {
      throw const CatalogCropWriteProtocolException(
        'Invalid Catalog Crop RPC payload',
      );
    }

    return parsedValue.toUtc();
  }
}
