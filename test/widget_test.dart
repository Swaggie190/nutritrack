// Basic Flutter widget test for NutriTrack
// Firebase-dependent tests should be in integration tests

import 'package:flutter_test/flutter_test.dart';
import 'package:nutritrack/data/models/meal.dart';

void main() {
  group('Meal Model Tests', () {
    test('Meal model should serialize and deserialize correctly', () {
      // Create a test meal
      final meal = Meal(
        id: 'test123',
        userId: 'user456',
        name: 'Test Meal',
        calories: 500,
        consumedAt: DateTime(2024, 4, 11, 12, 0),
        notes: 'Test notes',
        protein: 25.0,
        carbs: 50.0,
        fats: 15.0,
        mealType: MealType.lunch,
      );

      // Convert to map
      final map = meal.toMap();

      // Verify map contains correct values
      expect(map['id'], 'test123');
      expect(map['name'], 'Test Meal');
      expect(map['calories'], 500);
      expect(map['protein'], 25.0);
      expect(map['carbs'], 50.0);
      expect(map['fats'], 15.0);
      expect(map['mealType'], 'lunch');

      // Convert back from map
      final deserializedMeal = Meal.fromMap(map);

      // Verify deserialization
      expect(deserializedMeal.id, meal.id);
      expect(deserializedMeal.name, meal.name);
      expect(deserializedMeal.calories, meal.calories);
      expect(deserializedMeal.protein, meal.protein);
      expect(deserializedMeal.carbs, meal.carbs);
      expect(deserializedMeal.fats, meal.fats);
      expect(deserializedMeal.mealType, meal.mealType);
    });

    test('MealType enum should have correct display names', () {
      expect(MealType.breakfast.displayName, 'Breakfast');
      expect(MealType.lunch.displayName, 'Lunch');
      expect(MealType.dinner.displayName, 'Dinner');
      expect(MealType.snack.displayName, 'Snack');
      expect(MealType.other.displayName, 'Other');
    });

    test('Meal copyWith should work correctly', () {
      final originalMeal = Meal(
        id: 'test123',
        userId: 'user456',
        name: 'Original Meal',
        calories: 500,
        consumedAt: DateTime(2024, 4, 11),
        mealType: MealType.breakfast,
      );

      final updatedMeal = originalMeal.copyWith(
        name: 'Updated Meal',
        calories: 600,
      );

      expect(updatedMeal.id, originalMeal.id);
      expect(updatedMeal.name, 'Updated Meal');
      expect(updatedMeal.calories, 600);
      expect(updatedMeal.userId, originalMeal.userId);
      expect(updatedMeal.mealType, originalMeal.mealType);
    });

    test('Meal with null optional fields should serialize correctly', () {
      final meal = Meal(
        id: 'test123',
        userId: 'user456',
        name: 'Simple Meal',
        calories: 300,
        consumedAt: DateTime(2024, 4, 11),
        mealType: MealType.snack,
      );

      final map = meal.toMap();

      expect(map['protein'], null);
      expect(map['carbs'], null);
      expect(map['fats'], null);
      expect(map['notes'], null);
      expect(map['servingSize'], null);
      expect(map['servingUnit'], null);
      expect(map['photoUrl'], null);
      expect(map['tags'], null);
    });
  });
}
