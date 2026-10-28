
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/measurement_unit_write_result.dart';
import '../models/measurement_unit.dart';

typedef MeasurementUnitListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef MeasurementUnitRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class MeasurementUnitRepository {
  final MeasurementUnitListLoader _loadUnits;
  final MeasurementUnitRpcInvoker _invokeRpc;

  factory MeasurementUnitRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return MeasurementUnitRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('measurement_units').select();

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

  MeasurementUnitRepository.withProviders(
    this._loadUnits,
    this._invokeRpc,
  );

  MeasurementUnitRepository.withLoader(
    MeasurementUnitListLoader loadUnits,
  ) : this.withProviders(loadUnits, (functionName, parameters) {
          throw UnsupportedError(
            'RPC invocation is not configured for this '
            'MeasurementUnitRepository',
          );
        });

  Future<List<MeasurementUnit>> getMeasurementUnits({
    bool activeOnly = true,
  }) async {
    final response = await _loadUnits(activeOnly: activeOnly);
    return response.map(MeasurementUnit.fromMap).toList();
  }

  Future<CreateMeasurementUnitResult> createMeasurementUnit({
    required String code,
    required String name,
    required String symbol,
    required String quantityKind,
    required num toBaseFactor,
    required num toBaseOffset,
    String? description,
  }) async {
    final response = await _invokeRpc('create_measurement_unit', {
      'unit_code': code,
      'unit_name': name,
      'unit_symbol': symbol,
      'unit_quantity_kind': quantityKind,
      'unit_to_base_factor': toBaseFactor,
      'unit_to_base_offset': toBaseOffset,
      'unit_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => MeasurementUnitCreated(
          measurementUnitId: _requiredString(payload, 'measurement_unit_id'),
          code: _requiredString(payload, 'code'),
          isActive: _requiredBool(payload, 'is_active'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
          createdAt: _requiredDateTime(payload, 'created_at'),
        ),
      'forbidden' => const CreateMeasurementUnitForbidden(),
      'invalid_input' => const CreateMeasurementUnitInvalidInput(),
      'duplicate_code' => const CreateMeasurementUnitDuplicateCode(),
      _ => throw const MeasurementUnitWriteProtocolException(
          'Invalid create_measurement_unit response',
        ),
    };
  }

  Future<UpdateMeasurementUnitResult> updateMeasurementUnit({
    required String measurementUnitId,
    required int expectedRowVersion,
    required String code,
    required String name,
    required String symbol,
    required String quantityKind,
    required num toBaseFactor,
    required num toBaseOffset,
    String? description,
  }) async {
    final response = await _invokeRpc('update_measurement_unit', {
      'target_measurement_unit_id': measurementUnitId,
      'expected_row_version': expectedRowVersion,
      'unit_code': code,
      'unit_name': name,
      'unit_symbol': symbol,
      'unit_quantity_kind': quantityKind,
      'unit_to_base_factor': toBaseFactor,
      'unit_to_base_offset': toBaseOffset,
      'unit_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => MeasurementUnitUpdated(
          measurementUnitId: _requiredString(payload, 'measurement_unit_id'),
          code: _requiredString(payload, 'code'),
          isActive: _requiredBool(payload, 'is_active'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
          updatedAt: _requiredDateTime(payload, 'updated_at'),
        ),
      'unchanged' => UpdateMeasurementUnitUnchanged(
          measurementUnitId: _requiredString(payload, 'measurement_unit_id'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
        ),
      'version_conflict' => UpdateMeasurementUnitVersionConflict(
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
        ),
      'forbidden' => const UpdateMeasurementUnitForbidden(),
      'invalid_input' => const UpdateMeasurementUnitInvalidInput(),
      'not_found' => const UpdateMeasurementUnitNotFound(),
      'semantics_frozen' => const UpdateMeasurementUnitSemanticsFrozen(),
      'unit_in_use' => const UpdateMeasurementUnitInUse(),
      'duplicate_code' => const UpdateMeasurementUnitDuplicateCode(),
      _ => throw const MeasurementUnitWriteProtocolException(
          'Invalid update_measurement_unit response',
        ),
    };
  }

  Future<SetMeasurementUnitActiveResult> setMeasurementUnitActive({
    required String measurementUnitId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = await _invokeRpc('set_measurement_unit_active', {
      'target_measurement_unit_id': measurementUnitId,
      'expected_row_version': expectedRowVersion,
      'unit_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'active_changed' => MeasurementUnitActiveChanged(
          measurementUnitId: _requiredString(payload, 'measurement_unit_id'),
          isActive: _requiredBool(payload, 'is_active'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
          updatedAt: _requiredDateTime(payload, 'updated_at'),
        ),
      'unchanged' => SetMeasurementUnitActiveUnchanged(
          measurementUnitId: _requiredString(payload, 'measurement_unit_id'),
          isActive: _requiredBool(payload, 'is_active'),
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
        ),
      'version_conflict' => SetMeasurementUnitActiveVersionConflict(
          rowVersion: _requiredPositiveInt(payload, 'row_version'),
        ),
      'forbidden' => const SetMeasurementUnitActiveForbidden(),
      'invalid_input' => const SetMeasurementUnitActiveInvalidInput(),
      'not_found' => const SetMeasurementUnitActiveNotFound(),
      'active_dependents' => const SetMeasurementUnitActiveDependents(),
      _ => throw const MeasurementUnitWriteProtocolException(
          'Invalid set_measurement_unit_active response',
        ),
    };
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const MeasurementUnitWriteProtocolException(
        'Measurement Unit RPC response is not a map',
      );
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const MeasurementUnitWriteProtocolException(
        'Measurement Unit RPC response contains invalid keys',
      );
    }
  }

  String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const MeasurementUnitWriteProtocolException(
        'Invalid Measurement Unit RPC payload',
      );
    }

    return value;
  }

  int _requiredPositiveInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const MeasurementUnitWriteProtocolException(
        'Invalid Measurement Unit RPC payload',
      );
    }

    return value;
  }

  bool _requiredBool(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const MeasurementUnitWriteProtocolException(
        'Invalid Measurement Unit RPC payload',
      );
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String ||
        !RegExp(r'(?:[Zz]|[+-]\d{2}:\d{2})$').hasMatch(value)) {
      throw const MeasurementUnitWriteProtocolException(
        'Invalid Measurement Unit RPC timestamp',
      );
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw const MeasurementUnitWriteProtocolException(
        'Invalid Measurement Unit RPC timestamp',
      );
    }

    return parsed.toUtc();
  }
}
