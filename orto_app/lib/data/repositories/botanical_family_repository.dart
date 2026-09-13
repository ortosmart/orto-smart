import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/botanical_family_write_result.dart';
import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';
import '../models/botanical_family.dart';

typedef BotanicalFamilyListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef BotanicalFamilyWriteAuthorityProvider = ProfileEditLockLease Function();

typedef BotanicalFamilyRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class BotanicalFamilyRepository {
  final BotanicalFamilyListLoader _loadFamilies;
  final BotanicalFamilyRpcInvoker _invokeRpc;
  final BotanicalFamilyWriteAuthorityProvider? _requireLeaseForWrite;

  factory BotanicalFamilyRepository({
    SupabaseClient? supabase,
    BotanicalFamilyWriteAuthorityProvider? requireLeaseForWrite,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return BotanicalFamilyRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('botanical_families').select();

        if (activeOnly) {
          query = query.eq('is_active', true);
        }

        query = query.order('name');

        final response = await query;

        return (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
      requireLeaseForWrite,
    );
  }

  BotanicalFamilyRepository.withProviders(
    this._loadFamilies,
    this._invokeRpc, [
    this._requireLeaseForWrite,
  ]);

  Future<List<BotanicalFamily>> getBotanicalFamilies({
    bool activeOnly = true,
  }) async {
    final response = await _loadFamilies(activeOnly: activeOnly);

    return response.map(BotanicalFamily.fromMap).toList();
  }

  Future<CreateBotanicalFamilyResult> createBotanicalFamily({
    required String name,
    String? scientificName,
    String? description,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('create_botanical_family', {
      'target_profile_id': lease.profileId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'family_name': name,
      'family_scientific_name': scientificName,
      'family_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => BotanicalFamilyCreated(
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        name: _requiredNonEmptyString(payload, 'name'),
        scientificName: _optionalString(payload, 'scientific_name'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateBotanicalFamilyForbidden(),
      'write_forbidden' => const CreateBotanicalFamilyWriteForbidden(),
      'invalid_input' => const CreateBotanicalFamilyInvalidInput(),
      'duplicate_name' => const CreateBotanicalFamilyDuplicateName(),
      'duplicate_scientific_name' =>
        const CreateBotanicalFamilyDuplicateScientificName(),
      _ => throw const BotanicalFamilyWriteProtocolException(),
    };
  }

  Future<UpdateBotanicalFamilyResult> updateBotanicalFamily({
    required String botanicalFamilyId,
    required int expectedRowVersion,
    required String name,
    String? scientificName,
    String? description,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('update_botanical_family', {
      'target_profile_id': lease.profileId,
      'target_botanical_family_id': botanicalFamilyId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'family_name': name,
      'family_scientific_name': scientificName,
      'family_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => BotanicalFamilyUpdated(
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        name: _requiredNonEmptyString(payload, 'name'),
        scientificName: _optionalString(payload, 'scientific_name'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateBotanicalFamilyUnchanged(
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => UpdateBotanicalFamilyVersionConflict(
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
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
      'forbidden' => const UpdateBotanicalFamilyForbidden(),
      'write_forbidden' => const UpdateBotanicalFamilyWriteForbidden(),
      'not_found' => const UpdateBotanicalFamilyNotFound(),
      'invalid_input' => const UpdateBotanicalFamilyInvalidInput(),
      'duplicate_name' => const UpdateBotanicalFamilyDuplicateName(),
      'duplicate_scientific_name' =>
        const UpdateBotanicalFamilyDuplicateScientificName(),
      _ => throw const BotanicalFamilyWriteProtocolException(),
    };
  }

  Future<SetBotanicalFamilyActiveResult> setBotanicalFamilyActive({
    required String botanicalFamilyId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final lease = _requireWriteLease();

    final response = await _invokeRpc('set_botanical_family_active', {
      'target_profile_id': lease.profileId,
      'target_botanical_family_id': botanicalFamilyId,
      'expected_row_version': expectedRowVersion,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'family_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => BotanicalFamilyActiveUpdated(
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        profileId: _requiredNonEmptyString(payload, 'profile_id'),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetBotanicalFamilyActiveUnchanged(
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => SetBotanicalFamilyActiveVersionConflict(
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
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
      'forbidden' => const SetBotanicalFamilyActiveForbidden(),
      'write_forbidden' => const SetBotanicalFamilyActiveWriteForbidden(),
      'not_found' => const SetBotanicalFamilyActiveNotFound(),
      'invalid_input' => const SetBotanicalFamilyActiveInvalidInput(),
      'blocked_by_active_crops' => SetBotanicalFamilyActiveBlockedByActiveCrops(
        botanicalFamilyId: _requiredNonEmptyString(
          payload,
          'botanical_family_id',
        ),
        activeCrops: _activeCropReferences(payload),
      ),
      _ => throw const BotanicalFamilyWriteProtocolException(),
    };
  }

  ProfileEditLockLease _requireWriteLease() {
    final provider = _requireLeaseForWrite;

    if (provider == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    return provider();
  }

  List<ActiveCropReference> _activeCropReferences(
    Map<String, dynamic> payload,
  ) {
    final value = payload['active_crops'];

    if (value is! List) {
      throw const BotanicalFamilyWriteProtocolException();
    }

    return value
        .map((item) {
          if (item is! Map) {
            throw const BotanicalFamilyWriteProtocolException();
          }

          final map = Map<String, dynamic>.from(item);

          return ActiveCropReference(
            cropId: _requiredNonEmptyString(map, 'crop_id'),
            name: _requiredNonEmptyString(map, 'name'),
          );
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const BotanicalFamilyWriteProtocolException();
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const BotanicalFamilyWriteProtocolException();
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const BotanicalFamilyWriteProtocolException();
    }

    return value;
  }

  String? _optionalString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw const BotanicalFamilyWriteProtocolException();
    }

    return value;
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const BotanicalFamilyWriteProtocolException();
    }

    return value;
  }

  bool _requiredBoolean(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const BotanicalFamilyWriteProtocolException();
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const BotanicalFamilyWriteProtocolException();
    }

    final parsedValue = DateTime.tryParse(value);

    if (parsedValue == null) {
      throw const BotanicalFamilyWriteProtocolException();
    }

    return parsedValue.toUtc();
  }
}
