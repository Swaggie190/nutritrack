import '../../data/models/meal.dart';
import '../../data/reposotories/meal_repository.dart';

class MealService {
  final MealRepository _mealRepository;

  MealService(this._mealRepository);

  // Add a new meal
  Future<void> addMeal({
    required String userId,
    required String name,
    required int calories,
    String? notes,
  }) async {
    try {
      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // or use UUID
        userId: userId,
        name: name,
        calories: calories,
        consumedAt: DateTime.now(),
        notes: notes,
      );

      await _mealRepository.addMeal(meal);
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  Future<bool> userHasMeals(String userId) async {
    try {
      final meals = await _mealRepository.getUserMeals(userId);

      return meals.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get all meals for a user
  Future<List<Meal>> getUserMeals(String userId) async {
    try {
      return await _mealRepository.getUserMeals(userId);
    } catch (e) {
      throw Exception('Failed to get user meals: $e');
    }
  }

  Stream<List<Meal>> getUserMealsStream(String userId) {
    return _mealRepository.getUserMealsStream(userId).handleError((error) {
      print(error);
      throw Exception('Failed to get user meals: $error');
    });
  }

  // Update existing meal
  Future<void> updateMeal(Meal meal) async {
    try {
      await _mealRepository.updateMeal(meal);
    } catch (e) {
      throw Exception('Failed to update meal: $e');
    }
  }

  // Delete meal
  Future<void> deleteMeal(String mealId) async {
    try {
      await _mealRepository.deleteMeal(mealId);
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  // Get calories for specific date
  Future<int> getCaloriesForDate(String userId, DateTime date) async {
    try {
      return await _mealRepository.getTotalCaloriesForDay(userId, date);
    } catch (e) {
      throw Exception('Failed to get calories for date: $e');
    }
  }

  // Get calories for date range (weekly/monthly)
  Future<Map<DateTime, int>> getCaloriesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final meals = await _mealRepository.getUserMeals(userId);
      Map<DateTime, int> caloriesByDate = {};

      for (var date = startDate;
          date.isBefore(endDate.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
        final dayMeals = meals.where((meal) =>
            meal.consumedAt.year == date.year &&
            meal.consumedAt.month == date.month &&
            meal.consumedAt.day == date.day);

        caloriesByDate[date] =
            dayMeals.fold(0, (sum, meal) => sum + meal.calories);
      }

      return caloriesByDate;
    } catch (e) {
      throw Exception('Failed to get calories for date range: $e');
    }
  }

  // Get average daily calories for a week
  Future<double> getWeeklyAverageCalories(String userId) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime weekAgo = now.subtract(const Duration(days: 7));

      final caloriesByDate =
          await getCaloriesForDateRange(userId, weekAgo, now);
      final totalCalories =
          caloriesByDate.values.fold(0, (sum, calories) => sum + calories);

      return totalCalories / 7;
    } catch (e) {
      throw Exception('Failed to get weekly average calories: $e');
    }
  }

  // Get meals by type (breakfast, lunch, dinner, snack)
  Future<List<Meal>> getMealsByType(String userId, String mealType) async {
    try {
      final meals = await getUserMeals(userId);
      return meals
          .where((meal) =>
              meal.name.toLowerCase().contains(mealType.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get meals by type: $e');
    }
  }

  // Check if user exceeded daily calorie goal
  Future<bool> hasExceededDailyGoal(String userId, int dailyGoal) async {
    try {
      final today = DateTime.now();
      final totalCalories = await getCaloriesForDate(userId, today);
      return totalCalories > dailyGoal;
    } catch (e) {
      throw Exception('Failed to check daily calorie goal: $e');
    }
  }

  // Get meal statistics for visualization
  Future<Map<String, dynamic>> getMealStatistics(String userId) async {
    try {
      final meals = await getUserMeals(userId);
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Today's meals
      final todayMeals = meals.where((meal) =>
          meal.consumedAt.isAfter(startOfDay) ||
          meal.consumedAt.isAtSameMomentAs(startOfDay));

      // Calculate statistics
      return {
        'totalMeals': meals.length,
        'todayMeals': todayMeals.length,
        'todayCalories': todayMeals.fold(0, (sum, meal) => sum + meal.calories),
        'averageCaloriesPerMeal': meals.isEmpty
            ? 0
            : meals.fold(0, (sum, meal) => sum + meal.calories) / meals.length,
      };
    } catch (e) {
      throw Exception('Failed to get meal statistics: $e');
    }
  }
}
