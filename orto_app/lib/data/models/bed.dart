import 'bed_geometry.dart';

class Bed {
  final String id;
  final String gardenId;
  final int number;
  final String? name;
  final String? notes;
  final bool isActive;
  final int rowVersion;
  final BedGeometry geometry;

  const Bed({
    required this.id,
    required this.gardenId,
    required this.number,
    this.name,
    this.notes,
    required this.isActive,
    required this.rowVersion,
    required this.geometry,
  });

  String get code => 'A${number.toString().padLeft(2, '0')}';

  int get widthCm => geometry.widthCm;

  int get lengthCm => geometry.lengthCm;

  factory Bed.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String;
    final gardenId = map['garden_id'] as String;
    final number = map['number'] as int;
    final rowVersion = map['row_version'] as int;

    final geometries = map['bed_geometries'];

    if (geometries is! List ||
        geometries.length != 1 ||
        geometries.single is! Map) {
      throw const FormatException('Expected exactly one selected BedGeometry');
    }

    final geometry = BedGeometry.fromMap(
      Map<String, dynamic>.from(geometries.single as Map),
    );

    if (id.trim().isEmpty ||
        gardenId.trim().isEmpty ||
        number <= 0 ||
        rowVersion < 1 ||
        geometry.bedId != id) {
      throw const FormatException('Invalid Bed data');
    }

    return Bed(
      id: id,
      gardenId: gardenId,
      number: number,
      name: map['name'] as String?,
      notes: map['notes'] as String?,
      isActive: map['is_active'] as bool,
      rowVersion: rowVersion,
      geometry: geometry,
    );
  }
}
