class Planet {
  final String id;
  final String name;
  final String classification;
  final String image;
  final String description;
  final String climate;
  final String atmosphere;
  final double gravity;
  final double habitability;
  final List<String> pros;
  final List<String> cons;

  const Planet({
    required this.id,
    required this.name,
    required this.classification,
    required this.image,
    required this.description,
    required this.climate,
    required this.atmosphere,
    required this.gravity,
    required this.habitability,
    required this.pros,
    required this.cons,
  });

  factory Planet.fromSupabase(Map<String, dynamic> row) {
    List<String> stringList(dynamic value) {
      if (value is List) return value.map((item) => item.toString()).toList();
      return <String>[];
    }

    return Planet(
      id: row['id'].toString(),
      name: row['name'] as String? ?? 'Unknown Planet',
      classification: row['classification'] as String? ?? 'UNCLASSIFIED WORLD',
      image: row['image_url'] as String? ?? '',
      description: row['description'] as String? ?? '',
      climate: row['climate'] as String? ?? 'Unknown',
      atmosphere: row['atmosphere'] as String? ?? 'Unknown',
      gravity: (row['gravity'] as num?)?.toDouble() ?? 1.0,
      habitability: (row['habitability'] as num?)?.toDouble() ?? 0,
      pros: stringList(row['pros']),
      cons: stringList(row['cons']),
    );
  }
}
