import 'package:flutter/material.dart';
import '../../../core/constants/theme_constants.dart';
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
          const SnackBar(content: Text('Meal updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update meal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Meal Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the meal name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _calories.toString(),
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Please enter a valid number of calories';
                  }
                  return null;
                },
                onSaved: (value) => _calories = int.parse(value!),
              ),
              TextFormField(
                initialValue: _notes,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: ThemeConstants.defaultPadding),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.primaryColor),
                  onPressed: _updateMeal,
                  child: Text('Save Changes', style: ThemeConstants.bodyStyle)),
            ],
          ),
        ),
      ),
    );
  }
}
