
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/agronomic_parameter_write_result.dart';
import '../models/agronomic_parameter.dart';

typedef AgronomicParameterListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef AgronomicParameterRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class AgronomicParameterRepository {
  final AgronomicParameterListLoader _loadParameters;
  final AgronomicParameterRpcInvoker _invokeRpc;

  factory AgronomicParameterRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return AgronomicParameterRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('agronomic_parameters').select();

        if (activeOnly) {
          query = query.eq('is_active', true);
        }

        final response = await query.order('name');

        return (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
    );
  }

  AgronomicParameterRepository.withProviders(
    this._loadParameters,
    this._invokeRpc,
  );

  AgronomicParameterRepository.withLoader(
    AgronomicParameterListLoader loadParameters,
  ) : this.withProviders(loadParameters, (functionName, parameters) {
          throw UnsupportedError(
            'RPC invocation is not configured for this '
            'AgronomicParameterRepository',
          );
        });

  Future<List<AgronomicParameter>> getAgronomicParameters({
    bool activeOnly = true,
  }) async {
    final response = await _loadParameters(activeOnly: activeOnly);
    return response.map(AgronomicParameter.fromMap).toList();
  }

  Future<CreateAgronomicParameterResult> createAgronomicParameter({
    required String code,
    required String name,
    String? description,
    required String valueSchema,
    required String knowledgeScope,
    String? quantityKind,
    String? canonicalUnitId,
    required bool allowsCrop,
    required bool allowsCultivar,
    required bool allowsProductionContext,
    required bool allowsProtectionContext,
    required bool allowsTrainingContext,
    required bool allowsHarvestPurpose,
  }) async {
    final response = await _invokeRpc('create_agronomic_parameter', {
      'parameter_code': code,
      'parameter_name': name,
      'parameter_description': description,
      'parameter_value_schema': valueSchema,
      'parameter_knowledge_scope': knowledgeScope,
      'parameter_quantity_kind': quantityKind,
      'parameter_canonical_unit_id': canonicalUnitId,
      'parameter_allows_crop': allowsCrop,
      'parameter_allows_cultivar': allowsCultivar,
      'parameter_allows_production_context': allowsProductionContext,
      'parameter_allows_protection_context': allowsProtectionContext,
      'parameter_allows_training_context': allowsTrainingContext,
      'parameter_allows_harvest_purpose': allowsHarvestPurpose,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => AgronomicParameterCreated(
          agronomicParameterId: _requiredString(
            payload,
            'agronomic_parameter_id',
          ),
          code: _requiredString(payload, 'code'),
          isActive: _requiredBool(payload, 'is_active'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
          createdAt: _requiredDateTime(payload, 'created_at'),
        ),
      'forbidden' => const CreateAgronomicParameterForbidden(),
      'invalid_input' => const CreateAgronomicParameterInvalidInput(),
      'duplicate_code' => const CreateAgronomicParameterDuplicateCode(),
      'unit_not_found' => const CreateAgronomicParameterUnitNotFound(),
      'dependency_inactive' =>
        const CreateAgronomicParameterDependencyInactive(),
      _ => throw const AgronomicParameterWriteProtocolException(
          'Invalid create_agronomic_parameter response',
        ),
    };
  }

  Future<UpdateAgronomicParameterResult> updateAgronomicParameter({
    required String agronomicParameterId,
    required int expectedRowVersion,
    required String code,
    required String name,
    String? description,
    required String valueSchema,
    required String knowledgeScope,
    String? quantityKind,
    String? canonicalUnitId,
    required bool allowsCrop,
    required bool allowsCultivar,
    required bool allowsProductionContext,
    required bool allowsProtectionContext,
    required bool allowsTrainingContext,
    required bool allowsHarvestPurpose,
  }) async {
    final response = await _invokeRpc('update_agronomic_parameter', {
      'target_agronomic_parameter_id': agronomicParameterId,
      'expected_row_version': expectedRowVersion,
      'parameter_code': code,
      'parameter_name': name,
      'parameter_description': description,
      'parameter_value_schema': valueSchema,
      'parameter_knowledge_scope': knowledgeScope,
      'parameter_quantity_kind': quantityKind,
      'parameter_canonical_unit_id': canonicalUnitId,
      'parameter_allows_crop': allowsCrop,
      'parameter_allows_cultivar': allowsCultivar,
      'parameter_allows_production_context': allowsProductionContext,
      'parameter_allows_protection_context': allowsProtectionContext,
      'parameter_allows_training_context': allowsTrainingContext,
      'parameter_allows_harvest_purpose': allowsHarvestPurpose,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => AgronomicParameterUpdated(
          agronomicParameterId: _requiredString(
            payload,
            'agronomic_parameter_id',
          ),
          code: _requiredString(payload, 'code'),
          isActive: _requiredBool(payload, 'is_active'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
          updatedAt: _requiredDateTime(payload, 'updated_at'),
        ),
      'unchanged' => UpdateAgronomicParameterUnchanged(
          agronomicParameterId: _requiredString(
            payload,
            'agronomic_parameter_id',
          ),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
        ),
      'version_conflict' => UpdateAgronomicParameterVersionConflict(
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
        ),
      'forbidden' => const UpdateAgronomicParameterForbidden(),
      'invalid_input' => const UpdateAgronomicParameterInvalidInput(),
      'not_found' => const UpdateAgronomicParameterNotFound(),
      'semantics_frozen' =>
        const UpdateAgronomicParameterSemanticsFrozen(),
      'enum_values_exist' =>
        const UpdateAgronomicParameterEnumValuesExist(),
      'unit_not_found' => const UpdateAgronomicParameterUnitNotFound(),
      'dependency_inactive' =>
        const UpdateAgronomicParameterDependencyInactive(),
      'duplicate_code' => const UpdateAgronomicParameterDuplicateCode(),
      _ => throw const AgronomicParameterWriteProtocolException(
          'Invalid update_agronomic_parameter response',
        ),
    };
  }

  Future<SetAgronomicParameterActiveResult>
      setAgronomicParameterActive({
    required String agronomicParameterId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = await _invokeRpc('set_agronomic_parameter_active', {
      'target_agronomic_parameter_id': agronomicParameterId,
      'expected_row_version': expectedRowVersion,
      'parameter_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'active_changed' => AgronomicParameterActiveChanged(
          agronomicParameterId: _requiredString(
            payload,
            'agronomic_parameter_id',
          ),
          isActive: _requiredBool(payload, 'is_active'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
          updatedAt: _requiredDateTime(payload, 'updated_at'),
        ),
      'unchanged' => SetAgronomicParameterActiveUnchanged(
          agronomicParameterId: _requiredString(
            payload,
            'agronomic_parameter_id',
          ),
          isActive: _requiredBool(payload, 'is_active'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
        ),
      'version_conflict' => SetAgronomicParameterActiveVersionConflict(
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
        ),
      'forbidden' => const SetAgronomicParameterActiveForbidden(),
      'invalid_input' => const SetAgronomicParameterActiveInvalidInput(),
      'not_found' => const SetAgronomicParameterActiveNotFound(),
      'active_dependents' =>
        const SetAgronomicParameterActiveDependents(),
      'dependency_inactive' =>
        const SetAgronomicParameterActiveDependencyInactive(),
      _ => throw const AgronomicParameterWriteProtocolException(
          'Invalid set_agronomic_parameter_active response',
        ),
    };
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const AgronomicParameterWriteProtocolException(
        'Agronomic Parameter RPC response is not a map',
      );
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const AgronomicParameterWriteProtocolException(
        'Agronomic Parameter RPC response contains invalid keys',
      );
    }
  }

  String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const AgronomicParameterWriteProtocolException(
        'Invalid Agronomic Parameter RPC payload',
      );
    }

    return value;
  }

  int _requiredPositiveInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const AgronomicParameterWriteProtocolException(
        'Invalid Agronomic Parameter RPC payload',
      );
    }

    return value;
  }

  bool _requiredBool(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const AgronomicParameterWriteProtocolException(
        'Invalid Agronomic Parameter RPC payload',
      );
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String ||
        !RegExp(r'(?:[Zz]|[+-]\d{2}:\d{2})$').hasMatch(value)) {
      throw const AgronomicParameterWriteProtocolException(
        'Invalid Agronomic Parameter RPC timestamp',
      );
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const AgronomicParameterWriteProtocolException(
        'Invalid Agronomic Parameter RPC timestamp',
      );
    }

    return parsed.toUtc();
  }
}
