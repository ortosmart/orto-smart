class Planting {
  static const allowedStartMethods = {
    'purchased_seedlings',
    'nursery_then_transplant',
    'direct_rows',
    'direct_broadcast',
  };

  static const allowedStatuses = {
    'sown',
    'growing',
    'harvest_ready',
    'harvested',
    'finished',
    'removed',
  };

  final String id;
  final String profileId;
  final String gardenId;
  final String seasonId;
  final String bedId;
  final String cropId;
  final String? cultivarId;

  final String startMethod;
  final DateTime startDate;
  final DateTime? endDate;

  final int startPositionCm;
  final int lengthCm;

  final int? plantSpacingCm;
  final int? rowSpacingCm;
  final int? rowsCount;
  final int occupiedWidthCm;

  final int? plantsCount;
  final double? seedQuantityG;

  final String status;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;
  final int rowVersion;

  const Planting({
    required this.id,
    required this.profileId,
    required this.gardenId,
    required this.seasonId,
    required this.bedId,
    required this.cropId,
    required this.cultivarId,
    required this.startMethod,
    required this.startDate,
    required this.endDate,
    required this.startPositionCm,
    required this.lengthCm,
    required this.plantSpacingCm,
    required this.rowSpacingCm,
    required this.rowsCount,
    required this.occupiedWidthCm,
    required this.plantsCount,
    required this.seedQuantityG,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
  });

  factory Planting.fromMap(Map<String, dynamic> map) {
    final id = _requiredNonEmptyString(map, 'id');
    final profileId = _requiredNonEmptyString(map, 'profile_id');
    final gardenId = _requiredNonEmptyString(map, 'garden_id');
    final seasonId = _requiredNonEmptyString(map, 'season_id');
    final bedId = _requiredNonEmptyString(map, 'bed_id');
    final cropId = _requiredNonEmptyString(map, 'crop_id');

    final startMethod = _requiredNonEmptyString(map, 'start_method');
    final status = _requiredNonEmptyString(map, 'status');

    final startDate = _requiredDate(map, 'start_date');
    final endDate = _nullableDate(map, 'end_date');

    final startPositionCm = _requiredInteger(map, 'start_position_cm');
    final lengthCm = _requiredInteger(map, 'length_cm');
    final occupiedWidthCm = _requiredInteger(map, 'occupied_width_cm');
    final rowVersion = _requiredInteger(map, 'row_version');

    final plantSpacingCm = _nullableInteger(map, 'plant_spacing_cm');
    final rowSpacingCm = _nullableInteger(map, 'row_spacing_cm');
    final rowsCount = _nullableInteger(map, 'rows_count');
    final plantsCount = _nullableInteger(map, 'plants_count');
    final seedQuantityG = _nullableNumber(map, 'seed_quantity_g');

    if (!allowedStartMethods.contains(startMethod) ||
        !allowedStatuses.contains(status) ||
        startPositionCm < 0 ||
        lengthCm <= 0 ||
        occupiedWidthCm <= 0 ||
        rowVersion < 1 ||
        (plantSpacingCm != null && plantSpacingCm <= 0) ||
        (rowSpacingCm != null && rowSpacingCm <= 0) ||
        (rowsCount != null && rowsCount <= 0) ||
        (plantsCount != null && plantsCount <= 0) ||
        (seedQuantityG != null && seedQuantityG <= 0) ||
        (endDate != null && endDate.isBefore(startDate))) {
      throw const FormatException('Invalid Planting response');
    }

    final terminal = status == 'finished' || status == 'removed';

    if ((terminal && endDate == null) || (!terminal && endDate != null)) {
      throw const FormatException('Invalid Planting lifecycle response');
    }

    return Planting(
      id: id,
      profileId: profileId,
      gardenId: gardenId,
      seasonId: seasonId,
      bedId: bedId,
      cropId: cropId,
      cultivarId: _nullableNonEmptyString(map, 'cultivar_id'),
      startMethod: startMethod,
      startDate: startDate,
      endDate: endDate,
      startPositionCm: startPositionCm,
      lengthCm: lengthCm,
      plantSpacingCm: plantSpacingCm,
      rowSpacingCm: rowSpacingCm,
      rowsCount: rowsCount,
      occupiedWidthCm: occupiedWidthCm,
      plantsCount: plantsCount,
      seedQuantityG: seedQuantityG,
      status: status,
      notes: _nullableNonEmptyString(map, 'notes'),
      createdAt: _requiredDateTime(map, 'created_at'),
      updatedAt: _requiredDateTime(map, 'updated_at'),
      rowVersion: rowVersion,
    );
  }

  static String _requiredNonEmptyString(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid Planting response');
    }

    return value;
  }

  static String? _nullableNonEmptyString(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value == null) {
      return null;
    }

    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid Planting response');
    }

    return value;
  }

  static int _requiredInteger(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is! int) {
      throw const FormatException('Invalid Planting response');
    }

    return value;
  }

  static int? _nullableInteger(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value == null) {
      return null;
    }

    if (value is! int) {
      throw const FormatException('Invalid Planting response');
    }

    return value;
  }

  static double? _nullableNumber(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value == null) {
      return null;
    }

    if (value is! num) {
      throw const FormatException('Invalid Planting response');
    }

    return value.toDouble();
  }

  static DateTime _requiredDate(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw const FormatException('Invalid Planting response');
    }

    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(5, 7));
    final day = int.parse(value.substring(8, 10));
    final date = DateTime.utc(year, month, day);

    if (year < 1 ||
        date.year != year ||
        date.month != month ||
        date.day != day) {
      throw const FormatException('Invalid Planting response');
    }

    return date;
  }

  static DateTime? _nullableDate(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) {
      throw const FormatException('Invalid Planting response');
    }

    if (map[key] == null) {
      return null;
    }

    return _requiredDate(map, key);
  }

  static DateTime _requiredDateTime(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is! String) {
      throw const FormatException('Invalid Planting response');
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const FormatException('Invalid Planting response');
    }

    return parsed.toUtc();
  }
}
