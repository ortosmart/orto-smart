
class MeasurementUnit {
  final String id;
  final String code;
  final String name;
  final String symbol;
  final String quantityKind;
  final num toBaseFactor;
  final num toBaseOffset;
  final String? description;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeasurementUnit({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    required this.quantityKind,
    required this.toBaseFactor,
    required this.toBaseOffset,
    required this.description,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MeasurementUnit.fromMap(Map<String, dynamic> map) {
    String requiredString(String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Invalid measurement unit $key');
      }
      return value;
    }

    DateTime requiredDateTime(String key) {
      final value = requiredString(key);
      final parsed = DateTime.tryParse(value);
      if (parsed == null || !parsed.isUtc && !value.contains(RegExp(r'[Zz]|[+-]\d{2}:\d{2}$'))) {
        throw FormatException('Invalid measurement unit $key');
      }
      return parsed.toUtc();
    }

    num requiredFiniteNumber(String key, {bool positive = false}) {
      final value = map[key];
      if (value is! num || !value.isFinite || (positive && value <= 0)) {
        throw FormatException('Invalid measurement unit $key');
      }
      return value;
    }

    final descriptionValue = map['description'];
    if (descriptionValue != null && descriptionValue is! String) {
      throw const FormatException('Invalid measurement unit description');
    }

    final isActiveValue = map['is_active'];
    if (isActiveValue is! bool) {
      throw const FormatException('Invalid measurement unit is_active');
    }

    final rowVersionValue = map['row_version'];
    if (rowVersionValue is! int || rowVersionValue < 1) {
      throw const FormatException('Invalid measurement unit row_version');
    }

    return MeasurementUnit(
      id: requiredString('id'),
      code: requiredString('code'),
      name: requiredString('name'),
      symbol: requiredString('symbol'),
      quantityKind: requiredString('quantity_kind'),
      toBaseFactor: requiredFiniteNumber('to_base_factor', positive: true),
      toBaseOffset: requiredFiniteNumber('to_base_offset'),
      description: descriptionValue as String?,
      isActive: isActiveValue,
      rowVersion: rowVersionValue,
      createdAt: requiredDateTime('created_at'),
      updatedAt: requiredDateTime('updated_at'),
    );
  }
}
