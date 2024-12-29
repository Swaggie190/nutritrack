class HealthProfile {
  final String id;
  final String userId;
  final double bmi;
  final String bmiCategory;
  final List<String> dietaryRestrictions;
  final List<String> healthGoals;
  final DateTime updatedAt;

  HealthProfile({
    required this.id,
    required this.userId,
    required this.bmi,
    required this.bmiCategory,
    this.dietaryRestrictions = const [],
    this.healthGoals = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'dietaryRestrictions': dietaryRestrictions,
      'healthGoals': healthGoals,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    return HealthProfile(
      id: map['id'],
      userId: map['userId'],
      bmi: map['bmi'],
      bmiCategory: map['bmiCategory'],
      dietaryRestrictions: List<String>.from(map['dietaryRestrictions']),
      healthGoals: List<String>.from(map['healthGoals']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
