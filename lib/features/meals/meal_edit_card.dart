import 'package:flutter/material.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/meal.dart';
import '../../../core/services/meal_service.dart';
import 'package:provider/provider.dart';

class MealEditCard extends StatefulWidget {
  final Meal meal;

  const MealEditCard({super.key, required this.meal});

  @override
  _MealEditCardState createState() => _MealEditCardState();
}

class _MealEditCardState extends State<MealEditCard> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _calories;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _name = widget.meal.name;
    _calories = widget.meal.calories;
    _notes = widget.meal.notes;
  }

  Future<void> _updateMeal() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final updatedMeal = Meal(
        id: widget.meal.id,
        userId: widget.meal.userId,
        name: _name,
        calories: _calories,
        consumedAt: widget.meal.consumedAt,
        notes: _notes,
      );

      try {
        final mealService = Provider.of<MealService>(context, listen: false);
        await mealService.updateMeal(updatedMeal);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meal updated successfully'),
            backgroundColor: ThemeConstants.successColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update meal: $e'),
            backgroundColor: ThemeConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Meal',
            style: ThemeConstants.headingStyle.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(ThemeConstants.largePadding),
            child: Card(
              elevation: ThemeConstants.largeElevation,
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Edit Meal Details',
                        style: ThemeConstants.subheadingStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(
                          labelText: 'Meal Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the meal name';
                          }
                          if (value.length > AppConstants.maxNameLength) {
                            return 'Name too long';
                          }
                          return null;
                        },
                        onSaved: (value) => _name = value!,
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),
                      TextFormField(
                        initialValue: _calories.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter calories';
                          }
                          final calories = int.tryParse(value);
                          if (calories == null || calories <= 0) {
                            return 'Please enter a valid number of calories';
                          }
                          return null;
                        },
                        onSaved: (value) => _calories = int.parse(value!),
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),
                      TextFormField(
                        initialValue: _notes,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onSaved: (value) => _notes = value,
                      ),
                      const SizedBox(height: ThemeConstants.largePadding),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: ThemeConstants.defaultPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.defaultBorderRadius),
                          ),
                        ),
                        onPressed: _updateMeal,
                        child: Text(
                          'Save Changes',
                          style: ThemeConstants.bodyStyle
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
