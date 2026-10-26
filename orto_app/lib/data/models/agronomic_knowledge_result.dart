/// Strict, transport-level contract for resolve_agronomic_knowledge.
/// No implicit fallback, rounding, unit conversion, or network access.
library;

final class AgronomicKnowledgeRequest {
  final String parameterId;
  final String cropId;
  final String? cultivarId;
  final String? productionContextId;
  final String? protectionContextId;
  final String? trainingContextId;
  final String? harvestPurposeId;

  AgronomicKnowledgeRequest({
    required this.parameterId,
    required this.cropId,
    required this.cultivarId,
    required this.productionContextId,
    required this.protectionContextId,
    required this.trainingContextId,
    required this.harvestPurposeId,
  }) {
    _uuid(parameterId);
    _uuid(cropId);
    for (final id in [
      cultivarId,
      productionContextId,
      protectionContextId,
      trainingContextId,
      harvestPurposeId,
    ]) {
      if (id != null) _uuid(id);
    }
  }

  void verify(Map<String, String?> ids) {
    final expected = <String, String?>{
      'parameter_id': parameterId,
      'crop_id': cropId,
      'cultivar_id': cultivarId,
      'production_context_id': productionContextId,
      'protection_context_id': protectionContextId,
      'training_context_id': trainingContextId,
      'harvest_purpose_id': harvestPurposeId,
    };
    for (final entry in expected.entries) {
      if (!ids.containsKey(entry.key) ||
          ids[entry.key] !=
              (entry.value == null ? null : _uuid(entry.value as Object))) {
        throw FormatException(
          'Agronomic knowledge request mismatch: ${entry.key}',
        );
      }
    }
  }
}

final class AgronomicKnowledgeMetadata {
  final String assertionId;
  final int revisionNo;
  final String parameterCode;
  final String kind;
  final String valueSchema;
  final Map<String, String?> identifiers;

  AgronomicKnowledgeMetadata._(
    this.assertionId,
    this.revisionNo,
    this.parameterCode,
    this.kind,
    this.valueSchema,
    this.identifiers,
  );

  factory AgronomicKnowledgeMetadata.fromMap(Map<String, dynamic> map) {
    final revision = map['revision_no'];
    if (revision is! int || revision < 1) {
      throw const FormatException('Invalid revision_no');
    }
    final kind = _oneOf(map, 'kind', {'VALUE', 'NOT_APPLICABLE'});
    final schema = _oneOf(map, 'value_schema', {
      'NUMERIC_SCALAR',
      'NUMERIC_RANGE',
      'BOOLEAN',
      'ENUM',
    });
    return AgronomicKnowledgeMetadata._(
      _uuid(_required(map, 'assertion_id')),
      revision,
      _nonempty(map, 'parameter_code'),
      kind,
      schema,
      _identifiers(map),
    );
  }
}

final class AgronomicUnit {
  final String id;
  final String code;
  final String name;
  final String? symbol;
  final String quantityKind;

  AgronomicUnit._(
    this.id,
    this.code,
    this.name,
    this.symbol,
    this.quantityKind,
  );

  factory AgronomicUnit.fromMap(Map<String, dynamic> map) => AgronomicUnit._(
    _uuid(_required(map, 'id')),
    _nonempty(map, 'code'),
    _nonempty(map, 'name'),
    _optionalString(map, 'symbol'),
    _nonempty(map, 'quantity_kind'),
  );
}

sealed class AgronomicValue {
  const AgronomicValue();
}

final class AgronomicNumericScalar extends AgronomicValue {
  final num numericValue;
  final AgronomicUnit unit;
  const AgronomicNumericScalar(this.numericValue, this.unit);
}

final class AgronomicNumericRange extends AgronomicValue {
  final num minimum;
  final num maximum;
  final AgronomicUnit unit;
  const AgronomicNumericRange(this.minimum, this.maximum, this.unit);
}

final class AgronomicBoolean extends AgronomicValue {
  final bool value;
  const AgronomicBoolean(this.value);
}

final class AgronomicEnum extends AgronomicValue {
  final String id;
  final String code;
  final String name;
  const AgronomicEnum(this.id, this.code, this.name);
}

sealed class AgronomicKnowledgeResult {
  const AgronomicKnowledgeResult();

