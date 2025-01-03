import 'package:nutritrack/features/Home/health_tip.dart';

class HealthTipsData {
  static const List<HealthTip> tips = [
    // Nutrition Tips
    HealthTip(
      category: 'nutrition',
      message:
          'Eat a rainbow of colors in your fruits and vegetables to ensure you\'re getting a wide variety of nutrients.',
      source: 'WHO Nutrition Guidelines',
    ),
    HealthTip(
      category: 'nutrition',
      message:
          'Protein helps build and repair tissues. Include lean meats, legumes, or plant-based alternatives in your meals.',
      source: 'Dietary Guidelines',
    ),

    // BMI Awareness
    HealthTip(
      category: 'bmi',
      message:
          'Regular BMI monitoring helps track your progress toward your health goals.',
      source: 'Health Organizations',
    ),
    HealthTip(
      category: 'bmi',
      message:
          'BMI is just one measure of health - consider also tracking your body composition and energy levels.',
    ),

    // Calorie Awareness
    HealthTip(
      category: 'calories',
      message:
          'Reading food labels can help you make informed decisions about your calorie intake.',
      source: 'Nutrition Education',
    ),
    HealthTip(
      category: 'calories',
      message:
          'Remember that not all calories are equal - focus on nutrient-dense foods.',
    ),

    // General Wellness
    HealthTip(
      category: 'wellness',
      message: 'Stay hydrated! Aim to drink water throughout the day.',
      source: 'Hydration Guidelines',
    ),
    HealthTip(
      category: 'wellness',
      message:
          'Small, consistent changes to your diet are more sustainable than dramatic restrictions.',
    ),

    // Mindful Eating
    HealthTip(
      category: 'mindful_eating',
      message:
          'Practice mindful eating by sitting down and focusing on your meal without distractions.',
      source: 'Mindful Eating Practice',
    ),
    HealthTip(
      category: 'mindful_eating',
      message:
          'Listen to your body\'s hunger and fullness cues to develop better eating habits.',
    ),
  ];
}
