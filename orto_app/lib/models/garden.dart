class Garden {
  final String id;
  final String name;
  final String? description;
  final int bedsCount;
  final int bedLengthCm;
  final int bedWidthCm;
  final int pathWidthCm;

  const Garden({
    required this.id,
    required this.name,
    this.description,
    required this.bedsCount,
    required this.bedLengthCm,
    required this.bedWidthCm,
    required this.pathWidthCm,
  });

  factory Garden.fromJson(Map<String, dynamic> json) {
    return Garden(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      bedsCount: json['beds_count'] as int,
      bedLengthCm: json['bed_length_cm'] as int,
      bedWidthCm: json['bed_width_cm'] as int,
      pathWidthCm: json['path_width_cm'] as int,
    );
  }
}