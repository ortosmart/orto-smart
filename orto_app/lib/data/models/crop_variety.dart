class CropVariety {
  final String id;
  final String profileId;
  final String cropId;

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
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CropVariety({
    required this.id,
    required this.profileId,
    required this.cropId,
    required this.name,
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
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Alias temporaneo per la UI legacy delle varietà.
  ///
  /// Il campo autoritativo del Catalogo DB V1 è [defaultStartMethod].
  String? get defaultPlantingMethod => defaultStartMethod;

  factory CropVariety.fromMap(Map<String, dynamic> map) {
    return CropVariety(
      id: map['id'].toString(),
      profileId: map['profile_id'].toString(),
      cropId: map['crop_id'].toString(),
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
      rowVersion: map['row_version'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
