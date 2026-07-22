import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/season.dart';

class SeasonRepository {
  final SupabaseClient _supabase;

  SeasonRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Season> getActiveSeason() async {
    final response = await _supabase
        .from('seasons')
        .select()
        .eq('is_active', true)
        .limit(1)
        .single();

    return Season.fromMap(
      Map<String, dynamic>.from(response),
    );
  }
}