class HumanProfile {
  final String name;
  final int age;
  final String bio;
  /// A Supabase public URL after saving, or a local path while editing a legacy profile.
  final String? photoUrl;
  final String breathingGas;
  final double minPressure;
  final double maxPressure;
  final double minTemperature;
  final double maxTemperature;
  final double minGravity;
  final double maxGravity;
  final bool needsLiquidWater;
  final bool canUseLifeSupport;
  final String preferredClimate;

  const HumanProfile({
    required this.name,
    required this.age,
    required this.bio,
    this.photoUrl,
    required this.breathingGas,
    required this.minPressure,
    required this.maxPressure,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minGravity,
    required this.maxGravity,
    required this.needsLiquidWater,
    required this.canUseLifeSupport,
    required this.preferredClimate,
  });

  factory HumanProfile.fromSupabase(Map<String, dynamic> row) {
    return HumanProfile(
      name: row['name'] as String? ?? '',
      age: (row['age'] as num?)?.toInt() ?? 18,
      bio: row['bio'] as String? ?? '',
      photoUrl: row['photo_url'] as String?,
      breathingGas: row['breathing_gas'] as String? ?? 'Oxygen',
      minPressure: (row['min_pressure'] as num?)?.toDouble() ?? 0.8,
      maxPressure: (row['max_pressure'] as num?)?.toDouble() ?? 1.2,
      minTemperature: (row['min_temperature'] as num?)?.toDouble() ?? -10,
      maxTemperature: (row['max_temperature'] as num?)?.toDouble() ?? 40,
      minGravity: (row['min_gravity'] as num?)?.toDouble() ?? 0.7,
      maxGravity: (row['max_gravity'] as num?)?.toDouble() ?? 1.3,
      needsLiquidWater: row['needs_liquid_water'] as bool? ?? true,
      canUseLifeSupport: row['can_use_life_support'] as bool? ?? false,
      preferredClimate: row['preferred_climate'] as String? ?? 'Temperate',
    );
  }

  Map<String, dynamic> toSupabaseMap({
    required String userId,
    required String? photoUrl,
  }) => {
        'user_id': userId,
        'profile_type': 'human',
        'name': name,
        'age': age,
        'bio': bio,
        'photo_url': photoUrl,
        'breathing_gas': breathingGas,
        'min_pressure': minPressure,
        'max_pressure': maxPressure,
        'min_temperature': minTemperature,
        'max_temperature': maxTemperature,
        'min_gravity': minGravity,
        'max_gravity': maxGravity,
        'needs_liquid_water': needsLiquidWater,
        'can_use_life_support': canUseLifeSupport,
        'preferred_climate': preferredClimate,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
}
