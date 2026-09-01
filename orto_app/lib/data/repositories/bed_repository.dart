import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/bed_write_result.dart';
import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';
import '../models/bed.dart';

typedef BedsLoader =
    Future<List<Map<String, dynamic>>> Function(String gardenId);

typedef BedLoader =
    Future<Map<String, dynamic>?> Function(String gardenId, String bedId);

typedef BedWriteAuthorityProvider = ProfileEditLockLease Function();

typedef BedRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class BedRepository {
  final BedsLoader _loadBeds;
  final BedLoader? _loadBed;
  final BedRpcInvoker? _invokeRpc;
  final BedWriteAuthorityProvider? _requireLeaseForWrite;

  factory BedRepository({
    SupabaseClient? supabase,
    BedWriteAuthorityProvider? requireLeaseForWrite,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return BedRepository.withProviders(
      (gardenId) async {
        final response = await client
            .from('beds')
            .select('''
              id,
              garden_id,
              number,
              name,
              notes,
              is_active,
              row_version,
              bed_geometries (
                id,
                bed_id,
                width_cm,
                length_cm,
                valid_from,
                valid_to,
                row_version
              )
            ''')
            .eq('garden_id', gardenId)
            .eq('is_active', true)
            .isFilter('bed_geometries.valid_to', null)
            .order('number', ascending: true, nullsFirst: false);

        return response.map((row) => Map<String, dynamic>.from(row)).toList();
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
      requireLeaseForWrite,
      (gardenId, bedId) async {
        final response = await client
            .from('beds')
            .select('''
              id,
              garden_id,
              number,
              name,
              notes,
              is_active,
              row_version,
              bed_geometries (
                id,
                bed_id,
                width_cm,
                length_cm,
                valid_from,
                valid_to,
                row_version
              )
            ''')
            .eq('garden_id', gardenId)
            .eq('id', bedId)
            .isFilter('bed_geometries.valid_to', null);

        if (response.isEmpty) {
          return null;
        }

        if (response.length != 1) {
          throw const FormatException('Expected a single Bed response');
        }

        return Map<String, dynamic>.from(response.single);
      },
    );
  }

  BedRepository.withLoader(this._loadBeds, [this._loadBed])
    : _invokeRpc = null,
      _requireLeaseForWrite = null;

  BedRepository.withProviders(
    this._loadBeds,
    this._invokeRpc, [
    this._requireLeaseForWrite,
    this._loadBed,
  ]);

  Future<List<Bed>> getBeds({required String gardenId}) async {
    if (gardenId.trim().isEmpty) {
      throw ArgumentError.value(
        gardenId,
        'gardenId',
        'Garden ID must not be empty',
      );
    }

    final response = await _loadBeds(gardenId);
    final beds = response.map(Bed.fromMap).toList();

    if (beds.any((bed) => bed.gardenId != gardenId)) {
      throw const FormatException(
        'Bed does not belong to the requested Garden',
      );
    }

    return beds;
  }

  Future<Bed?> getBed({required String gardenId, required String bedId}) async {
    if (gardenId.trim().isEmpty) {
      throw ArgumentError.value(
        gardenId,
        'gardenId',
        'Garden ID must not be empty',
      );
    }

    if (bedId.trim().isEmpty) {
      throw ArgumentError.value(bedId, 'bedId', 'Bed ID must not be empty');
    }

    final loadBed = _loadBed;

    if (loadBed == null) {
      throw StateError('Single Bed loader is not configured');
    }

    final response = await loadBed(gardenId, bedId);

    if (response == null) {
      return null;
    }

    final bed = Bed.fromMap(response);

    if (bed.id != bedId || bed.gardenId != gardenId) {
      throw const FormatException(
        'Bed does not match the requested Bed and Garden',
      );
    }

    return bed;
  }

  Future<CreateBedResult> createBed({
    required String gardenId,
    required int number,
    String? name,
    String? notes,
    required int widthCm,
    required int lengthCm,
    DateTime? validFrom,
  }) async {
    final lease = _requireWriteLease();
    final invokeRpc = _invokeRpc;

    if (invokeRpc == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    final response = await invokeRpc('create_bed', {
      'target_profile_id': lease.profileId,
      'target_garden_id': gardenId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'bed_number': number,
      'bed_name': name,
      'bed_notes': notes,
      'geometry_width_cm': widthCm,
      'geometry_length_cm': lengthCm,
      'geometry_valid_from': validFrom == null ? null : _dateOnly(validFrom),
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => _createdBed(payload),
      'forbidden' => const CreateBedForbidden(),
      'write_forbidden' => const CreateBedWriteForbidden(),
      'not_found' => const CreateBedNotFound(),
      'invalid_input' => const CreateBedInvalidInput(),
      'duplicate_number' => const CreateBedDuplicateNumber(),
      _ => throw const BedWriteProtocolException(),
    };
  }

  Future<UpdateBedResult> updateBed({
    required String bedId,
    required int expectedRowVersion,
    required int number,
    String? name,
    String? notes,
  }) async {
    final lease = _requireWriteLease();
    final invokeRpc = _invokeRpc;

    if (invokeRpc == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    final response = await invokeRpc('update_bed', {
      'target_profile_id': lease.profileId,
      'target_bed_id': bedId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'bed_number': number,
      'bed_name': name,
      'bed_notes': notes,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => BedUpdated(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        number: _requiredPositiveInteger(payload, 'number'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateBedUnchanged(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => UpdateBedVersionConflict(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        expectedRowVersion: _requiredPositiveInteger(
          payload,
          'expected_row_version',
        ),
        currentRowVersion: _requiredPositiveInteger(
          payload,
          'current_row_version',
        ),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'forbidden' => const UpdateBedForbidden(),
      'write_forbidden' => const UpdateBedWriteForbidden(),
      'not_found' => const UpdateBedNotFound(),
      'invalid_input' => const UpdateBedInvalidInput(),
      'duplicate_number' => const UpdateBedDuplicateNumber(),
      _ => throw const BedWriteProtocolException(),
    };
  }

  Future<SetBedActiveResult> setBedActive({
    required String bedId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final lease = _requireWriteLease();
    final invokeRpc = _invokeRpc;

    if (invokeRpc == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    final response = await invokeRpc('set_bed_active', {
      'target_profile_id': lease.profileId,
      'target_bed_id': bedId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'bed_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => BedActiveUpdated(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetBedActiveUnchanged(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => SetBedActiveVersionConflict(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        expectedRowVersion: _requiredPositiveInteger(
          payload,
          'expected_row_version',
        ),
        currentRowVersion: _requiredPositiveInteger(
          payload,
          'current_row_version',
        ),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'forbidden' => const SetBedActiveForbidden(),
      'write_forbidden' => const SetBedActiveWriteForbidden(),
      'not_found' => const SetBedActiveNotFound(),
      'invalid_input' => const SetBedActiveInvalidInput(),
      _ => throw const BedWriteProtocolException(),
    };
  }

  Future<ChangeBedGeometryResult> changeBedGeometry({
    required String bedId,
    required int expectedRowVersion,
    required int widthCm,
    required int lengthCm,
    required DateTime validFrom,
  }) async {
    final lease = _requireWriteLease();
    final invokeRpc = _invokeRpc;

    if (invokeRpc == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    final response = await invokeRpc('change_bed_geometry', {
      'target_profile_id': lease.profileId,
      'target_bed_id': bedId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'geometry_width_cm': widthCm,
      'geometry_length_cm': lengthCm,
      'geometry_valid_from': _dateOnly(validFrom),
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'changed' => _changedBedGeometry(payload),
      'unchanged' => ChangeBedGeometryUnchanged(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
        geometryId: _requiredNonEmptyString(payload, 'geometry_id'),
        geometryRowVersion: _requiredPositiveInteger(
          payload,
          'geometry_row_version',
        ),
        geometryUpdatedAt: _requiredDateTime(payload, 'geometry_updated_at'),
      ),
      'correction_required' => BedGeometryCorrectionRequired(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
        geometryId: _requiredNonEmptyString(payload, 'geometry_id'),
        geometryRowVersion: _requiredPositiveInteger(
          payload,
          'geometry_row_version',
        ),
        geometryUpdatedAt: _requiredDateTime(payload, 'geometry_updated_at'),
      ),
      'version_conflict' => ChangeBedGeometryVersionConflict(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        expectedRowVersion: _requiredPositiveInteger(
          payload,
          'expected_row_version',
        ),
        currentRowVersion: _requiredPositiveInteger(
          payload,
          'current_row_version',
        ),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'forbidden' => const ChangeBedGeometryForbidden(),
      'write_forbidden' => const ChangeBedGeometryWriteForbidden(),
      'not_found' => const ChangeBedGeometryNotFound(),
      'invalid_input' => const ChangeBedGeometryInvalidInput(),
      _ => throw const BedWriteProtocolException(),
    };
  }

  BedGeometryChanged _changedBedGeometry(Map<String, dynamic> payload) {
    final geometryId = _requiredNonEmptyString(payload, 'geometry_id');
    final validFrom = _requiredDate(payload, 'valid_from');
    final validTo = _requiredNullableDate(payload, 'valid_to');
    final previousGeometry = _requiredPreviousGeometry(payload);

    if ((validTo != null && !validTo.isAfter(validFrom)) ||
        previousGeometry.validTo != validFrom ||
        previousGeometry.geometryId == geometryId) {
      throw const BedWriteProtocolException();
    }

    return BedGeometryChanged(
      bedId: _requiredNonEmptyString(payload, 'bed_id'),
      gardenId: _requiredNonEmptyString(payload, 'garden_id'),
      rowVersion: _requiredPositiveInteger(payload, 'row_version'),
      updatedAt: _requiredDateTime(payload, 'updated_at'),
      geometryId: geometryId,
      widthCm: _requiredPositiveInteger(payload, 'width_cm'),
      lengthCm: _requiredPositiveInteger(payload, 'length_cm'),
      validFrom: validFrom,
      validTo: validTo,
      geometryRowVersion: _requiredPositiveInteger(
        payload,
        'geometry_row_version',
      ),
      geometryCreatedAt: _requiredDateTime(payload, 'geometry_created_at'),
      previousGeometry: previousGeometry,
    );
  }

  PreviousBedGeometry _requiredPreviousGeometry(Map<String, dynamic> payload) {
    return PreviousBedGeometry(
      geometryId: _requiredNonEmptyString(payload, 'previous_geometry_id'),
      validTo: _requiredDate(payload, 'previous_geometry_valid_to'),
      rowVersion: _requiredPositiveInteger(
        payload,
        'previous_geometry_row_version',
      ),
      updatedAt: _requiredDateTime(payload, 'previous_geometry_updated_at'),
    );
  }

  DateTime? _requiredNullableDate(Map<String, dynamic> payload, String key) {
    if (!payload.containsKey(key)) {
      throw const BedWriteProtocolException();
    }

    if (payload[key] == null) {
      return null;
    }

    return _requiredDate(payload, key);
  }

  Future<CorrectBedGeometryResult> correctBedGeometry({
    required String bedId,
    required String geometryId,
    required int expectedRowVersion,
    required int widthCm,
    required int lengthCm,
    required DateTime validFrom,
    required String reason,
  }) async {
    final lease = _requireWriteLease();
    final invokeRpc = _invokeRpc;

    if (invokeRpc == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    final response = await invokeRpc('correct_bed_geometry', {
      'target_profile_id': lease.profileId,
      'target_bed_id': bedId,
      'target_geometry_id': geometryId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'geometry_width_cm': widthCm,
      'geometry_length_cm': lengthCm,
      'geometry_valid_from': _dateOnly(validFrom),
      'correction_reason': reason,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'corrected' => _correctedBedGeometry(payload),
      'unchanged' => CorrectBedGeometryUnchanged(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        gardenId: _requiredNonEmptyString(payload, 'garden_id'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
        geometryId: _requiredNonEmptyString(payload, 'geometry_id'),
        geometryRowVersion: _requiredPositiveInteger(
          payload,
          'geometry_row_version',
        ),
        geometryUpdatedAt: _requiredDateTime(payload, 'geometry_updated_at'),
      ),
      'version_conflict' => CorrectBedGeometryVersionConflict(
        bedId: _requiredNonEmptyString(payload, 'bed_id'),
        expectedRowVersion: _requiredPositiveInteger(
          payload,
          'expected_row_version',
        ),
        currentRowVersion: _requiredPositiveInteger(
          payload,
          'current_row_version',
        ),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'forbidden' => const CorrectBedGeometryForbidden(),
      'write_forbidden' => const CorrectBedGeometryWriteForbidden(),
      'not_found' => const CorrectBedGeometryNotFound(),
      'invalid_input' => const CorrectBedGeometryInvalidInput(),
      _ => throw const BedWriteProtocolException(),
    };
  }

  BedGeometryCorrected _correctedBedGeometry(Map<String, dynamic> payload) {
    final geometryId = _requiredNonEmptyString(payload, 'geometry_id');
    final validFrom = _requiredDate(payload, 'valid_from');
    final validTo = _requiredNullableDate(payload, 'valid_to');
    final previousGeometry = _optionalPreviousGeometry(payload);

    if (validTo != null && !validTo.isAfter(validFrom)) {
      throw const BedWriteProtocolException();
    }

    if (previousGeometry != null &&
        (previousGeometry.validTo != validFrom ||
            previousGeometry.geometryId == geometryId)) {
      throw const BedWriteProtocolException();
    }

    return BedGeometryCorrected(
      bedId: _requiredNonEmptyString(payload, 'bed_id'),
      gardenId: _requiredNonEmptyString(payload, 'garden_id'),
      rowVersion: _requiredPositiveInteger(payload, 'row_version'),
      updatedAt: _requiredDateTime(payload, 'updated_at'),
      geometryId: geometryId,
      widthCm: _requiredPositiveInteger(payload, 'width_cm'),
      lengthCm: _requiredPositiveInteger(payload, 'length_cm'),
      validFrom: validFrom,
      validTo: validTo,
      geometryRowVersion: _requiredPositiveInteger(
        payload,
        'geometry_row_version',
      ),
      geometryUpdatedAt: _requiredDateTime(payload, 'geometry_updated_at'),
      correctionId: _requiredNonEmptyString(payload, 'correction_id'),
      correctionCreatedAt: _requiredDateTime(payload, 'correction_created_at'),
      previousGeometry: previousGeometry,
    );
  }

  PreviousBedGeometry? _optionalPreviousGeometry(Map<String, dynamic> payload) {
    const keys = [
      'previous_geometry_id',
      'previous_geometry_valid_to',
      'previous_geometry_row_version',
      'previous_geometry_updated_at',
    ];

    if (!keys.any(payload.containsKey)) {
      return null;
    }

    if (!keys.every(payload.containsKey)) {
      throw const BedWriteProtocolException();
    }

    return _requiredPreviousGeometry(payload);
  }

  ProfileEditLockLease _requireWriteLease() {
    final provider = _requireLeaseForWrite;

    if (provider == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    return provider();
  }

  BedCreated _createdBed(Map<String, dynamic> payload) {
    if (payload['is_active'] != true ||
        !payload.containsKey('valid_to') ||
        payload['valid_to'] != null) {
      throw const BedWriteProtocolException();
    }

    return BedCreated(
      bedId: _requiredNonEmptyString(payload, 'bed_id'),
      gardenId: _requiredNonEmptyString(payload, 'garden_id'),
      number: _requiredPositiveInteger(payload, 'number'),
      isActive: true,
      rowVersion: _requiredPositiveInteger(payload, 'row_version'),
      createdAt: _requiredDateTime(payload, 'created_at'),
      geometryId: _requiredNonEmptyString(payload, 'geometry_id'),
      widthCm: _requiredPositiveInteger(payload, 'width_cm'),
      lengthCm: _requiredPositiveInteger(payload, 'length_cm'),
      validFrom: _requiredDate(payload, 'valid_from'),
      validTo: null,
      geometryRowVersion: _requiredPositiveInteger(
        payload,
        'geometry_row_version',
      ),
      geometryCreatedAt: _requiredDateTime(payload, 'geometry_created_at'),
    );
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const BedWriteProtocolException();
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const BedWriteProtocolException();
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const BedWriteProtocolException();
    }

    return value;
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const BedWriteProtocolException();
    }

    return value;
  }

  bool _requiredBoolean(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const BedWriteProtocolException();
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const BedWriteProtocolException();
    }

    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      throw const BedWriteProtocolException();
    }

    return parsed.toUtc();
  }

  DateTime _requiredDate(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      throw const BedWriteProtocolException();
    }

    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(5, 7));
    final day = int.parse(value.substring(8, 10));
    final date = DateTime.utc(year, month, day);

    if (year < 1 ||
        date.year != year ||
        date.month != month ||
        date.day != day) {
      throw const BedWriteProtocolException();
    }

    return date;
  }

  String _dateOnly(DateTime value) {
    if (value.year < 1 || value.year > 9999) {
      throw ArgumentError.value(value, 'value', 'Unsupported civil date');
    }

    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
