class Bed {
  final String id;
  final String gardenId;
  final String code;
  final int number;
  final String? name;
  final int widthCm;
  final int lengthCm;
  final int? irrigationZone;
  final String? notes;
  final bool isActive;

  const Bed({
    required this.id,
    required this.gardenId,
    required this.code,
    required this.number,
    required this.widthCm,
    required this.lengthCm,
    this.name,
    this.irrigationZone,
    this.notes,
    required this.isActive,
  });

  factory Bed.fromMap(Map<String, dynamic> map) {
    return Bed(
      id: map['id'] as String,
      gardenId: map['garden_id'] as String,
      code: map['code'] as String,
      number: (map['number'] as num).toInt(),
      name: map['name'] as String?,
      widthCm: (map['width_cm'] as num).toInt(),
      lengthCm: (map['length_cm'] as num).toInt(),
      irrigationZone: map['irrigation_zone'] as int?,
      notes: map['notes'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}