class Crop {
  final String id;
  final String? profileId;
  final String? botanicalFamilyId;
  final String name;
  final String? scientificName;
  final String? description;
  final String? defaultStartMethod;
  final int? rowSpacingCm;
  final int? plantSpacingCm;
  final double? sowingDepthCm;
  final int? germinationDays;
  final int? harvestDays;
  final int? minTemperature;
  final int? optimalTemperature;
  final int? rotationSeasons;
  final String? waterRequirement;
  final double? waterRequirementValue;
  final String? waterRequirementBasis;
  final int? waterIntervalDays;
  final String? productivity;
  final double? expectedYieldMin;
  final double? expectedYieldAvg;
  final double? expectedYieldMax;
  final String? expectedYieldUnit;
  final String? yieldSourceName;
  final String? yieldSourceUrl;
  final int? yieldSourceYear;
  final String? yieldNotes;
  final bool isActive;
  final int? rowVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? botanicalFamilyName;
  final bool heavyFeeder;

  const Crop({
    required this.id,
    required this.name,
    this.profileId,
    this.botanicalFamilyId,
    this.scientificName,
    this.description,
    this.defaultStartMethod,
    this.rowSpacingCm,
    this.plantSpacingCm,
    this.sowingDepthCm,
    this.germinationDays,
    this.harvestDays,
    this.minTemperature,
    this.optimalTemperature,
    this.rotationSeasons,
    this.waterRequirement,
    this.waterRequirementValue,
    this.waterRequirementBasis,
    this.waterIntervalDays,
    this.productivity,
    this.expectedYieldMin,
    this.expectedYieldAvg,
    this.expectedYieldMax,
    this.expectedYieldUnit,
    this.yieldSourceName,
    this.yieldSourceUrl,
    this.yieldSourceYear,
    this.yieldNotes,
    this.isActive = true,
    this.rowVersion,
    this.createdAt,
    this.updatedAt,
    String? botanicalFamily,
    String? botanicalFamilyName,
    this.heavyFeeder = false,
  }) : botanicalFamilyName = botanicalFamilyName ?? botanicalFamily;

  String? get botanicalFamily => botanicalFamilyName;
  String? get sowingMethod => defaultStartMethod;

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: _requiredString(map, 'crop_id'),
      botanicalFamilyId: _optionalString(map, 'family_taxon_id'),
      name: _requiredString(map, 'canonical_name'),
      scientificName: _optionalString(map, 'taxon_scientific_name'),
      description: _optionalString(map, 'description'),
      isActive: _requiredBool(map, 'is_active'),
      rowVersion: _requiredPositiveInt(map, 'row_version'),
      createdAt: _requiredDateTime(map, 'created_at'),
      updatedAt: _requiredDateTime(map, 'updated_at'),
      botanicalFamilyName: _optionalString(map, 'family_scientific_name'),
    );
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid Crop response');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid Crop response');
    }
    return value;
  }

  static bool _requiredBool(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! bool) throw const FormatException('Invalid Crop response');
    return value;
  }

  static int _requiredPositiveInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! int || value < 1) {
      throw const FormatException('Invalid Crop response');
    }
    return value;
  }

  static DateTime _requiredDateTime(Map<String, dynamic> map, String key) {
    final value = map[key];
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed == null) throw const FormatException('Invalid Crop response');
    return parsed.toUtc();
  }
}
