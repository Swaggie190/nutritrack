import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutritrack/data/models/meal.dart';

class MealRepository {
  final FirebaseFirestore _firestore;

  MealRepository(this._firestore);

  Future<void> addMeal(Meal meal) async {
    try {
      await _firestore.collection('meals').doc(meal.id).set(meal.toMap());
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  Future<List<Meal>> getUserMeals(String userId) async {
    try {
      print(userId);
      final querySnapshot = await _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .orderBy('consumedAt', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => Meal.fromMap(doc.data())).toList();
    } catch (e) {
      print("sorri");
      print(e);
      throw Exception('Failed to get user meals: $e');
    }
  }

  Future<void> updateMeal(Meal meal) async {
    try {
      await _firestore.collection('meals').doc(meal.id).update(meal.toMap());
    } catch (e) {
      throw Exception('Failed to update meal: $e');
    }
  }

  Future<void> deleteMeal(String id) async {
    try {
      await _firestore.collection('meals').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  Future<int> getTotalCaloriesForDay(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('meals')
          .where('userId', isEqualTo: userId)
          .where('consumedAt',
              isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('consumedAt', isLessThan: endOfDay.toIso8601String())
          .get();

      final meals =
          querySnapshot.docs.map((doc) => Meal.fromMap(doc.data())).toList();
      return meals.fold<int>(0, (sum, meal) => sum + meal.calories);
    } catch (e) {
      throw Exception('Failed to get total calories: $e');
    }
  }
}