  static AgronomicKnowledgeResult fromMap(Map<String, dynamic> map) {
    final status = _nonempty(map, 'status');
    switch (status) {
      case 'RESOLVED':
        final metadata = AgronomicKnowledgeMetadata.fromMap(map);
        if (metadata.kind != 'VALUE') {
          throw const FormatException('RESOLVED requires kind VALUE');
        }
        final valueMap = _object(map, 'value');
        final type = _oneOf(valueMap, 'type', {
          'NUMERIC_SCALAR',
          'NUMERIC_RANGE',
          'BOOLEAN',
          'ENUM',
        });
        if (type != metadata.valueSchema) {
          throw const FormatException('value type and schema mismatch');
        }
        final AgronomicValue value;
        switch (type) {
          case 'NUMERIC_SCALAR':
            value = AgronomicNumericScalar(
              _finite(valueMap, 'numeric_value'),
              AgronomicUnit.fromMap(_object(valueMap, 'unit')),
            );
            break;
          case 'NUMERIC_RANGE':
            final min = _finite(valueMap, 'numeric_min_value');
            final max = _finite(valueMap, 'numeric_max_value');
            if (min > max) {
              throw const FormatException('Invalid numeric range');
            }
            value = AgronomicNumericRange(
              min,
              max,
              AgronomicUnit.fromMap(_object(valueMap, 'unit')),
            );
            break;
          case 'BOOLEAN':
            final raw = _required(valueMap, 'boolean_value');
            if (raw is! bool) {
              throw const FormatException('Invalid boolean_value');
            }
            value = AgronomicBoolean(raw);
            break;
          case 'ENUM':
            final enumMap = _object(valueMap, 'enum_value');
            value = AgronomicEnum(
              _uuid(_required(enumMap, 'id')),
              _nonempty(enumMap, 'code'),
              _nonempty(enumMap, 'name'),
            );
            break;
          default:
            throw const FormatException('Unsupported value type');
        }
        return AgronomicResolved(metadata, value);
      case 'NO_APPROVED_VALUE':
        _absent(map, 'value');
        return AgronomicNoApprovedValue(_identifiers(map));
      case 'NOT_APPLICABLE':
        final metadata = AgronomicKnowledgeMetadata.fromMap(map);
        if (metadata.kind != 'NOT_APPLICABLE') {
          throw const FormatException('Invalid NOT_APPLICABLE kind');
        }
        _absent(map, 'value');
        return AgronomicNotApplicable(metadata);
      case 'RESOLUTION_CONFLICT':
        _absent(map, 'value');
        final reason = _oneOf(map, 'conflict_reason', {
          'MULTIPLE_APPROVED_ASSERTIONS',
          'INACTIVE_CANONICAL_UNIT',
          'NON_CANONICAL_UNIT',
          'INACTIVE_ENUM_VALUE',
          'UNSUPPORTED_VALUE_SCHEMA',
        });
        if (reason == 'MULTIPLE_APPROVED_ASSERTIONS') {
          return AgronomicResolutionConflict(reason, null);
        }
        return AgronomicResolutionConflict(
          reason,
          AgronomicKnowledgeMetadata.fromMap(map),
        );
      default:
        if (!_failureStatuses.contains(status)) {
          throw FormatException('Unknown agronomic resolver status: $status');
        }
        String? detail;
        if (status == 'invalid_target') {
          detail = _oneOf(map, 'target_level', {'CROP', 'CULTIVAR'});
        } else if (status == 'invalid_context') {
          detail = _oneOf(map, 'context_type', {
            'PRODUCTION',
            'PROTECTION',
            'TRAINING',
            'HARVEST_PURPOSE',
          });
        }
        return AgronomicResolverFailure(status, detail);
    }
  }
}

final class AgronomicResolved extends AgronomicKnowledgeResult {
  final AgronomicKnowledgeMetadata metadata;
  final AgronomicValue value;
  const AgronomicResolved(this.metadata, this.value);
}

final class AgronomicNoApprovedValue extends AgronomicKnowledgeResult {
  final Map<String, String?> identifiers;

  AgronomicNoApprovedValue(Map<String, String?> identifiers)
    : identifiers = Map.unmodifiable(identifiers);
}

