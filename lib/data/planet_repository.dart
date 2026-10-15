import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/planet.dart';

class PlanetRepository {
  PlanetRepository(this._client);

  final SupabaseClient _client;

  Future<List<Planet>> loadPlanets() async {
    final rows = await _client
        .from('planets')
        .select('id, name, classification, image_url, description, climate, atmosphere, gravity, habitability, pros, cons')
        .order('sort_order')
        .order('name');

    return (rows as List)
        .map((row) => Planet.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }
}
