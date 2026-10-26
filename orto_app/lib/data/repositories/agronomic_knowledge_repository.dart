import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/agronomic_knowledge_result.dart';

typedef AgronomicKnowledgeRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

final class AgronomicKnowledgeRepository {
  final AgronomicKnowledgeRpcInvoker _invokeRpc;

  factory AgronomicKnowledgeRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return AgronomicKnowledgeRepository.withRpcInvoker((
      functionName,
      parameters,
    ) {
      return client.rpc(functionName, params: parameters);
    });
  }

  AgronomicKnowledgeRepository.withRpcInvoker(this._invokeRpc);

  Future<AgronomicKnowledgeResult> resolve(
    AgronomicKnowledgeRequest request,
  ) async {
    final response = await _invokeRpc('resolve_agronomic_knowledge', {
      'target_parameter_id': request.parameterId,
      'target_crop_id': request.cropId,
      'target_cultivar_id': request.cultivarId,
      'target_production_context_id': request.productionContextId,
      'target_protection_context_id': request.protectionContextId,
      'target_training_context_id': request.trainingContextId,
      'target_harvest_purpose_id': request.harvestPurposeId,
    });

    if (response is! Map) {
      throw const FormatException(
        'Agronomic knowledge RPC response is not a map',
      );
    }

    final Map<String, dynamic> payload;
    try {
      payload = Map<String, dynamic>.from(response);
    } on Object {
      throw const FormatException(
        'Agronomic knowledge RPC response contains invalid keys',
      );
    }

    final result = AgronomicKnowledgeResult.fromMap(payload);
    verifyAgronomicKnowledgeIdentity(request, result);

    return result;
  }
}
