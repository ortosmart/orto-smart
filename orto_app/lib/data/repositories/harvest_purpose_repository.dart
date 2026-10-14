import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/harvest_purpose_write_result.dart';
import '../models/harvest_purpose.dart';

typedef HarvestPurposeListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef HarvestPurposeRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class HarvestPurposeRepository {
  final HarvestPurposeListLoader _loadContexts;
  final HarvestPurposeRpcInvoker _invokeRpc;

  factory HarvestPurposeRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return HarvestPurposeRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('harvest_purposes').select();

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

  HarvestPurposeRepository.withProviders(this._loadContexts, this._invokeRpc);

  HarvestPurposeRepository.withLoader(HarvestPurposeListLoader loadContexts)
    : this.withProviders(loadContexts, (functionName, parameters) {
        throw UnsupportedError(
          'RPC invocation is not configured for this '
          'HarvestPurposeRepository',
        );
      });

  Future<List<HarvestPurpose>> getHarvestPurposes({
    bool activeOnly = true,
  }) async {
    final response = await _loadContexts(activeOnly: activeOnly);

    return response.map(HarvestPurpose.fromMap).toList();
  }

  Future<CreateHarvestPurposeResult> createHarvestPurpose({
    required String code,
    required String name,
    String? description,
  }) async {
    final response = await _invokeRpc('create_harvest_purpose', {
      'context_code': code,
      'context_name': name,
      'context_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => HarvestPurposeCreated(
        harvestPurposeId: _requiredString(payload, 'harvest_purpose_id'),
        code: _requiredString(payload, 'code'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateHarvestPurposeForbidden(),
      'invalid_input' => const CreateHarvestPurposeInvalidInput(),
      'duplicate_code' => const CreateHarvestPurposeDuplicateCode(),
      _ => throw const HarvestPurposeWriteProtocolException(
        'Invalid create_harvest_purpose response',
      ),
    };
  }

  Future<UpdateHarvestPurposeResult> updateHarvestPurpose({
    required String harvestPurposeId,
    required int expectedRowVersion,
    required String name,
    String? description,
  }) async {
    final response = await _invokeRpc('update_harvest_purpose', {
      'target_harvest_purpose_id': harvestPurposeId,
      'expected_row_version': expectedRowVersion,
      'context_name': name,
      'context_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => HarvestPurposeUpdated(
        harvestPurposeId: _requiredString(payload, 'harvest_purpose_id'),
        code: _requiredString(payload, 'code'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateHarvestPurposeUnchanged(
        harvestPurposeId: _requiredString(payload, 'harvest_purpose_id'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'version_conflict' => UpdateHarvestPurposeVersionConflict(
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'forbidden' => const UpdateHarvestPurposeForbidden(),
      'invalid_input' => const UpdateHarvestPurposeInvalidInput(),
      'not_found' => const UpdateHarvestPurposeNotFound(),
      _ => throw const HarvestPurposeWriteProtocolException(
        'Invalid update_harvest_purpose response',
      ),
    };
  }

  Future<SetHarvestPurposeActiveResult> setHarvestPurposeActive({
    required String harvestPurposeId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = await _invokeRpc('set_harvest_purpose_active', {
      'target_harvest_purpose_id': harvestPurposeId,
      'expected_row_version': expectedRowVersion,
      'context_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'active_changed' => HarvestPurposeActiveChanged(
        harvestPurposeId: _requiredString(payload, 'harvest_purpose_id'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetHarvestPurposeActiveUnchanged(
        harvestPurposeId: _requiredString(payload, 'harvest_purpose_id'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'version_conflict' => SetHarvestPurposeActiveVersionConflict(
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'forbidden' => const SetHarvestPurposeActiveForbidden(),
      'invalid_input' => const SetHarvestPurposeActiveInvalidInput(),
      'not_found' => const SetHarvestPurposeActiveNotFound(),
      'active_dependents' => const SetHarvestPurposeActiveDependents(),
      _ => throw const HarvestPurposeWriteProtocolException(
        'Invalid set_harvest_purpose_active response',
      ),
    };
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const HarvestPurposeWriteProtocolException(
        'Protection Context RPC response is not a map',
      );
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const HarvestPurposeWriteProtocolException(
        'Protection Context RPC response contains invalid keys',
      );
    }
  }

  String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const HarvestPurposeWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  int _requiredPositiveInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const HarvestPurposeWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  bool _requiredBool(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const HarvestPurposeWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const HarvestPurposeWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const HarvestPurposeWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return parsed.toUtc();
  }
}
