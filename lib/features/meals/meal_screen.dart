import 'package:flutter/material.dart';
import 'package:nutritrack/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../core/services/meal_service.dart';
import '../../core/constants/theme_constants.dart';
import '../../widgets/meal_card.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealService = Provider.of<MealService>(context, listen: false);

    return FutureBuilder(
      future: Provider.of<AuthService>(context, listen: false)
          .authStateChanges
          .first
          .then((userId) => mealService.getUserMeals(userId!)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meals'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meals'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: ThemeConstants.errorColor)),
            ),
          );
        } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meals'),
            ),
            body: const Center(
              child: Text('No meals found'),
            ),
          );
        } else {
          final meals = snapshot.data as List;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Meals'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/meal_statistics'),
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return MealCard(
                  meal: meal,
                  onDelete: () async {
                    await mealService.deleteMeal(meal.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Meal deleted successfully')),
                    );
                  },
                  onEdit: () => Navigator.pushNamed(
                    context,
                    '/edit_meal',
                    arguments: meal,
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/add_meal'),
              tooltip: 'Add Meal',
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
