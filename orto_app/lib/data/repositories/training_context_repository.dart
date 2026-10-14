import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/training_context_write_result.dart';
import '../models/training_context.dart';

typedef TrainingContextListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef TrainingContextRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class TrainingContextRepository {
  final TrainingContextListLoader _loadContexts;
  final TrainingContextRpcInvoker _invokeRpc;

  factory TrainingContextRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return TrainingContextRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('training_contexts').select();

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

  TrainingContextRepository.withProviders(this._loadContexts, this._invokeRpc);

  TrainingContextRepository.withLoader(TrainingContextListLoader loadContexts)
    : this.withProviders(loadContexts, (functionName, parameters) {
        throw UnsupportedError(
          'RPC invocation is not configured for this '
          'TrainingContextRepository',
        );
      });

  Future<List<TrainingContext>> getTrainingContexts({
    bool activeOnly = true,
  }) async {
    final response = await _loadContexts(activeOnly: activeOnly);

    return response.map(TrainingContext.fromMap).toList();
  }

  Future<CreateTrainingContextResult> createTrainingContext({
    required String code,
    required String name,
    String? description,
  }) async {
    final response = await _invokeRpc('create_training_context', {
      'context_code': code,
      'context_name': name,
      'context_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => TrainingContextCreated(
        trainingContextId: _requiredString(payload, 'training_context_id'),
        code: _requiredString(payload, 'code'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateTrainingContextForbidden(),
      'invalid_input' => const CreateTrainingContextInvalidInput(),
      'duplicate_code' => const CreateTrainingContextDuplicateCode(),
      _ => throw const TrainingContextWriteProtocolException(
        'Invalid create_training_context response',
      ),
    };
  }

  Future<UpdateTrainingContextResult> updateTrainingContext({
    required String trainingContextId,
    required int expectedRowVersion,
    required String name,
    String? description,
  }) async {
    final response = await _invokeRpc('update_training_context', {
      'target_training_context_id': trainingContextId,
      'expected_row_version': expectedRowVersion,
      'context_name': name,
      'context_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => TrainingContextUpdated(
        trainingContextId: _requiredString(payload, 'training_context_id'),
        code: _requiredString(payload, 'code'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateTrainingContextUnchanged(
        trainingContextId: _requiredString(payload, 'training_context_id'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'version_conflict' => UpdateTrainingContextVersionConflict(
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'forbidden' => const UpdateTrainingContextForbidden(),
      'invalid_input' => const UpdateTrainingContextInvalidInput(),
      'not_found' => const UpdateTrainingContextNotFound(),
      _ => throw const TrainingContextWriteProtocolException(
        'Invalid update_training_context response',
      ),
    };
  }

  Future<SetTrainingContextActiveResult> setTrainingContextActive({
    required String trainingContextId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = await _invokeRpc('set_training_context_active', {
      'target_training_context_id': trainingContextId,
      'expected_row_version': expectedRowVersion,
      'context_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'active_changed' => TrainingContextActiveChanged(
        trainingContextId: _requiredString(payload, 'training_context_id'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetTrainingContextActiveUnchanged(
        trainingContextId: _requiredString(payload, 'training_context_id'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'version_conflict' => SetTrainingContextActiveVersionConflict(
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'forbidden' => const SetTrainingContextActiveForbidden(),
      'invalid_input' => const SetTrainingContextActiveInvalidInput(),
      'not_found' => const SetTrainingContextActiveNotFound(),
      'active_dependents' => const SetTrainingContextActiveDependents(),
      _ => throw const TrainingContextWriteProtocolException(
        'Invalid set_training_context_active response',
      ),
    };
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const TrainingContextWriteProtocolException(
        'Protection Context RPC response is not a map',
      );
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const TrainingContextWriteProtocolException(
        'Protection Context RPC response contains invalid keys',
      );
    }
  }

  String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const TrainingContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  int _requiredPositiveInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const TrainingContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  bool _requiredBool(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const TrainingContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const TrainingContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const TrainingContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return parsed.toUtc();
  }
}
