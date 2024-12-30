import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

class FoodRecommendationCard extends StatelessWidget {
  final String bmiCategory;

  const FoodRecommendationCard({super.key, required this.bmiCategory});

  List<String> _getRecommendations(String category) {
    switch (category) {
      case 'Underweight':
        return ['Avocado Toast', 'Protein Smoothie', 'Granola with Yogurt'];
      case 'Normal':
        return ['Grilled Chicken Salad', 'Steamed Vegetables', 'Brown Rice'];
      case 'Overweight':
        return ['Quinoa Salad', 'Vegetable Stir Fry', 'Grilled Fish'];
      case 'Obese':
        return ['Green Salad', 'Low-Carb Soup', 'Steamed Broccoli'];
      default:
        return ['No recommendations available'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations(bmiCategory);

    return Card(
      elevation: ThemeConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Recommendations',
              style: ThemeConstants.headingStyle,
            ),
            const SizedBox(height: ThemeConstants.defaultPadding),
            ...recommendations.map((meal) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('• $meal', style: ThemeConstants.bodyStyle),
                )),
          ],
        ),
      ),
    );
  }
}
