class Crop {
  final String id;
  final String name;
  final String? variety;
  final String? sowingMethod;
  final int? rowSpacingCm;
  final int? plantSpacingCm;

  final String? botanicalFamily;
  final int? rotationSeasons;
  final bool heavyFeeder;

  const Crop({
    required this.id,
    required this.name,
    this.variety,
    this.sowingMethod,
    this.rowSpacingCm,
    this.plantSpacingCm,
    this.botanicalFamily,
    this.rotationSeasons,
    this.heavyFeeder = false,
  });

  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: map['id'].toString(),
      name: map['name'] as String,
      variety: map['variety'] as String?,
      sowingMethod: map['sowing_method'] as String?,
      rowSpacingCm: map['row_spacing_cm'] as int?,
      plantSpacingCm: map['plant_spacing_cm'] as int?,
      botanicalFamily: map['botanical_family'] as String?,
      rotationSeasons: map['rotation_seasons'] as int?,
      heavyFeeder: map['heavy_feeder'] as bool? ?? false,
    );
  }
}