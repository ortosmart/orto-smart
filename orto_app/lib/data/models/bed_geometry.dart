class BedGeometry {
  final String id;
  final String bedId;
  final int widthCm;
  final int lengthCm;
  final DateTime validFrom;
  final DateTime? validTo;
  final int rowVersion;

  const BedGeometry({
    required this.id,
    required this.bedId,
    required this.widthCm,
    required this.lengthCm,
    required this.validFrom,
    this.validTo,
    required this.rowVersion,
  });

  factory BedGeometry.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as String;
    final bedId = map['bed_id'] as String;
    final widthCm = map['width_cm'] as int;
    final lengthCm = map['length_cm'] as int;
    final rowVersion = map['row_version'] as int;
    final validFrom = _parseDate(map['valid_from']);
    final validTo = map['valid_to'] == null
        ? null
        : _parseDate(map['valid_to']);

    if (id.trim().isEmpty ||
        bedId.trim().isEmpty ||
        widthCm <= 0 ||
        lengthCm <= 0 ||
        rowVersion < 1 ||
        (validTo != null && !validTo.isAfter(validFrom))) {
      throw const FormatException('Invalid BedGeometry data');
    }

    return BedGeometry(
      id: id,
      bedId: bedId,
      widthCm: widthCm,
      lengthCm: lengthCm,
      validFrom: validFrom,
      validTo: validTo,
      rowVersion: rowVersion,
    );
  }

  static DateTime _parseDate(Object? value) {
    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw const FormatException('Invalid BedGeometry date');
    }

    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(5, 7));
    final day = int.parse(value.substring(8, 10));
    final date = DateTime.utc(year, month, day);

    if (year < 1 ||
        date.year != year ||
        date.month != month ||
        date.day != day) {
      throw const FormatException('Invalid BedGeometry date');
    }

    return date;
  }
}
