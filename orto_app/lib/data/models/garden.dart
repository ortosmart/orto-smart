class Garden {
  final String id;
  final String profileId;
  final String name;
  final String? description;
  final bool isActive;
  final int rowVersion;

  const Garden({
    required this.id,
    required this.profileId,
    required this.name,
    this.description,
    required this.isActive,
    required this.rowVersion,
  });

  factory Garden.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final profileId = json['profile_id'];
    final name = json['name'];
    final description = json['description'];
    final isActive = json['is_active'];
    final rowVersion = json['row_version'];

    if (id is! String ||
        id.trim().isEmpty ||
        profileId is! String ||
        profileId.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        (description != null && description is! String) ||
        isActive is! bool ||
        rowVersion is! int ||
        rowVersion < 1) {
      throw const FormatException('Invalid Garden data');
    }

    return Garden(
      id: id,
      profileId: profileId,
      name: name,
      description: description as String?,
      isActive: isActive,
      rowVersion: rowVersion,
    );
  }
}
