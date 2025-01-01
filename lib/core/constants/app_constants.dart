import 'package:flutter/material.dart'; // Import for Color

class AppConstants {
  // App Info
  static const String appName = 'NutriTrack';
  static const String appVersion = '1.0.0';

  // API Keys (CRITICAL: NEVER store API keys directly in code)
  // These should be fetched from a secure source at runtime or injected
  // via build configurations.
  // Example (using environment variables):
  // static String googleMapsApiKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const String googleMapsApiKeyPlaceholder =
      'YOUR_GOOGLE_MAPS_API_KEY'; // Placeholder for development

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // Nutrition
  static const int defaultDailyCalorieGoal = 2000;
  static const List<String> mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack'
  ];

  // BMI Categories
  static const Map<String, Map<String, dynamic>> bmiCategories = {
    'Underweight': {
      'range': '< 18.5',
      'color': Color(0xFF64B5F6)
    }, // Use const Color
    'Normal': {
      'range': '18.5 - 24.9',
      'color': Color(0xFF81C784)
    }, // Use const Color
    'Overweight': {
      'range': '25 - 29.9',
      'color': Color(0xFFFFB74D)
    }, // Use const Color
    'Obese': {'range': '≥ 30', 'color': Color(0xFFE57373)}, // Use const Color
  };

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String unauthorized = 'Unauthorized access';
  static const String serverError = 'Server error occurred';

  // Consider adding more specific error messages for better UX
  // Example:
  static const String invalidEmailFormat = 'Invalid email format';
  static const String passwordMismatch = 'Passwords do not match';
}
