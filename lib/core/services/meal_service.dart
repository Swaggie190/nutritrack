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
    double? protein,
    double? carbs,
    double? fats,
    MealType? mealType,
    double? servingSize,
    String? servingUnit,
    String? photoUrl,
    List<String>? tags,
    DateTime? consumedAt,
  }) async {
    try {
      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: name,
        calories: calories,
        consumedAt: consumedAt ?? DateTime.now(),
        notes: notes,
        protein: protein,
        carbs: carbs,
        fats: fats,
        mealType: mealType ?? MealType.other,
        servingSize: servingSize,
        servingUnit: servingUnit,
        photoUrl: photoUrl,
        tags: tags,
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
  Future<List<Meal>> getMealsByType(String userId, MealType mealType) async {
    try {
      final meals = await getUserMeals(userId);
      return meals.where((meal) => meal.mealType == mealType).toList();
    } catch (e) {
      throw Exception('Failed to get meals by type: $e');
    }
  }

  // Get macronutrient statistics for a specific date
  Future<Map<String, double>> getMacroStatistics(
      String userId, DateTime date) async {
    try {
      final meals = await getUserMeals(userId);
      final dayMeals = meals.where((meal) =>
          meal.consumedAt.year == date.year &&
          meal.consumedAt.month == date.month &&
          meal.consumedAt.day == date.day);

      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFats = 0;

      for (var meal in dayMeals) {
        totalProtein += meal.protein ?? 0;
        totalCarbs += meal.carbs ?? 0;
        totalFats += meal.fats ?? 0;
      }

      return {
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fats': totalFats,
      };
    } catch (e) {
      throw Exception('Failed to get macro statistics: $e');
    }
  }

  // Get meal type distribution (count and calories by meal type)
  Future<Map<String, Map<String, int>>> getMealTypeDistribution(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final meals = await getUserMeals(userId);
      final filteredMeals = meals.where((meal) =>
          meal.consumedAt
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          meal.consumedAt.isBefore(endDate.add(const Duration(days: 1))));

      Map<String, Map<String, int>> distribution = {};

      for (var mealType in MealType.values) {
        final typeMeals =
            filteredMeals.where((meal) => meal.mealType == mealType);
        distribution[mealType.displayName] = {
          'count': typeMeals.length,
          'calories': typeMeals.fold(0, (sum, meal) => sum + meal.calories),
        };
      }

      return distribution;
    } catch (e) {
      throw Exception('Failed to get meal type distribution: $e');
    }
  }

  // Get nutritional breakdown for enhanced statistics
  Future<Map<String, dynamic>> getNutritionalBreakdown(
      String userId, DateTime date) async {
    try {
      final macros = await getMacroStatistics(userId, date);
      final calories = await getCaloriesForDate(userId, date);

      // Calculate calories from macros (if available)
      final proteinCals = (macros['protein'] ?? 0) * 4; // 4 cal/g
      final carbsCals = (macros['carbs'] ?? 0) * 4; // 4 cal/g
      final fatsCals = (macros['fats'] ?? 0) * 9; // 9 cal/g
      final totalMacroCals = proteinCals + carbsCals + fatsCals;

      return {
        'calories': calories,
        'protein': macros['protein'],
        'carbs': macros['carbs'],
        'fats': macros['fats'],
        'proteinPercentage':
            totalMacroCals > 0 ? (proteinCals / totalMacroCals * 100) : 0,
        'carbsPercentage':
            totalMacroCals > 0 ? (carbsCals / totalMacroCals * 100) : 0,
        'fatsPercentage':
            totalMacroCals > 0 ? (fatsCals / totalMacroCals * 100) : 0,
      };
    } catch (e) {
      throw Exception('Failed to get nutritional breakdown: $e');
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
