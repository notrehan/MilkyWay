class AlienProfile {
  final String id;
  final String name;
  final int? age;
  final String bio;
  final String? photoUrl;
  final String? species;
  final String? homePlanet;

  const AlienProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photoUrl,
    required this.species,
    required this.homePlanet,
  });

  factory AlienProfile.fromSupabase(Map<String, dynamic> row) {
    return AlienProfile(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'Unknown alien',
      age: (row['age'] as num?)?.toInt(),
      bio: row['bio'] as String? ?? '',
      photoUrl: row['photo_url'] as String?,
      species: row['species'] as String?,
      homePlanet: row['home_planet'] as String?,
    );
  }
}
