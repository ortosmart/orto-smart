import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/garden_write_result.dart';
import '../../core/write_authority/profile_edit_lock.dart';
import '../../core/write_authority/profile_write_authority_controller.dart';
import '../models/garden.dart';

typedef GardensLoader =
    Future<List<Map<String, dynamic>>> Function(String profileId);

typedef GardenWriteAuthorityProvider = ProfileEditLockLease Function();

typedef GardenRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class GardenRepository {
  final GardensLoader _loadGardens;
  final GardenRpcInvoker? _invokeRpc;
  final GardenWriteAuthorityProvider? _requireLeaseForWrite;

  factory GardenRepository({
    SupabaseClient? supabase,
    GardenWriteAuthorityProvider? requireLeaseForWrite,
  }) {
    final client = supabase ?? Supabase.instance.client;

    return GardenRepository.withProviders(
      (profileId) async {
        final response = await client
            .from('gardens')
            .select('id,profile_id,name,description,is_active,row_version')
            .eq('profile_id', profileId)
            .order('name', ascending: true, nullsFirst: false)
            .order('id', ascending: true, nullsFirst: false);

        return response.map((row) => Map<String, dynamic>.from(row)).toList();
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
      requireLeaseForWrite,
    );
  }

  GardenRepository.withLoader(this._loadGardens)
    : _invokeRpc = null,
      _requireLeaseForWrite = null;

  GardenRepository.withProviders(
    this._loadGardens,
    this._invokeRpc,
    this._requireLeaseForWrite,
  );

  Future<List<Garden>> getGardens({required String profileId}) async {
    if (profileId.trim().isEmpty) {
      throw ArgumentError.value(
        profileId,
        'profileId',
        'Profile ID must not be empty',
      );
    }

    final response = await _loadGardens(profileId);
    final gardens = response.map(Garden.fromJson).toList();

    if (gardens.any((garden) => garden.profileId != profileId)) {
      throw const FormatException(
        'Garden does not belong to the requested Profile',
      );
    }

    return gardens;
  }

  Future<CreateGardenResult> createGarden({
    required String profileId,
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    int? elevationM,
    required String timezone,
    required String countryCode,
    String? municipality,
    String? locality,
    String? streetAddress,
  }) async {
    final provider = _requireLeaseForWrite;
    if (provider == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    final lease = provider();
    if (profileId.trim().isEmpty || lease.profileId != profileId) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    final invokeRpc = _invokeRpc;
    if (invokeRpc == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    final response = await invokeRpc('create_garden', {
      'target_profile_id': lease.profileId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
      'garden_name': name,
      'garden_description': description,
      'garden_latitude': latitude,
      'garden_longitude': longitude,
      'garden_elevation_m': elevationM,
      'garden_timezone': timezone,
      'garden_country_code': countryCode,
      'garden_municipality': municipality,
      'garden_locality': locality,
      'garden_street_address': streetAddress,
    });

    if (response is! Map) {
      throw const GardenWriteProtocolException();
    }

    late final Map<String, dynamic> payload;
    try {
      payload = Map<String, dynamic>.from(response);
    } on Object {
      throw const GardenWriteProtocolException();
    }

    return switch (payload['status']) {
      'created' => GardenCreated(
        gardenId: _requiredGardenString(payload, 'garden_id'),
        rowVersion: _requiredGardenVersion(payload, 'row_version'),
        createdAt: _requiredGardenDateTime(payload, 'created_at'),
      ),
      'forbidden' => const CreateGardenForbidden(),
      'write_forbidden' => const CreateGardenWriteForbidden(),
      'invalid_input' => const CreateGardenInvalidInput(),
      'duplicate_name' => const CreateGardenDuplicateName(),
      _ => throw const GardenWriteProtocolException(),
    };
  }

  String _requiredGardenString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is! String || value.trim().isEmpty) {
      throw const GardenWriteProtocolException();
    }
    return value;
  }

  int _requiredGardenVersion(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is! int || value < 1) {
      throw const GardenWriteProtocolException();
    }
    return value;
  }

  DateTime _requiredGardenDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is! String) {
      throw const GardenWriteProtocolException();
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw const GardenWriteProtocolException();
    }
    return parsed;
  }
}
