import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';
import '../../data/models/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const MealCard(
      {super.key,
      required this.meal,
      required this.onDelete,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: ThemeConstants.smallPadding,
        horizontal: ThemeConstants.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
      elevation: ThemeConstants.defaultElevation,
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: ThemeConstants.headingStyle,
                  ),
                  const SizedBox(height: ThemeConstants.smallPadding),
                  Text(
                    'Calories: ${meal.calories}',
                    style: ThemeConstants.bodyStyle,
                  ),
                  Text(
                    'Date: ${meal.consumedAt.toLocal().toString().split(' ')[0]}',
                    style: ThemeConstants.bodyStyle,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit,
                      color: ThemeConstants.secondaryColor),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete,
                      color: ThemeConstants.errorColor),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
