import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/catalog_capabilities.dart';

typedef CatalogRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class CatalogAuthorityRepository {
  final CatalogRpcInvoker _invokeRpc;

  factory CatalogAuthorityRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;
    return CatalogAuthorityRepository.withInvoker(
      (functionName, parameters) =>
          client.rpc(functionName, params: parameters),
    );
  }

  CatalogAuthorityRepository.withInvoker(this._invokeRpc);

  Future<CatalogCapabilities> getMyCapabilities() async {
    final response = await _invokeRpc('get_my_catalog_capabilities', const {});
    return CatalogCapabilities.fromMap(_responseMap(response));
  }

  Future<ClaimInitialCatalogAuthorityStatus> claimInitialAuthority() async {
    final response = await _invokeRpc(
      'claim_initial_catalog_authority',
      const {},
    );
    final payload = _responseMap(response);

    return switch (payload['status']) {
      'claimed' => ClaimInitialCatalogAuthorityStatus.claimed,
      'already_initialized' =>
        ClaimInitialCatalogAuthorityStatus.alreadyInitialized,
      'already_claimed' => ClaimInitialCatalogAuthorityStatus.alreadyClaimed,
      'forbidden' => ClaimInitialCatalogAuthorityStatus.forbidden,
      _ => throw const FormatException('Invalid catalog authority response'),
    };
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const FormatException('Invalid catalog authority response');
    }
    return Map<String, dynamic>.from(response);
  }
}
