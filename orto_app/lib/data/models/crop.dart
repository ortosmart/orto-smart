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

  /// Nome della famiglia botanica disponibile quando la query lo fornisce.
  ///
  /// È distinto da [botanicalFamilyId], che rappresenta la relazione
  /// autoritativa del Catalogo DB V1.
  final String? botanicalFamilyName;

  /// Compatibilità temporanea con il dominio agronomico legacy.
  ///
  /// Non è un campo persistente del Catalogo DB V1.
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

  /// Alias temporaneo usato dal motore di rotazione legacy.
  String? get botanicalFamily => botanicalFamilyName;

  /// Alias temporaneo usato dalla pagina legacy di inserimento planting.
  ///
  /// Il valore autoritativo V1 resta [defaultStartMethod].
  String? get sowingMethod => defaultStartMethod;

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: map['id'].toString(),
      profileId: map['profile_id']?.toString(),
      botanicalFamilyId: map['botanical_family_id']?.toString(),
      name: map['name'] as String,
      scientificName: map['scientific_name'] as String?,
      description: map['description'] as String?,
      defaultStartMethod: map['default_start_method'] as String?,
      rowSpacingCm: map['row_spacing_cm'] as int?,
      plantSpacingCm: map['plant_spacing_cm'] as int?,
      sowingDepthCm: (map['sowing_depth_cm'] as num?)?.toDouble(),
      germinationDays: map['germination_days'] as int?,
      harvestDays: map['harvest_days'] as int?,
      minTemperature: map['min_temperature'] as int?,
      optimalTemperature: map['optimal_temperature'] as int?,
      rotationSeasons: map['rotation_seasons'] as int?,
      waterRequirement: map['water_requirement'] as String?,
      waterRequirementValue: (map['water_requirement_value'] as num?)
          ?.toDouble(),
      waterRequirementBasis: map['water_requirement_basis'] as String?,
      waterIntervalDays: map['water_interval_days'] as int?,
      productivity: map['productivity'] as String?,
      expectedYieldMin: (map['expected_yield_min'] as num?)?.toDouble(),
      expectedYieldAvg: (map['expected_yield_avg'] as num?)?.toDouble(),
      expectedYieldMax: (map['expected_yield_max'] as num?)?.toDouble(),
      expectedYieldUnit: map['expected_yield_unit'] as String?,
      yieldSourceName: map['yield_source_name'] as String?,
      yieldSourceUrl: map['yield_source_url'] as String?,
      yieldSourceYear: map['yield_source_year'] as int?,
      yieldNotes: map['yield_notes'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      rowVersion: map['row_version'] as int?,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
      botanicalFamilyName: map['botanical_family_name'] as String?,
    );
  }
}
