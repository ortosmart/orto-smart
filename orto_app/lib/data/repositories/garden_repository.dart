import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/garden.dart';

typedef GardensLoader =
    Future<List<Map<String, dynamic>>> Function(String profileId);

class GardenRepository {
  final GardensLoader _loadGardens;

  factory GardenRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return GardenRepository.withLoader((profileId) async {
      final response = await client
          .from('gardens')
          .select('id,profile_id,name,description,is_active,row_version')
          .eq('profile_id', profileId)
          .order('name', ascending: true, nullsFirst: false)
          .order('id', ascending: true, nullsFirst: false);

      return response.map((row) => Map<String, dynamic>.from(row)).toList();
    });
  }

  GardenRepository.withLoader(this._loadGardens);

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
}
