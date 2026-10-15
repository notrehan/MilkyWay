class HumanProfile {
  final String name;
  final int age;
  final String bio;
  final String? photoPath;
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
    this.photoPath,
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'bio': bio,
        'photoPath': photoPath,
        'breathingGas': breathingGas,
        'minPressure': minPressure,
        'maxPressure': maxPressure,
        'minTemperature': minTemperature,
        'maxTemperature': maxTemperature,
        'minGravity': minGravity,
        'maxGravity': maxGravity,
        'needsLiquidWater': needsLiquidWater,
        'canUseLifeSupport': canUseLifeSupport,
        'preferredClimate': preferredClimate,
      };
}
