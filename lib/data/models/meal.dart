class Meal {
  final String id;
  final String userId;
  final String name;
  final int calories;
  final DateTime consumedAt;
  final String? notes;

  Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.consumedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'calories': calories,
      'consumedAt': consumedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      calories: map['calories'],
      consumedAt: DateTime.parse(map['consumedAt']),
      notes: map['notes'],
    );
  }
}
