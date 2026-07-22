import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/crop_association.dart';

class CropAssociationRepository {
  final SupabaseClient _client;

  CropAssociationRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<CropAssociation>> getAssociationsForCrop(
    String cropId,
  ) async {
    final response = await _client
        .from('crop_associations')
        .select()
        .eq('crop_id', cropId)
        .order('score', ascending: false);

    return (response as List<dynamic>)
        .map(
          (item) => CropAssociation.fromMap(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<CropAssociation>> getAssociationsBetweenCrops(
    String cropId,
    Iterable<String> associatedCropIds,
  ) async {
    final ids = associatedCropIds.toSet().toList();

    if (ids.isEmpty) {
      return const [];
    }

    final response = await _client
        .from('crop_associations')
        .select()
        .eq('crop_id', cropId)
        .inFilter('associated_crop_id', ids)
        .order('score', ascending: false);

    return (response as List<dynamic>)
        .map(
          (item) => CropAssociation.fromMap(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<CropAssociation>> getAllAssociations() async {
    final response = await _client
        .from('crop_associations')
        .select()
        .order('crop_id')
        .order('score', ascending: false);

    return (response as List<dynamic>)
        .map(
          (item) => CropAssociation.fromMap(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}