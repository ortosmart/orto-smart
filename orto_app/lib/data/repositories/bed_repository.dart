import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/bed.dart';

class BedRepository {
  final _client = Supabase.instance.client;

  Future<List<Bed>> getBeds() async {
    final response = await _client
        .from('beds')
        .select()
        .eq('is_active', true)
        .order('number');

    return (response as List)
        .map((bed) => Bed.fromMap(bed))
        .toList();
  }
}