final class AgronomicNotApplicable extends AgronomicKnowledgeResult {
  final AgronomicKnowledgeMetadata metadata;
  const AgronomicNotApplicable(this.metadata);
}

final class AgronomicResolutionConflict extends AgronomicKnowledgeResult {
  final String reason;
  final AgronomicKnowledgeMetadata? metadata;
  const AgronomicResolutionConflict(this.reason, this.metadata);
}

final class AgronomicResolverFailure extends AgronomicKnowledgeResult {
  final String status;

  /// target_level or context_type when applicable.
  final String? detail;
  const AgronomicResolverFailure(this.status, this.detail);
}

/// Fail closed: errors and conflicts without identity metadata cannot be
/// matched to a request; callers must never use them as agronomic values.
void verifyAgronomicKnowledgeIdentity(
  AgronomicKnowledgeRequest request,
  AgronomicKnowledgeResult result,
) {
  switch (result) {
    case AgronomicResolved(:final metadata):
      request.verify(metadata.identifiers);
    case AgronomicNotApplicable(:final metadata):
      request.verify(metadata.identifiers);
    case AgronomicNoApprovedValue(:final identifiers):
      request.verify(identifiers);
    case AgronomicResolutionConflict(:final metadata):
      if (metadata != null) request.verify(metadata.identifiers);
    case AgronomicResolverFailure():
      break;
  }
}

const _failureStatuses = <String>{
  'unauthenticated',
  'invalid_input',
  'parameter_not_found',
  'parameter_inactive',
  'crop_not_found',
  'crop_inactive',
  'cultivar_not_found',
  'cultivar_crop_mismatch',
  'cultivar_inactive',
  'invalid_target',
  'invalid_context',
  'production_context_not_found',
  'production_context_inactive',
  'protection_context_not_found',
  'protection_context_inactive',
  'training_context_not_found',
  'training_context_inactive',
  'harvest_purpose_not_found',
  'harvest_purpose_inactive',
};

Object _required(Map<String, dynamic> map, String key) {
  if (!map.containsKey(key) || map[key] == null) {
    throw FormatException('Missing required field: $key');
  }
  return map[key] as Object;
}

String _nonempty(Map<String, dynamic> map, String key) {
  final value = _required(map, key);
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Invalid string: $key');
  }
  return value;
}

String? _optionalString(Map<String, dynamic> map, String key) {
  if (!map.containsKey(key)) {
    throw FormatException('Missing field: $key');
  }
  final value = map[key];
  if (value != null && value is! String) {
    throw FormatException('Invalid string: $key');
  }
  return value as String?;
}

String _oneOf(Map<String, dynamic> map, String key, Set<String> allowed) {
  final value = _nonempty(map, key);
  if (!allowed.contains(value)) {
    throw FormatException('Unsupported $key: $value');
  }
  return value;
}

Map<String, dynamic> _object(Map<String, dynamic> map, String key) {
  final value = _required(map, key);
  if (value is! Map<String, dynamic>) {
    throw FormatException('Invalid object: $key');
  }
  return value;
}

num _finite(Map<String, dynamic> map, String key) {
  final value = _required(map, key);
  if (value is! num || !value.isFinite) {
    throw FormatException('Invalid numeric value: $key');
  }
  return value;
}

void _absent(Map<String, dynamic> map, String key) {
  if (map.containsKey(key)) {
    throw FormatException('Unexpected field: $key');
  }
}

String _uuid(Object value) {
  if (value is! String ||
      !RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(value)) {
    throw const FormatException('Invalid UUID');
  }
  return value.toLowerCase();
}

Map<String, String?> _identifiers(Map<String, dynamic> map) {
  final ids = <String, String?>{};
  for (final key in [
    'parameter_id',
    'crop_id',
    'cultivar_id',
    'production_context_id',
    'protection_context_id',
    'training_context_id',
    'harvest_purpose_id',
  ]) {
    if (!map.containsKey(key)) {
      throw FormatException('Missing identifier: $key');
    }
    final raw = map[key];
    if (raw == null) {
      if (key == 'parameter_id' || key == 'crop_id') {
        throw FormatException('Null identifier: $key');
      }
      ids[key] = null;
    } else {
      ids[key] = _uuid(raw);
    }
  }
  return Map.unmodifiable(ids);
}
