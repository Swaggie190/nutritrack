enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  other;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      case MealType.other:
        return 'Other';
    }
  }
}

class Meal {
  final String id;
  final String userId;
  final String name;
  final int calories;
  final DateTime consumedAt;
  final String? notes;

  // Macronutrients (in grams)
  final double? protein;
  final double? carbs;
  final double? fats;

  // Meal metadata
  final MealType mealType;
  final double? servingSize;
  final String? servingUnit; // "oz", "g", "cups", etc.
  final String? photoUrl;
  final List<String>? tags;

  Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.consumedAt,
    this.notes,
    this.protein,
    this.carbs,
    this.fats,
    this.mealType = MealType.other,
    this.servingSize,
    this.servingUnit,
    this.photoUrl,
    this.tags,
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
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'mealType': mealType.name,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'photoUrl': photoUrl,
      'tags': tags,
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
      protein: map['protein']?.toDouble(),
      carbs: map['carbs']?.toDouble(),
      fats: map['fats']?.toDouble(),
      mealType: _parseMealType(map['mealType']),
      servingSize: map['servingSize']?.toDouble(),
      servingUnit: map['servingUnit'],
      photoUrl: map['photoUrl'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
    );
  }

  static MealType _parseMealType(dynamic value) {
    if (value == null) return MealType.other;
    if (value is String) {
      try {
        return MealType.values.firstWhere(
          (e) => e.name == value,
          orElse: () => MealType.other,
        );
      } catch (e) {
        return MealType.other;
      }
    }
    return MealType.other;
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
      protein: firestoreData['protein']?.toDouble(),
      carbs: firestoreData['carbs']?.toDouble(),
      fats: firestoreData['fats']?.toDouble(),
      mealType: _parseMealType(firestoreData['mealType']),
      servingSize: firestoreData['servingSize']?.toDouble(),
      servingUnit: firestoreData['servingUnit'],
      photoUrl: firestoreData['photoUrl'],
      tags: firestoreData['tags'] != null
          ? List<String>.from(firestoreData['tags'])
          : null,
    );
  }

  // Convert Meal to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'calories': calories,
      'consumedAt': consumedAt.toIso8601String(),
      'notes': notes,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'mealType': mealType.name,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'photoUrl': photoUrl,
      'tags': tags,
    };
  }

  // CopyWith method for creating modified copies
  Meal copyWith({
    String? id,
    String? userId,
    String? name,
    int? calories,
    DateTime? consumedAt,
    String? notes,
    double? protein,
    double? carbs,
    double? fats,
    MealType? mealType,
    double? servingSize,
    String? servingUnit,
    String? photoUrl,
    List<String>? tags,
  }) {
    return Meal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      consumedAt: consumedAt ?? this.consumedAt,
      notes: notes ?? this.notes,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      mealType: mealType ?? this.mealType,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      photoUrl: photoUrl ?? this.photoUrl,
      tags: tags ?? this.tags,
    );
  }
}
