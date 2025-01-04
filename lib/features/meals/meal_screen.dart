import 'package:flutter/material.dart';
import 'package:nutritrack/data/models/meal.dart';
import 'package:nutritrack/widgets/custom_bottom_nav.dart';
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          final userId = authSnapshot.data!.uid;
          final mealService = Provider.of<MealService>(context, listen: false);

          return StreamBuilder<List<Meal>>(
            stream: mealService.getUserMealsStream(userId),
            builder: (context, mealsSnapshot) {
              if (mealsSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!mealsSnapshot.hasData || mealsSnapshot.data!.isEmpty) {
                Future.microtask(
                    () => Navigator.pushReplacementNamed(context, '/add_meal'));
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final meals = mealsSnapshot.data!;

              return Scaffold(
                appBar: AppBar(
                  title: Text('Meals',
                      style: ThemeConstants.headingStyle
                          .copyWith(color: Colors.white)),
                  backgroundColor: ThemeConstants.primaryColor,
                  elevation: ThemeConstants.defaultElevation,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.bar_chart),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/meal_statistics'),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
                  child: ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return MealCard(
                        meal: meal,
                        onDelete: () async {
                          await mealService.deleteMeal(meal.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Meal deleted successfully',
                                style: ThemeConstants.bodyStyle,
                              ),
                              backgroundColor: ThemeConstants.successColor,
                            ),
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
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => Navigator.pushNamed(context, '/add_meal'),
                  backgroundColor: ThemeConstants.primaryColor,
                  elevation: ThemeConstants.defaultElevation,
                  child: const Icon(Icons.add),
                ),
                bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
              );
            },
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Meals', style: ThemeConstants.headingStyle),
            backgroundColor: ThemeConstants.primaryColor,
            elevation: ThemeConstants.defaultElevation,
          ),
          body: Padding(
            padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not logged in,\nYou need to be logged in to see your meals.',
                    style: ThemeConstants.bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(ThemeConstants.smallPadding),
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.primaryColor,
                        elevation: ThemeConstants.defaultElevation,
                      ),
                      child:
                          Text('Go to Login', style: ThemeConstants.bodyStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
