import 'package:flutter/material.dart';
import 'package:nutritrack/features/meals/meal_recommendations_card.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/theme_constants.dart';
import '../../core/utils/bmi_calculator.dart';
import '../../core/services/user_service.dart';
import '../../core/services/auth_service.dart';

class BMICalculatorCard extends StatelessWidget {
  const BMICalculatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder(
      future: authService.authStateChanges.first
          .then((userId) => userService.getUser(userId!)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('BMI Result'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('BMI Result'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: ThemeConstants.errorColor)),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('BMI Result'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Text('No user data found'),
            ),
          );
        }

        final user = snapshot.data!;

        // Check if weight or height is null
        if (user.weight == null || user.height == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('BMI Result'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child:
                  Text('Please update your weight and height in your profile'),
            ),
          );
        }

        final double bmi =
            BMICalculator.calculateBMI(user.weight!, user.height!);
        final observation = _getObservation(bmi);
        final category = AppConstants.bmiCategories[observation]!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('BMI Result'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
            child: Card(
              elevation: ThemeConstants.defaultElevation,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ThemeConstants.defaultBorderRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your BMI: ${bmi.toStringAsFixed(1)}',
                      style: ThemeConstants.headingStyle,
                    ),
                    const SizedBox(height: ThemeConstants.defaultPadding),
                    Text(
                      'Observation:',
                      style: ThemeConstants.subheadingStyle,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          color: category['color'] as Color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$observation (${category['range']})',
                          style: ThemeConstants.bodyStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: ThemeConstants.defaultPadding),
                    Text(
                      'Recommendation:',
                      style: ThemeConstants.subheadingStyle,
                    ),
                    Text(
                      _getRecommendation(observation),
                      style: ThemeConstants.bodyStyle,
                    ),
                    FoodRecommendationCard(bmiCategory: observation),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getObservation(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi >= 18.5 && bmi <= 24.9) return 'Normal';
    if (bmi >= 25 && bmi <= 29.9) return 'Overweight';
    return 'Obese';
  }

  String _getRecommendation(String observation) {
    switch (observation) {
      case 'Underweight':
        return 'Consider eating more nutritious meals and consulting a dietitian.';
      case 'Normal':
        return 'Maintain your current lifestyle for a healthy weight.';
      case 'Overweight':
        return 'Incorporate more physical activities and consider a balanced diet.';
      case 'Obese':
        return 'Seek medical advice and follow a structured health plan.';
      default:
        return 'No specific recommendations.';
    }
  }
}
