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

  // Convert Meal to Map (for storing in Firestore)
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

  // Create a Meal from Map (Firestore-specific mapping)
  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      consumedAt: DateTime.parse(map['consumedAt']),
      notes: map['notes'],
    );
  }

  // Create a Meal from Firestore document (handles Firestore data retrieval)
  factory Meal.fromFirestore(Map<String, dynamic> firestoreData) {
    return Meal(
      id: firestoreData['id'] ?? '',
      userId: firestoreData['userId'] ?? '',
      name: firestoreData['name'] ?? '',
      calories: firestoreData['calories'] ?? 0,
      consumedAt: DateTime.parse(firestoreData['consumedAt']),
      notes: firestoreData['notes'],
    );
  }

  // Optional: Convert Meal to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'calories': calories,
      'consumedAt': consumedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
