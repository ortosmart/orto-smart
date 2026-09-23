import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/crop.dart';

typedef CropListLoader =
    Future<List<Map<String, dynamic>>> Function({bool activeOnly});

class CropRepository {
  final CropListLoader _loadCrops;

  factory CropRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return CropRepository.withLoader(({bool activeOnly = true}) async {
      dynamic query = client.from('crop_catalog_read').select();
      if (activeOnly) query = query.eq('is_active', true);

      final response = await query.order('canonical_name');
      return (response as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    });
  }

  CropRepository.withLoader(this._loadCrops);

  Future<List<Crop>> getCrops({bool activeOnly = true}) async {
    final response = await _loadCrops(activeOnly: activeOnly);
    return response.map(Crop.fromMap).toList();
  }
}
