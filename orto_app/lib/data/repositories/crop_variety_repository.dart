import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/crop_variety.dart';

class CropVarietyRepository {
  final _client = Supabase.instance.client;

  Future<List<CropVariety>> getVarietiesByCrop(int cropId) async {
    final response = await _client
        .from('crop_varieties')
        .select()
        .eq('crop_id', cropId)
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((e) => CropVariety.fromMap(e))
        .toList();
  }

  Future<List<CropVariety>> getAllVarieties() async {
    final response = await _client
        .from('crop_varieties')
        .select()
        .eq('is_active', true)
        .order('crop_id')
        .order('name');

    return (response as List)
        .map((e) => CropVariety.fromMap(e))
        .toList();
  }
}