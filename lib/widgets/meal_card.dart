import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';
import '../../data/models/meal.dart';
import 'package:intl/intl.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const MealCard({
    super.key,
    required this.meal,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM dd, yyyy').format(meal.consumedAt.toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: ThemeConstants.smallPadding,
        horizontal: ThemeConstants.defaultPadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
        side: BorderSide(
          color: ThemeConstants.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      elevation: ThemeConstants.defaultElevation,
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeConstants.largeBorderRadius),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: ThemeConstants.cardTitleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: ThemeConstants.smallPadding / 2),
                        Text(
                          formattedDate,
                          style: ThemeConstants.bodyStyle.copyWith(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black54,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          ThemeConstants.defaultBorderRadius),
                    ),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: ThemeConstants.secondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: ThemeConstants.smallPadding),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: ThemeConstants.errorColor,
                              size: 20,
                            ),
                            const SizedBox(width: ThemeConstants.smallPadding),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (String value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: ThemeConstants.defaultPadding),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConstants.smallPadding,
                  vertical: ThemeConstants.smallPadding / 2,
                ),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: ThemeConstants.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${meal.calories} calories',
                      style: ThemeConstants.bodyStyle.copyWith(
                        color: ThemeConstants.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (meal.notes?.isNotEmpty ?? false) ...[
                const SizedBox(height: ThemeConstants.smallPadding),
                Text(
                  meal.notes!,
                  style: ThemeConstants.bodyStyle.copyWith(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
