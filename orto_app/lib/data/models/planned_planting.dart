class PlannedPlanting {
  static const allowedStartMethods = {
    'purchased_seedlings',
    'nursery_then_transplant',
    'direct_rows',
    'direct_broadcast',
  };

  static const allowedStatuses = {
    'draft',
    'confirmed',
    'executed',
    'cancelled',
  };

  final String id;
  final String seasonPlanId;
  final String profileId;
  final String gardenId;
  final String seasonId;
  final String bedId;
  final String cropId;
  final String? cultivarId;

  final String startMethod;
  final DateTime plannedStartDate;
  final DateTime? plannedEndDate;

  final int startPositionCm;
  final int lengthCm;
  final int occupiedWidthCm;
  final int? plantSpacingCm;
  final int? rowSpacingCm;
  final int? rowsCount;
  final int? plantsCount;
  final double? seedQuantityG;

  final String status;
  final String? executedPlantingId;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;
  final int rowVersion;

  const PlannedPlanting({
    required this.id,
    required this.seasonPlanId,
    required this.profileId,
    required this.gardenId,
    required this.seasonId,
    required this.bedId,
    required this.cropId,
    required this.cultivarId,
    required this.startMethod,
    required this.plannedStartDate,
    required this.plannedEndDate,
    required this.startPositionCm,
    required this.lengthCm,
    required this.occupiedWidthCm,
    required this.plantSpacingCm,
    required this.rowSpacingCm,
    required this.rowsCount,
    required this.plantsCount,
    required this.seedQuantityG,
    required this.status,
    required this.executedPlantingId,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.rowVersion,
  });

  factory PlannedPlanting.fromMap(Map<String, dynamic> map) {
    final id = _requiredString(map, 'id');
    final seasonPlanId = _requiredString(map, 'season_plan_id');
    final profileId = _requiredString(map, 'profile_id');
    final gardenId = _requiredString(map, 'garden_id');
    final seasonId = _requiredString(map, 'season_id');
    final bedId = _requiredString(map, 'bed_id');
    final cropId = _requiredString(map, 'crop_id');
    final cultivarId = _nullableString(map, 'cultivar_id');

    final startMethod = _requiredString(map, 'start_method');
    final plannedStartDate = _requiredDate(map, 'planned_start_date');
    final plannedEndDate = _nullableDate(map, 'planned_end_date');

    final startPositionCm = _requiredInt(map, 'start_position_cm');
    final lengthCm = _requiredInt(map, 'length_cm');
    final occupiedWidthCm = _requiredInt(map, 'occupied_width_cm');
    final plantSpacingCm = _nullableInt(map, 'plant_spacing_cm');
    final rowSpacingCm = _nullableInt(map, 'row_spacing_cm');
    final rowsCount = _nullableInt(map, 'rows_count');
    final plantsCount = _nullableInt(map, 'plants_count');
    final seedQuantityG = _nullableNumber(map, 'seed_quantity_g');

    final status = _requiredString(map, 'status');
    final executedPlantingId = _nullableString(map, 'executed_planting_id');
    final notes = _nullableString(map, 'notes');
    final createdAt = _requiredTimestamp(map, 'created_at');
    final updatedAt = _requiredTimestamp(map, 'updated_at');
    final rowVersion = _requiredInt(map, 'row_version');

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
        (plannedEndDate != null && plannedEndDate.isBefore(plannedStartDate))) {
      throw const FormatException('Invalid PlannedPlanting response');
    }

    if ((status == 'executed') != (executedPlantingId != null)) {
      throw const FormatException('Invalid PlannedPlanting lifecycle response');
    }

    return PlannedPlanting(
      id: id,
      seasonPlanId: seasonPlanId,
      profileId: profileId,
      gardenId: gardenId,
      seasonId: seasonId,
      bedId: bedId,
      cropId: cropId,
      cultivarId: cultivarId,
      startMethod: startMethod,
      plannedStartDate: plannedStartDate,
      plannedEndDate: plannedEndDate,
      startPositionCm: startPositionCm,
      lengthCm: lengthCm,
      occupiedWidthCm: occupiedWidthCm,
      plantSpacingCm: plantSpacingCm,
      rowSpacingCm: rowSpacingCm,
      rowsCount: rowsCount,
      plantsCount: plantsCount,
      seedQuantityG: seedQuantityG,
      status: status,
      executedPlantingId: executedPlantingId,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      rowVersion: rowVersion,
    );
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    return value;
  }

  static String? _nullableString(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    final value = map[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    return value;
  }

  static int _requiredInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! int) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    return value;
  }

  static int? _nullableInt(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    final value = map[key];
    if (value == null) return null;
    if (value is! int) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    return value;
  }

  static double? _nullableNumber(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    final value = map[key];
    if (value == null) return null;
    if (value is! num) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    return value.toDouble();
  }

  static DateTime _requiredDate(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw const FormatException('Invalid PlannedPlanting response');
    }

    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(5, 7));
    final day = int.parse(value.substring(8, 10));
    final date = DateTime.utc(year, month, day);

    if (year < 1 ||
        date.year != year ||
        date.month != month ||
        date.day != day) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    return date;
  }

  static DateTime? _nullableDate(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    if (map[key] == null) return null;
    return _requiredDate(map, key);
  }

  static DateTime _requiredTimestamp(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw const FormatException('Invalid PlannedPlanting response');
    }
    return parsed.toUtc();
  }
}
