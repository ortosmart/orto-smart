class BotanicalFamily {
  final String id;
  final String profileId;
  final String name;
  final String? scientificName;
  final String? description;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BotanicalFamily({
    required this.id,
    required this.profileId,
    required this.name,
    this.scientificName,
    this.description,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BotanicalFamily.fromMap(Map<String, dynamic> map) {
    return BotanicalFamily(
      id: map['id'].toString(),
      profileId: map['profile_id'].toString(),
      name: map['name'] as String,
      scientificName: map['scientific_name'] as String?,
      description: map['description'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      rowVersion: map['row_version'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
