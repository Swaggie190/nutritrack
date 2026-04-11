import 'package:flutter/material.dart';
import '../core/constants/theme_constants.dart';

/// Displays macronutrient breakdown (Protein, Carbs, Fats)
/// Can show as horizontal bars or compact row
class MacroDisplay extends StatelessWidget {
  final double? protein;
  final double? carbs;
  final double? fats;
  final bool showPercentages;
  final bool isCompact;

  const MacroDisplay({
    super.key,
    this.protein,
    this.carbs,
    this.fats,
    this.showPercentages = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    final proteinVal = protein ?? 0;
    final carbsVal = carbs ?? 0;
    final fatsVal = fats ?? 0;

    // Calculate calories from macros (protein: 4 cal/g, carbs: 4 cal/g, fats: 9 cal/g)
    final proteinCals = proteinVal * 4;
    final carbsCals = carbsVal * 4;
    final fatsCals = fatsVal * 9;
    final totalCals = proteinCals + carbsCals + fatsCals;

    if (totalCals == 0) {
      return Center(
        child: Text(
          'No macro data available',
          style: ThemeConstants.bodyStyle.copyWith(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    if (isCompact) {
      return _buildCompactView(proteinVal, carbsVal, fatsVal);
    } else {
      return _buildExpandedView(
        proteinVal,
        carbsVal,
        fatsVal,
        proteinCals,
        carbsCals,
        fatsCals,
        totalCals,
      );
    }
  }

  Widget _buildCompactView(double protein, double carbs, double fats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMacroChip('P', protein, const Color(0xFFE57373)), // Red
        _buildMacroChip('C', carbs, const Color(0xFF81C784)), // Green
        _buildMacroChip('F', fats, const Color(0xFF64B5F6)), // Blue
      ],
    );
  }

  Widget _buildMacroChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${value.toStringAsFixed(1)}g',
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView(
    double protein,
    double carbs,
    double fats,
    double proteinCals,
    double carbsCals,
    double fatsCals,
    double totalCals,
  ) {
    return Column(
      children: [
        _buildMacroRow(
          'Protein',
          protein,
          proteinCals,
          totalCals,
          const Color(0xFFE57373),
          Icons.fitness_center,
        ),
        const SizedBox(height: 12),
        _buildMacroRow(
          'Carbs',
          carbs,
          carbsCals,
          totalCals,
          const Color(0xFF81C784),
          Icons.grass,
        ),
        const SizedBox(height: 12),
        _buildMacroRow(
          'Fats',
          fats,
          fatsCals,
          totalCals,
          const Color(0xFF64B5F6),
          Icons.water_drop,
        ),
      ],
    );
  }

  Widget _buildMacroRow(
    String name,
    double grams,
    double calories,
    double totalCals,
    Color color,
    IconData icon,
  ) {
    final percentage = totalCals > 0 ? (calories / totalCals) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              name,
              style: ThemeConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${grams.toStringAsFixed(1)}g',
              style: ThemeConstants.bodyStyle.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showPercentages) ...[
              const SizedBox(width: 8),
              Text(
                '(${(percentage * 100).toStringAsFixed(0)}%)',
                style: ThemeConstants.bodyStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
