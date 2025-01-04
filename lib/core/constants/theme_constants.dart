import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  // Colors (existing)
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color errorColor = Color(0xFFE57373);
  static const Color successColor = Color(0xFF81C784);
  static const Color warningColor = Color(0xFFFFB74D);

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: Colors.black87,
      );

  static TextStyle get subheadingStyle => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: Colors.black87,
      );

  static TextStyle get bodyStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: Colors.black87,
      );

  static TextStyle get statNumberStyle => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: Colors.black87,
      );

  static TextStyle get statLabelStyle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: Colors.black54,
      );

  static TextStyle get cardTitleStyle => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: Colors.black87,
      );

  // Other constants remain the same
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double defaultElevation = 2.0;
  static const double largeElevation = 4.0;

  // Update where text styles are used in the Meal Stats Screen
  static updateStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: statLabelStyle),
                const SizedBox(height: 4),
                Text(value, style: statNumberStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: defaultElevation,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
      cardTheme: CardTheme(
        elevation: defaultElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
    );
  }
}
