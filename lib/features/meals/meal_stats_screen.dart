import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/theme_constants.dart';
import '../../core/services/meal_service.dart';
import '../../core/services/auth_service.dart';

class MealStatisticsScreen extends StatelessWidget {
  const MealStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealService = Provider.of<MealService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Statistics'),
      ),
      body: StreamBuilder<String?>(
        stream: authService.authStateChanges,
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (authSnapshot.hasError) {
            return Center(
              child: Text('Authentication Error: ${authSnapshot.error}',
                  style: const TextStyle(color: ThemeConstants.errorColor)),
            );
          } else if (!authSnapshot.hasData || authSnapshot.data == null) {
            return const Center(child: Text('Not logged in'));
          } else {
            final userId = authSnapshot.data!;
            return _buildStatisticsBody(context, mealService, userId);
          }
        },
      ),
    );
  }

  Widget _buildStatisticsBody(
      BuildContext context, MealService mealService, String userId) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: mealService.getMealStatistics(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Statistics Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: ThemeConstants.errorColor)),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No meal statistics found'));
                } else {
                  final statistics = snapshot.data!;
                  return _buildStatisticsContent(statistics);
                }
              },
            ),
            const SizedBox(height: ThemeConstants.largePadding),
            const Divider(),
            const Text(
              'Calories by Date:',
              style: ThemeConstants.subheadingStyle,
            ),
            const SizedBox(height: ThemeConstants.smallPadding),
            FutureBuilder<Map<DateTime, int>>(
              future: mealService.getCaloriesForDateRange(
                userId,
                DateTime.now().subtract(const Duration(days: 7)),
                DateTime.now(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    'Calories by Date Error: ${snapshot.error}',
                    style: const TextStyle(color: ThemeConstants.errorColor),
                  );
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('No calorie data for this period.');
                } else {
                  final caloriesByDate = snapshot.data!;
                  return Column(
                    children: caloriesByDate.entries.map((entry) {
                      return Text(
                        '${entry.key.toLocal().toString().split(' ')[0]}: ${entry.value} kcal',
                        style: ThemeConstants.bodyStyle,
                      );
                    }).toList(),
                  );
                }
              },
            ),
            const SizedBox(height: ThemeConstants.defaultPadding),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back', style: ThemeConstants.bodyStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent(Map<String, dynamic> statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Meal Statistics',
          style: ThemeConstants.headingStyle,
        ),
        const SizedBox(height: ThemeConstants.defaultPadding),
        Text(
          'Total Meals: ${statistics['totalMeals'] ?? 0}', // Handle potential nulls
          style: ThemeConstants.bodyStyle,
        ),
        Text(
          'Today\'s Meals: ${statistics['todayMeals'] ?? 0}',
          style: ThemeConstants.bodyStyle,
        ),
        Text(
          'Today\'s Calories: ${statistics['todayCalories'] ?? 0}',
          style: ThemeConstants.bodyStyle,
        ),
        Text(
          'Average Calories Per Meal: ${statistics['averageCaloriesPerMeal'] != null ? (statistics['averageCaloriesPerMeal'] as num).toStringAsFixed(1) : 0}', // Handle nulls and cast
          style: ThemeConstants.bodyStyle,
        ),
      ],
    );
  }
}
