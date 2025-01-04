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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Meal Statistics',
            style: ThemeConstants.headingStyle.copyWith(color: Colors.white)),
        centerTitle: true,
        elevation: ThemeConstants.largeElevation,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeConstants.primaryColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: mealService.getMealStatistics(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Statistics Error: ${snapshot.error}',
                          style: const TextStyle(
                              color: ThemeConstants.errorColor)),
                    );
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                        child: Text('No meal statistics found'));
                  } else {
                    final statistics = snapshot.data!;
                    return _buildStatisticsContent(statistics);
                  }
                },
              ),
              const SizedBox(height: ThemeConstants.largePadding),
              _buildCaloriesCard(mealService, userId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsContent(Map<String, dynamic> statistics) {
    return Card(
      elevation: ThemeConstants.largeElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Meal Statistics',
              style: ThemeConstants.headingStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConstants.largePadding),
            _buildStatCard(
              'Total Meals',
              '${statistics['totalMeals'] ?? 0}',
              Icons.restaurant,
              ThemeConstants.primaryColor,
            ),
            _buildStatCard(
              'Today\'s Meals',
              '${statistics['todayMeals'] ?? 0}',
              Icons.today,
              ThemeConstants.secondaryColor,
            ),
            _buildStatCard(
              'Today\'s Calories',
              '${statistics['todayCalories'] ?? 0} kcal',
              Icons.local_fire_department,
              ThemeConstants.warningColor,
            ),
            _buildStatCard(
              'Average Calories/Meal',
              '${statistics['averageCaloriesPerMeal'] != null ? (statistics['averageCaloriesPerMeal'] as num).toStringAsFixed(1) : 0} kcal',
              Icons.analytics,
              ThemeConstants.successColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: ThemeConstants.smallPadding),
      child: Container(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: ThemeConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: ThemeConstants.bodyStyle.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    value,
                    style: ThemeConstants.subheadingStyle.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesCard(MealService mealService, String userId) {
    return Card(
      elevation: ThemeConstants.largeElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: ThemeConstants.secondaryColor),
                const SizedBox(width: ThemeConstants.smallPadding),
                Text(
                  'Weekly Calorie History',
                  style: ThemeConstants.subheadingStyle,
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.defaultPadding),
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: ThemeConstants.smallPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key.toLocal().toString().split(' ')[0],
                              style: ThemeConstants.bodyStyle,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ThemeConstants.defaultPadding,
                                vertical: ThemeConstants.smallPadding,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeConstants.primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    ThemeConstants.defaultBorderRadius),
                              ),
                              child: Text(
                                '${entry.value} kcal',
                                style: ThemeConstants.bodyStyle.copyWith(
                                  color: ThemeConstants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
