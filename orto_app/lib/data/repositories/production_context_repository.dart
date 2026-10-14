import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/production_context_write_result.dart';
import '../models/production_context.dart';

typedef ProductionContextListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef ProductionContextRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class ProductionContextRepository {
  final ProductionContextListLoader _loadContexts;
  final ProductionContextRpcInvoker _invokeRpc;

  factory ProductionContextRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return ProductionContextRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('production_contexts').select();

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

  ProductionContextRepository.withProviders(
    this._loadContexts,
    this._invokeRpc,
  );

  ProductionContextRepository.withLoader(
    ProductionContextListLoader loadContexts,
  ) : this.withProviders(loadContexts, (functionName, parameters) {
        throw UnsupportedError(
          'RPC invocation is not configured for this '
          'ProductionContextRepository',
        );
      });

  Future<List<ProductionContext>> getProductionContexts({
    bool activeOnly = true,
  }) async {
    final response = await _loadContexts(activeOnly: activeOnly);

    return response.map(ProductionContext.fromMap).toList();
  }

  Future<CreateProductionContextResult> createProductionContext({
    required String code,
    required String name,
    String? description,
  }) async {
    final response = await _invokeRpc('create_production_context', {
      'context_code': code,
      'context_name': name,
      'context_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => ProductionContextCreated(
        productionContextId: _requiredString(payload, 'production_context_id'),
        code: _requiredString(payload, 'code'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateProductionContextForbidden(),
      'invalid_input' => const CreateProductionContextInvalidInput(),
      'duplicate_code' => const CreateProductionContextDuplicateCode(),
      _ => throw const ProductionContextWriteProtocolException(
        'Invalid create_production_context response',
      ),
    };
  }

  Future<UpdateProductionContextResult> updateProductionContext({
    required String productionContextId,
    required int expectedRowVersion,
    required String name,
    String? description,
  }) async {
    final response = await _invokeRpc('update_production_context', {
      'target_production_context_id': productionContextId,
      'expected_row_version': expectedRowVersion,
      'context_name': name,
      'context_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => ProductionContextUpdated(
        productionContextId: _requiredString(payload, 'production_context_id'),
        code: _requiredString(payload, 'code'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateProductionContextUnchanged(
        productionContextId: _requiredString(payload, 'production_context_id'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'version_conflict' => UpdateProductionContextVersionConflict(
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'forbidden' => const UpdateProductionContextForbidden(),
      'invalid_input' => const UpdateProductionContextInvalidInput(),
      'not_found' => const UpdateProductionContextNotFound(),
      _ => throw const ProductionContextWriteProtocolException(
        'Invalid update_production_context response',
      ),
    };
  }

  Future<SetProductionContextActiveResult> setProductionContextActive({
    required String productionContextId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = await _invokeRpc('set_production_context_active', {
      'target_production_context_id': productionContextId,
      'expected_row_version': expectedRowVersion,
      'context_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'active_changed' => ProductionContextActiveChanged(
        productionContextId: _requiredString(payload, 'production_context_id'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetProductionContextActiveUnchanged(
        productionContextId: _requiredString(payload, 'production_context_id'),
        isActive: _requiredBool(payload, 'is_active'),
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'version_conflict' => SetProductionContextActiveVersionConflict(
        rowVersion: _requiredPositiveInt(payload, 'row_version'),
      ),
      'forbidden' => const SetProductionContextActiveForbidden(),
      'invalid_input' => const SetProductionContextActiveInvalidInput(),
      'not_found' => const SetProductionContextActiveNotFound(),
      'active_dependents' => const SetProductionContextActiveDependents(),
      _ => throw const ProductionContextWriteProtocolException(
        'Invalid set_production_context_active response',
      ),
    };
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const ProductionContextWriteProtocolException(
        'Production Context RPC response is not a map',
      );
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const ProductionContextWriteProtocolException(
        'Production Context RPC response contains invalid keys',
      );
    }
  }

  String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const ProductionContextWriteProtocolException(
        'Invalid Production Context RPC payload',
      );
    }

    return value;
  }

  int _requiredPositiveInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const ProductionContextWriteProtocolException(
        'Invalid Production Context RPC payload',
      );
    }

    return value;
  }

  bool _requiredBool(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const ProductionContextWriteProtocolException(
        'Invalid Production Context RPC payload',
      );
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const ProductionContextWriteProtocolException(
        'Invalid Production Context RPC payload',
      );
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const ProductionContextWriteProtocolException(
        'Invalid Production Context RPC payload',
      );
    }

    return parsed.toUtc();
  }
}
