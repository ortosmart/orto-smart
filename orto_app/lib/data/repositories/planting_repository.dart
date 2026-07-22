import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/planting.dart';

class PlantingRepository {
  final SupabaseClient _supabase;

  PlantingRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Planting>> getPlantingsByBed(String bedId) async {
    final response = await _supabase
        .from('plantings')
        .select()
        .eq('bed_id', bedId)
        .order('start_position_cm', ascending: true);

    return (response as List)
        .map(
          (item) => Planting.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<Planting> addPlanting(Planting planting) async {
    final data = planting.toMap()..remove('id');

    final response = await _supabase
        .from('plantings')
        .insert(data)
        .select()
        .single();

    return Planting.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  Future<Planting> updatePlanting(Planting planting) async {
    if (planting.id == null) {
      throw ArgumentError(
        'Non è possibile aggiornare una semina senza id.',
      );
    }

    final data = planting.toMap()..remove('id');

    final response = await _supabase
        .from('plantings')
        .update(data)
        .eq('id', planting.id!)
        .select()
        .single();

    return Planting.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  Future<void> deletePlanting(String id) async {
    await _supabase
        .from('plantings')
        .delete()
        .eq('id', id);
  }
}