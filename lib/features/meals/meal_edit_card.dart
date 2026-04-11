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

  // New fields
  late MealType _mealType;
  late TimeOfDay _mealTime;
  late bool _trackMacros;
  double? _protein;
  double? _carbs;
  double? _fats;
  double? _servingSize;
  late String _servingUnit;

  final List<String> _servingUnits = ['g', 'oz', 'ml', 'cups', 'servings'];

  @override
  void initState() {
    super.initState();
    _name = widget.meal.name;
    _calories = widget.meal.calories;
    _notes = widget.meal.notes;
    _mealType = widget.meal.mealType;
    _mealTime = TimeOfDay.fromDateTime(widget.meal.consumedAt);
    _protein = widget.meal.protein;
    _carbs = widget.meal.carbs;
    _fats = widget.meal.fats;
    _trackMacros = widget.meal.protein != null ||
        widget.meal.carbs != null ||
        widget.meal.fats != null;
    _servingSize = widget.meal.servingSize;
    _servingUnit = widget.meal.servingUnit ?? 'g';
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _mealTime,
    );
    if (picked != null && picked != _mealTime) {
      setState(() {
        _mealTime = picked;
      });
    }
  }

  Future<void> _updateMeal() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Create DateTime from selected time
      final originalDate = widget.meal.consumedAt;
      final consumedAt = DateTime(
        originalDate.year,
        originalDate.month,
        originalDate.day,
        _mealTime.hour,
        _mealTime.minute,
      );

      final updatedMeal = widget.meal.copyWith(
        name: _name,
        calories: _calories,
        notes: _notes,
        mealType: _mealType,
        consumedAt: consumedAt,
        protein: _trackMacros ? _protein : null,
        carbs: _trackMacros ? _carbs : null,
        fats: _trackMacros ? _fats : null,
        servingSize: _servingSize,
        servingUnit: _servingSize != null ? _servingUnit : null,
      );

      try {
        final mealService = Provider.of<MealService>(context, listen: false);
        await mealService.updateMeal(updatedMeal);
        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal updated successfully'),
            backgroundColor: ThemeConstants.successColor,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
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

                      // Meal Name
                      TextFormField(
                        initialValue: _name,
                        decoration: const InputDecoration(
                          labelText: 'Meal Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.restaurant),
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

                      // Meal Type Selector
                      Text('Meal Type', style: ThemeConstants.bodyStyle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: MealType.values.map((type) {
                          final isSelected = _mealType == type;
                          return ChoiceChip(
                            label: Text(type.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _mealType = type;
                              });
                            },
                            selectedColor: ThemeConstants.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),

                      // Time Picker
                      InkWell(
                        onTap: _selectTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            _mealTime.format(context),
                            style: ThemeConstants.bodyStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),

                      // Calories
                      TextFormField(
                        initialValue: _calories.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Calories',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_fire_department),
                          suffixText: 'kcal',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter calories';
                          }
                          final calories = int.tryParse(value);
                          if (calories == null || calories <= 0) {
                            return 'Please enter a valid number';
                          }
                          if (calories > 5000) {
                            return 'Calories seem too high';
                          }
                          return null;
                        },
                        onSaved: (value) => _calories = int.parse(value!),
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),

                      // Track Macros Toggle
                      SwitchListTile(
                        title: Text('Track Macronutrients',
                            style: ThemeConstants.bodyStyle),
                        subtitle: const Text('Protein, Carbs, Fats'),
                        value: _trackMacros,
                        onChanged: (value) {
                          setState(() {
                            _trackMacros = value;
                          });
                        },
                        activeColor: ThemeConstants.primaryColor,
                      ),

                      // Macro Inputs
                      if (_trackMacros) ...[
                        const SizedBox(height: ThemeConstants.defaultPadding),
                        Container(
                          padding: const EdgeInsets.all(
                              ThemeConstants.defaultPadding),
                          decoration: BoxDecoration(
                            color: ThemeConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.defaultBorderRadius),
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: _protein?.toString() ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Protein',
                                  border: OutlineInputBorder(),
                                  suffixText: 'g',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (value) => _protein =
                                    value != null && value.isNotEmpty
                                        ? double.tryParse(value)
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: _carbs?.toString() ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Carbohydrates',
                                  border: OutlineInputBorder(),
                                  suffixText: 'g',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (value) => _carbs =
                                    value != null && value.isNotEmpty
                                        ? double.tryParse(value)
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                initialValue: _fats?.toString() ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Fats',
                                  border: OutlineInputBorder(),
                                  suffixText: 'g',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (value) => _fats =
                                    value != null && value.isNotEmpty
                                        ? double.tryParse(value)
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: ThemeConstants.defaultPadding),

                      // Serving Size
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: _servingSize?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Serving Size (optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                              ),
                              keyboardType: TextInputType.number,
                              onSaved: (value) => _servingSize =
                                  value != null && value.isNotEmpty
                                      ? double.tryParse(value)
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _servingUnit,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                              ),
                              items: _servingUnits.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _servingUnit = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),

                      // Notes
                      TextFormField(
                        initialValue: _notes,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                        onSaved: (value) => _notes = value,
                      ),
                      const SizedBox(height: ThemeConstants.largePadding),

                      // Save Button
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
                              .copyWith(color: Colors.white, fontSize: 16),
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
