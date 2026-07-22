class Season {
  final String id;
  final String gardenId;
  final int year;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? notes;

  const Season({
    required this.id,
    required this.gardenId,
    required this.year,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.notes,
  });

  factory Season.fromMap(Map<String, dynamic> map) {
    return Season(
      id: map['id'].toString(),
      gardenId: map['garden_id'].toString(),
      year: map['year'] as int,
      name: map['name'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] == null
          ? null
          : DateTime.parse(map['end_date'] as String),
      isActive: map['is_active'] as bool? ?? false,
      notes: map['notes'] as String?,
    );
  }
}