class CropVariety {
  final int id;
  final int cropId;
  final String name;
  final String? scientificName;
  final String? description;
  final int? rowSpacingCm;
  final int? plantSpacingCm;
  final double? sowingDepthCm;
  final int? germinationDays;
  final int? harvestDays;
  final int? minTemperature;
  final int? optimalTemperature;
  final String? waterRequirement;
  final String? productivity;
  final bool isActive;
  final DateTime? createdAt;

  final String? defaultPlantingMethod;

  final double? expectedYieldMin;
  final double? expectedYieldAvg;
  final double? expectedYieldMax;
  final String? expectedYieldUnit;

  final String? yieldSourceName;
  final String? yieldSourceUrl;
  final int? yieldSourceYear;
  final String? yieldNotes;

  const CropVariety({
    required this.id,
    required this.cropId,
    required this.name,
    this.scientificName,
    this.description,
    this.rowSpacingCm,
    this.plantSpacingCm,
    this.sowingDepthCm,
    this.germinationDays,
    this.harvestDays,
    this.minTemperature,
    this.optimalTemperature,
    this.waterRequirement,
    this.productivity,
    this.isActive = true,
    this.createdAt,
    this.defaultPlantingMethod,
    this.expectedYieldMin,
    this.expectedYieldAvg,
    this.expectedYieldMax,
    this.expectedYieldUnit,
    this.yieldSourceName,
    this.yieldSourceUrl,
    this.yieldSourceYear,
    this.yieldNotes,
  });

  factory CropVariety.fromMap(Map<String, dynamic> map) {
    return CropVariety(
      id: map['id'] as int,
      cropId: map['crop_id'] as int,
      name: map['name'] as String,
      scientificName: map['scientific_name'] as String?,
      description: map['description'] as String?,
      rowSpacingCm: map['row_spacing_cm'] as int?,
      plantSpacingCm: map['plant_spacing_cm'] as int?,
      sowingDepthCm: (map['sowing_depth_cm'] as num?)?.toDouble(),
      germinationDays: map['germination_days'] as int?,
      harvestDays: map['harvest_days'] as int?,
      minTemperature: map['min_temperature'] as int?,
      optimalTemperature: map['optimal_temperature'] as int?,
      waterRequirement: map['water_requirement'] as String?,
      productivity: map['productivity'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
      defaultPlantingMethod: map['default_planting_method'] as String?,
      expectedYieldMin:
          (map['expected_yield_min'] as num?)?.toDouble(),
      expectedYieldAvg:
          (map['expected_yield_avg'] as num?)?.toDouble(),
      expectedYieldMax:
          (map['expected_yield_max'] as num?)?.toDouble(),
      expectedYieldUnit: map['expected_yield_unit'] as String?,
      yieldSourceName: map['yield_source_name'] as String?,
      yieldSourceUrl: map['yield_source_url'] as String?,
      yieldSourceYear: map['yield_source_year'] as int?,
      yieldNotes: map['yield_notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'crop_id': cropId,
      'name': name,
      'scientific_name': scientificName,
      'description': description,
      'row_spacing_cm': rowSpacingCm,
      'plant_spacing_cm': plantSpacingCm,
      'sowing_depth_cm': sowingDepthCm,
      'germination_days': germinationDays,
      'harvest_days': harvestDays,
      'min_temperature': minTemperature,
      'optimal_temperature': optimalTemperature,
      'water_requirement': waterRequirement,
      'productivity': productivity,
      'is_active': isActive,
      'default_planting_method': defaultPlantingMethod,
      'expected_yield_min': expectedYieldMin,
      'expected_yield_avg': expectedYieldAvg,
      'expected_yield_max': expectedYieldMax,
      'expected_yield_unit': expectedYieldUnit,
      'yield_source_name': yieldSourceName,
      'yield_source_url': yieldSourceUrl,
      'yield_source_year': yieldSourceYear,
      'yield_notes': yieldNotes,
    };
  }
}