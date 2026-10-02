class BotanicalTaxon {
  final String id;
  final String? parentTaxonId;
  final String rank;
  final String scientificName;
  final String? authorship;
  final bool isHybrid;
  final String? description;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BotanicalTaxon({
    required this.id,
    required this.rank,
    required this.scientificName,
    required this.isHybrid,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
    this.parentTaxonId,
    this.authorship,
    this.description,
  });

  factory BotanicalTaxon.fromMap(Map<String, dynamic> map) {
    return BotanicalTaxon(
      id: _requiredString(map, 'id'),
      parentTaxonId: _optionalString(map, 'parent_taxon_id'),
      rank: _requiredString(map, 'rank'),
      scientificName: _requiredString(map, 'scientific_name'),
      authorship: _optionalString(map, 'authorship'),
      isHybrid: _requiredBool(map, 'is_hybrid'),
      description: _optionalString(map, 'description'),
      isActive: _requiredBool(map, 'is_active'),
      rowVersion: _requiredPositiveInt(map, 'row_version'),
      createdAt: _requiredDateTime(map, 'created_at'),
      updatedAt: _requiredDateTime(map, 'updated_at'),
    );
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid BotanicalTaxon response');
    }

    return value;
  }

  static String? _optionalString(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value == null) {
      return null;
    }

    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid BotanicalTaxon response');
    }

    return value;
  }

  static bool _requiredBool(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is! bool) {
      throw const FormatException('Invalid BotanicalTaxon response');
    }

    return value;
  }

  static int _requiredPositiveInt(Map<String, dynamic> map, String key) {
    final value = map[key];

    if (value is! int || value < 1) {
      throw const FormatException('Invalid BotanicalTaxon response');
    }

    return value;
  }

  static DateTime _requiredDateTime(Map<String, dynamic> map, String key) {
    final value = map[key];
    final parsed = value is String ? DateTime.tryParse(value) : null;

    if (parsed == null) {
      throw const FormatException('Invalid BotanicalTaxon response');
    }

    return parsed.toUtc();
  }
}
