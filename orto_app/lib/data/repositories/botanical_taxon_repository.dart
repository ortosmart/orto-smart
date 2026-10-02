import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/write_authority/botanical_taxon_write_result.dart';
import '../models/botanical_taxon.dart';

typedef BotanicalTaxonListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

typedef BotanicalTaxonRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class BotanicalTaxonRepository {
  final BotanicalTaxonListLoader _loadTaxa;
  final BotanicalTaxonRpcInvoker _invokeRpc;

  factory BotanicalTaxonRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        dynamic query = client.from('botanical_taxa').select();

        if (activeOnly) {
          query = query.eq('is_active', true);
        }

        final response = await query.order('scientific_name');

        return (response as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      },
      (functionName, parameters) {
        return client.rpc(functionName, params: parameters);
      },
    );
  }

  BotanicalTaxonRepository.withProviders(this._loadTaxa, this._invokeRpc);

  Future<List<BotanicalTaxon>> getTaxa({bool activeOnly = true}) async {
    final response = await _loadTaxa(activeOnly: activeOnly);
    return response.map(BotanicalTaxon.fromMap).toList();
  }

  Future<CreateBotanicalTaxonResult> createTaxon({
    String? parentTaxonId,
    required String rank,
    required String scientificName,
    String? authorship,
    required bool isHybrid,
    String? description,
  }) async {
    final response = await _invokeRpc('create_botanical_taxon', {
      'target_parent_taxon_id': parentTaxonId,
      'taxon_rank': rank,
      'taxon_scientific_name': scientificName,
      'taxon_authorship': authorship,
      'taxon_is_hybrid': isHybrid,
      'taxon_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'created' => BotanicalTaxonCreated(
        botanicalTaxonId: _requiredNonEmptyString(
          payload,
          'botanical_taxon_id',
        ),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        createdAt: _requiredDateTime(payload, 'created_at'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'forbidden' => const CreateBotanicalTaxonForbidden(),
      'invalid_input' => const CreateBotanicalTaxonInvalidInput(),
      'parent_not_found' => const CreateBotanicalTaxonParentNotFound(),
      'dependency_inactive' => const CreateBotanicalTaxonDependencyInactive(),
      'duplicate_identity' => const CreateBotanicalTaxonDuplicateIdentity(),
      _ => throw const BotanicalTaxonWriteProtocolException(),
    };
  }

  Future<UpdateBotanicalTaxonResult> updateTaxon({
    required String botanicalTaxonId,
    required int expectedRowVersion,
    String? parentTaxonId,
    required String rank,
    required String scientificName,
    String? authorship,
    required bool isHybrid,
    String? description,
  }) async {
    final response = await _invokeRpc('update_botanical_taxon', {
      'target_botanical_taxon_id': botanicalTaxonId,
      'expected_row_version': expectedRowVersion,
      'target_parent_taxon_id': parentTaxonId,
      'taxon_rank': rank,
      'taxon_scientific_name': scientificName,
      'taxon_authorship': authorship,
      'taxon_is_hybrid': isHybrid,
      'taxon_description': description,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'updated' => BotanicalTaxonUpdated(
        botanicalTaxonId: _requiredNonEmptyString(
          payload,
          'botanical_taxon_id',
        ),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => UpdateBotanicalTaxonUnchanged(
        botanicalTaxonId: _requiredNonEmptyString(
          payload,
          'botanical_taxon_id',
        ),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => UpdateBotanicalTaxonVersionConflict(
        botanicalTaxonId: _requiredNonEmptyString(
          payload,
          'botanical_taxon_id',
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
      'forbidden' => const UpdateBotanicalTaxonForbidden(),
      'invalid_input' => const UpdateBotanicalTaxonInvalidInput(),
      'not_found' => const UpdateBotanicalTaxonNotFound(),
      'parent_not_found' => const UpdateBotanicalTaxonParentNotFound(),
      'dependency_inactive' => const UpdateBotanicalTaxonDependencyInactive(),
      'duplicate_identity' => const UpdateBotanicalTaxonDuplicateIdentity(),
      _ => throw const BotanicalTaxonWriteProtocolException(),
    };
  }

  Future<SetBotanicalTaxonActiveResult> setTaxonActive({
    required String botanicalTaxonId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    final response = await _invokeRpc('set_botanical_taxon_active', {
      'target_botanical_taxon_id': botanicalTaxonId,
      'expected_row_version': expectedRowVersion,
      'taxon_is_active': isActive,
    });

    final payload = _responseMap(response);

    return switch (payload['status']) {
      'active_changed' => BotanicalTaxonActiveChanged(
        botanicalTaxonId: _requiredNonEmptyString(
          payload,
          'botanical_taxon_id',
        ),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'unchanged' => SetBotanicalTaxonActiveUnchanged(
        botanicalTaxonId: _requiredNonEmptyString(
          payload,
          'botanical_taxon_id',
        ),
        isActive: _requiredBoolean(payload, 'is_active'),
        rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        updatedAt: _requiredDateTime(payload, 'updated_at'),
      ),
      'version_conflict' => _versionConflict(payload),
      'forbidden' => const SetBotanicalTaxonActiveForbidden(),
      'invalid_input' => const SetBotanicalTaxonActiveInvalidInput(),
      'not_found' => const SetBotanicalTaxonActiveNotFound(),
      'dependency_inactive' =>
        const SetBotanicalTaxonActiveDependencyInactive(),
      'active_dependents' => SetBotanicalTaxonActiveDependents(
        activeChildTaxaCount: _requiredNonNegativeInteger(
          payload,
          'active_child_taxa_count',
        ),
        activeCropsCount: _requiredNonNegativeInteger(
          payload,
          'active_crops_count',
        ),
      ),
      _ => throw const BotanicalTaxonWriteProtocolException(),
    };
  }

  SetBotanicalTaxonActiveVersionConflict _versionConflict(
    Map<String, dynamic> payload,
  ) {
    const detailKeys = [
      'botanical_taxon_id',
      'expected_row_version',
      'current_row_version',
      'updated_at',
    ];

    final hasAnyDetail = detailKeys.any(payload.containsKey);

    if (!hasAnyDetail) {
      return const SetBotanicalTaxonActiveVersionConflict();
    }

    if (!detailKeys.every(payload.containsKey)) {
      throw const BotanicalTaxonWriteProtocolException();
    }

    return SetBotanicalTaxonActiveVersionConflict(
      botanicalTaxonId: _requiredNonEmptyString(payload, 'botanical_taxon_id'),
      expectedRowVersion: _requiredPositiveInteger(
        payload,
        'expected_row_version',
      ),
      currentRowVersion: _requiredPositiveInteger(
        payload,
        'current_row_version',
      ),
      updatedAt: _requiredDateTime(payload, 'updated_at'),
    );
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const BotanicalTaxonWriteProtocolException();
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const BotanicalTaxonWriteProtocolException();
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const BotanicalTaxonWriteProtocolException();
    }

    return value;
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const BotanicalTaxonWriteProtocolException();
    }

    return value;
  }

  int _requiredNonNegativeInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 0) {
      throw const BotanicalTaxonWriteProtocolException();
    }

    return value;
  }

  bool _requiredBoolean(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! bool) {
      throw const BotanicalTaxonWriteProtocolException();
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const BotanicalTaxonWriteProtocolException();
    }

    final parsedValue = DateTime.tryParse(value);

    if (parsedValue == null) {
      throw const BotanicalTaxonWriteProtocolException();
    }

    return parsedValue.toUtc();
  }
}
