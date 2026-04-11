import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

/// Bar chart showing calories by meal type
class MealTypeBarChart extends StatelessWidget {
  final Map<String, Map<String, int>> mealTypeDistribution;

  const MealTypeBarChart({
    super.key,
    required this.mealTypeDistribution,
  });

  @override
  Widget build(BuildContext context) {
    if (mealTypeDistribution.isEmpty) {
      return Center(
        child: Text(
          'No meal data available',
          style: ThemeConstants.bodyStyle.copyWith(color: Colors.grey),
        ),
      );
    }

    final types = mealTypeDistribution.keys.toList();
    final maxCalories = mealTypeDistribution.values
        .map((data) => data['calories'] ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCalories.toDouble() * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final type = types[group.x.toInt()];
                final calories = rod.toY.toInt();
                final count = mealTypeDistribution[type]?['count'] ?? 0;
                return BarTooltipItem(
                  '$type\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '$calories kcal\n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: '$count meals',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= types.length) return const Text('');
                  final type = types[value.toInt()];
                  String shortName = type;
                  if (type.length > 8) {
                    shortName = type.substring(0, 3);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      shortName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: (maxCalories / 4).toDouble(),
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxCalories / 4).toDouble(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: types.asMap().entries.map((entry) {
            final index = entry.key;
            final type = entry.value;
            final calories = mealTypeDistribution[type]?['calories'] ?? 0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: calories.toDouble(),
                  color: _getColorForType(type),
                  width: 32,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxCalories.toDouble() * 1.2,
                    color: Colors.grey[200],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFB74D); // Orange
      case 'lunch':
        return const Color(0xFF81C784); // Green
      case 'dinner':
        return const Color(0xFF64B5F6); // Blue
      case 'snack':
        return const Color(0xFFE57373); // Red
      default:
        return ThemeConstants.primaryColor;
    }
  }
}
