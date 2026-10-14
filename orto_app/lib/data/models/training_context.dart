class TrainingContext {
  final String id;
  final String code;
  final String name;
  final String? description;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrainingContext({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrainingContext.fromMap(Map<String, dynamic> map) {
    return TrainingContext(
      id: _requiredString(map, 'id'),
      code: _requiredString(map, 'code'),
      name: _requiredString(map, 'name'),
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
      throw const FormatException('Invalid TrainingContext response');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Invalid TrainingContext response');
    }
    return value;
  }

  static bool _requiredBool(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! bool) {
      throw const FormatException('Invalid TrainingContext response');
    }
    return value;
  }

  static int _requiredPositiveInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! int || value < 1) {
      throw const FormatException('Invalid TrainingContext response');
    }
    return value;
  }

  static DateTime _requiredDateTime(Map<String, dynamic> map, String key) {
    final value = map[key];
    final parsed = value is String ? DateTime.tryParse(value) : null;
    if (parsed == null) {
      throw const FormatException('Invalid TrainingContext response');
    }
    return parsed.toUtc();
  }
}
