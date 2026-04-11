import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

/// Pie chart showing macronutrient distribution
class MacroPieChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fats;

  const MacroPieChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate calories from macros
    final proteinCals = protein * 4; // 4 cal/g
    final carbsCals = carbs * 4; // 4 cal/g
    final fatsCals = fats * 9; // 9 cal/g
    final totalCals = proteinCals + carbsCals + fatsCals;

    if (totalCals == 0) {
      return Center(
        child: Text(
          'No macro data available',
          style: ThemeConstants.bodyStyle.copyWith(color: Colors.grey),
        ),
      );
    }

    final proteinPercent = (proteinCals / totalCals * 100);
    final carbsPercent = (carbsCals / totalCals * 100);
    final fatsPercent = (fatsCals / totalCals * 100);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: [
                // Protein
                PieChartSectionData(
                  color: const Color(0xFFE57373), // Red
                  value: proteinCals,
                  title: '${proteinPercent.toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Carbs
                PieChartSectionData(
                  color: const Color(0xFF81C784), // Green
                  value: carbsCals,
                  title: '${carbsPercent.toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Fats
                PieChartSectionData(
                  color: const Color(0xFF64B5F6), // Blue
                  value: fatsCals,
                  title: '${fatsPercent.toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          'Protein',
          protein,
          const Color(0xFFE57373),
        ),
        _buildLegendItem(
          'Carbs',
          carbs,
          const Color(0xFF81C784),
        ),
        _buildLegendItem(
          'Fats',
          fats,
          const Color(0xFF64B5F6),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, double value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}g',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
