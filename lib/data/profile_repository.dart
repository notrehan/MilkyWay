import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/human_profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;
  static const table = 'profiles';
  static const photoBucket = 'profile-photos';

  Future<HumanProfile?> loadMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final row = await _client
        .from(table)
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (row == null) return null;
    return HumanProfile.fromSupabase(row);
  }

  Future<HumanProfile> saveMyProfile(
    HumanProfile profile, {
    XFile? newPhoto,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Please log in again.');

    var photoUrl = profile.photoUrl;
    if (newPhoto != null) {
      final bytes = await newPhoto.readAsBytes();
      final extension = _extension(newPhoto.name);
      final objectPath = '${user.id}/${DateTime.now().microsecondsSinceEpoch}.$extension';
      await _client.storage.from(photoBucket).uploadBinary(
            objectPath,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: false,
              contentType: _contentType(extension),
            ),
          );
      photoUrl = _client.storage.from(photoBucket).getPublicUrl(objectPath);
    }

    final data = profile.toSupabaseMap(userId: user.id, photoUrl: photoUrl);
    await _client.from(table).upsert(data, onConflict: 'user_id');

    return HumanProfile(
      name: profile.name,
      age: profile.age,
      bio: profile.bio,
      photoUrl: photoUrl,
      breathingGas: profile.breathingGas,
      minPressure: profile.minPressure,
      maxPressure: profile.maxPressure,
      minTemperature: profile.minTemperature,
      maxTemperature: profile.maxTemperature,
      minGravity: profile.minGravity,
      maxGravity: profile.maxGravity,
      needsLiquidWater: profile.needsLiquidWater,
      canUseLifeSupport: profile.canUseLifeSupport,
      preferredClimate: profile.preferredClimate,
    );
  }

  String _extension(String name) {
    final dot = name.lastIndexOf('.');
    final ext = dot == -1 ? 'jpg' : name.substring(dot + 1).toLowerCase();
    return const {'jpg', 'jpeg', 'png', 'webp', 'heic'}.contains(ext) ? ext : 'jpg';
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png': return 'image/png';
      case 'webp': return 'image/webp';
      case 'heic': return 'image/heic';
      default: return 'image/jpeg';
    }
  }
}
