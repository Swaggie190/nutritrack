import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/meal_service.dart';
import '../../core/constants/theme_constants.dart';
import '../../widgets/meal_card.dart';

class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final userId = authSnapshot.data!.uid;
          final mealService = Provider.of<MealService>(context, listen: false);

          return FutureBuilder<bool>(
            // First check if user has any meals
            future: mealService.userHasMeals(userId),
            builder: (context, hasMealsSnapshot) {
              if (hasMealsSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If user has no meals, redirect to add meal screen
              if (!hasMealsSnapshot.data!) {
                Future.microtask(
                  () => Navigator.pushReplacementNamed(context, '/add_meal'),
                );
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If user has meals, proceed with loading them
              return FutureBuilder(
                future: mealService.getUserMeals(userId),
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
                            style: const TextStyle(
                                color: ThemeConstants.errorColor)),
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
                            onPressed: () => Navigator.pushNamed(
                                context, '/meal_statistics'),
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
                        onPressed: () =>
                            Navigator.pushNamed(context, '/add_meal'),
                        tooltip: 'Add Meal',
                        child: const Icon(Icons.add),
                      ),
                    );
                  }
                },
              );
            },
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Meals'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not logged in'),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/login',
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
