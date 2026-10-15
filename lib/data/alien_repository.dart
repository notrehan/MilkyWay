import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/alien_profile.dart';

class AlienRepository {
  AlienRepository(this._client);

  final SupabaseClient _client;

  Future<List<AlienProfile>> loadAliens() async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Please log in again.');

    // Find this account's own profile ID too, so it can never appear in discovery.
    final ownProfile = await _client
        .from('profiles')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    final ownProfileId = ownProfile?['id'] as String?;

    final rows = await _client
        .from('profiles')
        .select('id, user_id, profile_type, name, age, bio, photo_url, species, home_planet, created_at')
        .eq('profile_type', 'alien')
        .order('created_at');

    return (rows as List)
        .where((row) => row['id'] != ownProfileId && row['user_id'] != user.id)
        .map((row) => AlienProfile.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }
}
