
class AgronomicParameter {
  final String id;
  final String code;
  final String name;
  final String? description;

  final String valueSchema;
  final String knowledgeScope;

  final String? quantityKind;
  final String? canonicalUnitId;

  final bool allowsCrop;
  final bool allowsCultivar;
  final bool allowsProductionContext;
  final bool allowsProtectionContext;
  final bool allowsTrainingContext;
  final bool allowsHarvestPurpose;

  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgronomicParameter({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.valueSchema,
    required this.knowledgeScope,
    required this.quantityKind,
    required this.canonicalUnitId,
    required this.allowsCrop,
    required this.allowsCultivar,
    required this.allowsProductionContext,
    required this.allowsProtectionContext,
    required this.allowsTrainingContext,
    required this.allowsHarvestPurpose,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgronomicParameter.fromMap(Map<String, dynamic> map) {
    String requiredString(String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Invalid agronomic parameter $key');
      }
      return value;
    }

    String? optionalString(String key) {
      final value = map[key];
      if (value == null) return null;
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Invalid agronomic parameter $key');
      }
      return value;
    }

    bool requiredBool(String key) {
      final value = map[key];
      if (value is! bool) {
        throw FormatException('Invalid agronomic parameter $key');
      }
      return value;
    }

    DateTime requiredDateTime(String key) {
      final value = requiredString(key);
      final parsed = DateTime.tryParse(value);

      if (parsed == null ||
          !RegExp(r'(?:[Zz]|[+-]\d{2}:\d{2})$').hasMatch(value)) {
        throw FormatException('Invalid agronomic parameter $key');
      }

      return parsed.toUtc();
    }

    final version = map['row_version'];
    if (version is! int || version < 1) {
      throw const FormatException(
        'Invalid agronomic parameter row_version',
      );
    }

    final valueSchema = requiredString('value_schema');
    if (!const {
      'NUMERIC_SCALAR',
      'NUMERIC_RANGE',
      'BOOLEAN',
      'ENUM',
    }.contains(valueSchema)) {
      throw const FormatException(
        'Invalid agronomic parameter value_schema',
      );
    }

    final knowledgeScope = requiredString('knowledge_scope');
    if (!const {
      'INTRINSIC',
      'CONTEXTUAL',
    }.contains(knowledgeScope)) {
      throw const FormatException(
        'Invalid agronomic parameter knowledge_scope',
      );
    }

    final quantityKind = optionalString('quantity_kind');
    final canonicalUnitId = optionalString('canonical_unit_id');

    final numericSchema = valueSchema == 'NUMERIC_SCALAR' ||
        valueSchema == 'NUMERIC_RANGE';

    if (numericSchema) {
      if (quantityKind == null || canonicalUnitId == null) {
        throw const FormatException(
          'Numeric agronomic parameter requires a canonical unit',
        );
      }
    } else if (quantityKind != null || canonicalUnitId != null) {
      throw const FormatException(
        'Non-numeric agronomic parameter cannot have a canonical unit',
      );
    }

    final allowsCrop = requiredBool('allows_crop');
    final allowsCultivar = requiredBool('allows_cultivar');
    final allowsProductionContext =
        requiredBool('allows_production_context');
    final allowsProtectionContext =
        requiredBool('allows_protection_context');
    final allowsTrainingContext =
        requiredBool('allows_training_context');
    final allowsHarvestPurpose =
        requiredBool('allows_harvest_purpose');

    if (!allowsCrop && !allowsCultivar) {
      throw const FormatException(
        'Agronomic parameter requires a crop or cultivar target',
      );
    }

    final hasContext = allowsProductionContext ||
        allowsProtectionContext ||
        allowsTrainingContext ||
        allowsHarvestPurpose;

    if ((knowledgeScope == 'INTRINSIC' && hasContext) ||
        (knowledgeScope == 'CONTEXTUAL' && !hasContext)) {
      throw const FormatException(
        'Invalid agronomic parameter context scope',
      );
    }

    return AgronomicParameter(
      id: requiredString('id'),
      code: requiredString('code'),
      name: requiredString('name'),
      description: optionalString('description'),
      valueSchema: valueSchema,
      knowledgeScope: knowledgeScope,
      quantityKind: quantityKind,
      canonicalUnitId: canonicalUnitId,
      allowsCrop: allowsCrop,
      allowsCultivar: allowsCultivar,
      allowsProductionContext: allowsProductionContext,
      allowsProtectionContext: allowsProtectionContext,
      allowsTrainingContext: allowsTrainingContext,
      allowsHarvestPurpose: allowsHarvestPurpose,
      isActive: requiredBool('is_active'),
      rowVersion: version,
      createdAt: requiredDateTime('created_at'),
      updatedAt: requiredDateTime('updated_at'),
    );
  }
}
