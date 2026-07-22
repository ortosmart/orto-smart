import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/crop.dart';

class CropRepository {
  final SupabaseClient _supabase;

  CropRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Crop>> getCrops() async {
    final response = await _supabase
        .from('crops')
        .select()
        .order('name');

    return (response as List)
        .map(
          (item) => Crop.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}