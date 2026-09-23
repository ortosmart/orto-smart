class CatalogCapabilities {
  final bool canManageIdentity;
  final bool canIngest;
  final bool canReview;
  final bool canPublish;
  final int? rowVersion;

  const CatalogCapabilities({
    required this.canManageIdentity,
    required this.canIngest,
    required this.canReview,
    required this.canPublish,
    required this.rowVersion,
  });

  factory CatalogCapabilities.fromMap(Map<String, dynamic> map) {
    if (map['status'] != 'ok') {
      throw const FormatException('Invalid CatalogCapabilities response');
    }

    return CatalogCapabilities(
      canManageIdentity: _requiredBool(map, 'can_manage_identity'),
      canIngest: _requiredBool(map, 'can_ingest'),
      canReview: _requiredBool(map, 'can_review'),
      canPublish: _requiredBool(map, 'can_publish'),
      rowVersion: _optionalPositiveInt(map, 'row_version'),
    );
  }

  static bool _requiredBool(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! bool) {
      throw const FormatException('Invalid CatalogCapabilities response');
    }
    return value;
  }

  static int? _optionalPositiveInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is! int || value < 1) {
      throw const FormatException('Invalid CatalogCapabilities response');
    }
    return value;
  }
}

enum ClaimInitialCatalogAuthorityStatus {
  claimed,
  alreadyInitialized,
  alreadyClaimed,
  forbidden,
}
