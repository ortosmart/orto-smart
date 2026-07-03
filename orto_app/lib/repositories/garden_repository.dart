import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/garden.dart';

class GardenRepository {
  final _client = Supabase.instance.client;

  Future<Garden?> getGarden() async {
    final response = await _client
        .from('gardens')
        .select()
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return Garden.fromJson(response);
  }
}