class Planting {
  final String? id;
  final String seasonId;
  final String bedId;
  final String cropId;
  final String? varietyId;

  // Posizione nell'aiuola
  final int startPositionCm;
  final int lengthCm;

  // Nuovi dati di coltivazione
  final String plantingMethod;
  final int? plantSpacingCm;
  final int? rowSpacingCm;
  final int? rowsCount;
  final int? occupiedWidthCm;
  final double? seedQuantityGrams;

  final DateTime sowingDate;
  final int? plantsCount;
  final String status;
  final String? notes;

  const Planting({
    this.id,
    required this.seasonId,
    required this.bedId,
    required this.cropId,
    this.varietyId,
    required this.startPositionCm,
    required this.lengthCm,

    this.plantingMethod = 'transplant',
    this.plantSpacingCm,
    this.rowSpacingCm,
    this.rowsCount,
    this.occupiedWidthCm,
    this.seedQuantityGrams,

    required this.sowingDate,
    this.plantsCount,
    required this.status,
    this.notes,
  });

  factory Planting.fromMap(Map<String, dynamic> map) {
    return Planting(
      id: map['id']?.toString(),
      seasonId: map['season_id'].toString(),
      bedId: map['bed_id'].toString(),
      cropId: map['crop_id'].toString(),
      varietyId: map['variety_id']?.toString(),

      startPositionCm: map['start_position_cm'] as int? ?? 0,
      lengthCm: map['length_cm'] as int? ?? 700,

      plantingMethod:
          map['planting_method'] as String? ?? 'transplant',

      plantSpacingCm: map['plant_spacing_cm'] as int?,
      rowSpacingCm: map['row_spacing_cm'] as int?,
      rowsCount: map['rows_count'] as int?,
      occupiedWidthCm: map['occupied_width_cm'] as int?,

      seedQuantityGrams:
          (map['seed_quantity_grams'] as num?)?.toDouble(),

      sowingDate: DateTime.parse(
        map['sowing_date'] as String,
      ),

      plantsCount: map['plants_count'] as int?,
      status: map['status'] as String? ?? 'growing',
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,

      'season_id': seasonId,
      'bed_id': bedId,
      'crop_id': cropId,
      'variety_id': varietyId,

      'start_position_cm': startPositionCm,
      'length_cm': lengthCm,

      'planting_method': plantingMethod,
      'plant_spacing_cm': plantSpacingCm,
      'row_spacing_cm': rowSpacingCm,
      'rows_count': rowsCount,
      'occupied_width_cm': occupiedWidthCm,
      'seed_quantity_grams': seedQuantityGrams,

      'sowing_date': _formatDate(sowingDate),
      'plants_count': plantsCount,
      'status': status,
      'notes': notes,
    };
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}