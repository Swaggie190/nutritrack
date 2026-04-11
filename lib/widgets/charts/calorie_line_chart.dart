import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

/// Line chart showing calorie trends over time
class CalorieLineChart extends StatelessWidget {
  final Map<DateTime, int> caloriesByDate;
  final int? dailyGoal;
  final String period; // '7d', '14d', '30d'

  const CalorieLineChart({
    super.key,
    required this.caloriesByDate,
    this.dailyGoal,
    this.period = '7d',
  });

  @override
  Widget build(BuildContext context) {
    if (caloriesByDate.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: ThemeConstants.bodyStyle.copyWith(color: Colors.grey),
        ),
      );
    }

    final sortedDates = caloriesByDate.keys.toList()..sort();
    final maxCalories = caloriesByDate.values.reduce((a, b) => a > b ? a : b);
    final maxY = dailyGoal != null
        ? (maxCalories > dailyGoal! ? maxCalories : dailyGoal!)
        : maxCalories;

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4).toDouble(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
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
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= sortedDates.length)
                    return const Text('');
                  final date = sortedDates[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY / 4).toDouble(),
                reservedSize: 42,
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
          minX: 0,
          maxX: (sortedDates.length - 1).toDouble(),
          minY: 0,
          maxY: maxY.toDouble() * 1.1,
          lineBarsData: [
            // Main calorie line
            LineChartBarData(
              spots: sortedDates.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  caloriesByDate[entry.value]!.toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: ThemeConstants.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: ThemeConstants.primaryColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: ThemeConstants.primaryColor.withOpacity(0.2),
              ),
            ),
            // Goal line
            if (dailyGoal != null)
              LineChartBarData(
                spots: List.generate(
                  sortedDates.length,
                  (index) => FlSpot(index.toDouble(), dailyGoal!.toDouble()),
                ),
                isCurved: false,
                color: ThemeConstants.warningColor,
                barWidth: 2,
                dashArray: [5, 5],
                dotData: const FlDotData(show: false),
              ),
          ],
        ),
      ),
    );
  }
}
