import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/protection_context_write_result.dart';
import '../models/protection_context.dart';

typedef ProtectionContextListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef ProtectionContextRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class ProtectionContextRepository {
  final ProtectionContextListLoader _loadContexts;
  final ProtectionContextRpcInvoker _invokeRpc;

  factory ProtectionContextRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return ProtectionContextRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('protection_contexts').select();

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

  ProtectionContextRepository.withProviders(
    this._loadContexts,
    this._invokeRpc,
  );

  ProtectionContextRepository.withLoader(
    ProtectionContextListLoader loadContexts,
  ) : this.withProviders(loadContexts, (functionName, parameters) {
        throw UnsupportedError(
          'RPC invocation is not configured for this '
          'ProtectionContextRepository',
        );
      });

  Future<List<ProtectionContext>> getProtectionContexts({
    bool activeOnly = true,
  }) async {
    final response = await _loadContexts(activeOnly: activeOnly);

    return response.map(ProtectionContext.fromMap).toList();
  }

  Future<CreateProtectionContextResult> createProtectionContext({
    required String code,
    required String name,
    String? description,
  }) async {
    final response = await _invokeRpc('create_protection_context', {
      'context_code': code,
      'context_name': name,
      'context_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => ProtectionContextCreated(
        protectionContextId: _requiredString(payload, 'protection_context_id'),
        code: _requiredString(payload, 'code'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateProtectionContextForbidden(),
      'invalid_input' => const CreateProtectionContextInvalidInput(),
      'duplicate_code' => const CreateProtectionContextDuplicateCode(),
      _ => throw const ProtectionContextWriteProtocolException(
        'Invalid create_protection_context response',
      ),
    };
  }

  Future<UpdateProtectionContextResult> updateProtectionContext({
    required String protectionContextId,
    required int expectedRowVersion,
    required String name,
    String? description,
  }) async {
    final response = await _invokeRpc('update_protection_context', {
      'target_protection_context_id': protectionContextId,
      'expected_row_version': expectedRowVersion,
      'context_name': name,
      'context_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => ProtectionContextUpdated(
        protectionContextId: _requiredString(payload, 'protection_context_id'),
        code: _requiredString(payload, 'code'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateProtectionContextUnchanged(
        protectionContextId: _requiredString(payload, 'protection_context_id'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'version_conflict' => UpdateProtectionContextVersionConflict(
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'forbidden' => const UpdateProtectionContextForbidden(),
      'invalid_input' => const UpdateProtectionContextInvalidInput(),
      'not_found' => const UpdateProtectionContextNotFound(),
      _ => throw const ProtectionContextWriteProtocolException(
        'Invalid update_protection_context response',
      ),
    };
  }

  Future<SetProtectionContextActiveResult> setProtectionContextActive({
    required String protectionContextId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = await _invokeRpc('set_protection_context_active', {
      'target_protection_context_id': protectionContextId,
      'expected_row_version': expectedRowVersion,
      'context_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'active_changed' => ProtectionContextActiveChanged(
        protectionContextId: _requiredString(payload, 'protection_context_id'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetProtectionContextActiveUnchanged(
        protectionContextId: _requiredString(payload, 'protection_context_id'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'version_conflict' => SetProtectionContextActiveVersionConflict(
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'forbidden' => const SetProtectionContextActiveForbidden(),
      'invalid_input' => const SetProtectionContextActiveInvalidInput(),
      'not_found' => const SetProtectionContextActiveNotFound(),
      'active_dependents' => const SetProtectionContextActiveDependents(),
      _ => throw const ProtectionContextWriteProtocolException(
        'Invalid set_protection_context_active response',
      ),
    };
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const ProtectionContextWriteProtocolException(
        'Protection Context RPC response is not a map',
      );
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const ProtectionContextWriteProtocolException(
        'Protection Context RPC response contains invalid keys',
      );
    }
  }

  String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const ProtectionContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  int _requiredPositiveInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const ProtectionContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  bool _requiredBool(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const ProtectionContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const ProtectionContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const ProtectionContextWriteProtocolException(
        'Invalid Protection Context RPC payload',
      );
    }

    return parsed.toUtc();
  }
}
