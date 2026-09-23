import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/crop_cultivar.dart';

typedef CropCultivarListLoader =
    Future<List<Map<String, dynamic>>> Function({
      String? cropId,
      bool activeOnly,
    });

class CropCultivarRepository {
  final CropCultivarListLoader _loadCultivars;

  factory CropCultivarRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return CropCultivarRepository.withLoader(({
      String? cropId,
      bool activeOnly = true,
    }) async {
      dynamic query = client.from('crop_cultivar_catalog_read').select();
      if (cropId != null) query = query.eq('crop_id', cropId);
      if (activeOnly) query = query.eq('is_active', true);

      final response = await query.order('crop_id').order('canonical_name');
      return (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    });
  }

  CropCultivarRepository.withLoader(this._loadCultivars);

  Future<List<CropCultivar>> getCultivarsByCrop(
    String cropId, {
    bool activeOnly = true,
  }) async {
    final response = await _loadCultivars(
      cropId: cropId,
      activeOnly: activeOnly,
    );
    return response.map(CropCultivar.fromMap).toList();
  }

  Future<List<CropCultivar>> getAllCultivars({bool activeOnly = true}) async {
    final response = await _loadCultivars(cropId: null, activeOnly: activeOnly);
    return response.map(CropCultivar.fromMap).toList();
  }
}
