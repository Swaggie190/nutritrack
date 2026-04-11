import 'package:flutter/material.dart';
import 'package:nutritrack/core/services/auth_service.dart';
import '../../core/constants/theme_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/meal_service.dart';
import '../../data/models/meal.dart';
import 'package:provider/provider.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _calories;
  String? _notes;

  // New fields
  MealType _mealType = MealType.other;
  TimeOfDay _mealTime = TimeOfDay.now();
  bool _trackMacros = false;
  double? _protein;
  double? _carbs;
  double? _fats;
  double? _servingSize;
  String _servingUnit = 'g';

  final List<String> _servingUnits = ['g', 'oz', 'ml', 'cups', 'servings'];

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

  Future<void> _addMeal() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        final mealService = Provider.of<MealService>(context, listen: false);
        final authService = Provider.of<AuthService>(context, listen: false);
        final userId = authService.currentUser?.uid;

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppConstants.unauthorized),
              backgroundColor: ThemeConstants.errorColor,
            ),
          );
          return;
        }

        // Create DateTime from selected time
        final now = DateTime.now();
        final consumedAt = DateTime(
          now.year,
          now.month,
          now.day,
          _mealTime.hour,
          _mealTime.minute,
        );

        await mealService.addMeal(
          userId: userId,
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

        if (!context.mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal added successfully'),
            backgroundColor: ThemeConstants.successColor,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add meal: $e'),
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
        title: Text('Add Meal',
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
                        'Meal Details',
                        style: ThemeConstants.subheadingStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),

                      // Meal Name
                      TextFormField(
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

                      // Macro Inputs (Expandable)
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
                              // Protein
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Protein',
                                  border: OutlineInputBorder(),
                                  suffixText: 'g',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                validator: _trackMacros
                                    ? (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final protein =
                                              double.tryParse(value);
                                          if (protein == null || protein < 0) {
                                            return 'Invalid value';
                                          }
                                        }
                                        return null;
                                      }
                                    : null,
                                onSaved: (value) => _protein =
                                    value != null && value.isNotEmpty
                                        ? double.tryParse(value)
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              // Carbs
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Carbohydrates',
                                  border: OutlineInputBorder(),
                                  suffixText: 'g',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                validator: _trackMacros
                                    ? (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final carbs = double.tryParse(value);
                                          if (carbs == null || carbs < 0) {
                                            return 'Invalid value';
                                          }
                                        }
                                        return null;
                                      }
                                    : null,
                                onSaved: (value) => _carbs =
                                    value != null && value.isNotEmpty
                                        ? double.tryParse(value)
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              // Fats
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Fats',
                                  border: OutlineInputBorder(),
                                  suffixText: 'g',
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.number,
                                validator: _trackMacros
                                    ? (value) {
                                        if (value != null && value.isNotEmpty) {
                                          final fats = double.tryParse(value);
                                          if (fats == null || fats < 0) {
                                            return 'Invalid value';
                                          }
                                        }
                                        return null;
                                      }
                                    : null,
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
                              decoration: const InputDecoration(
                                labelText: 'Serving Size (optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final size = double.tryParse(value);
                                  if (size == null || size <= 0) {
                                    return 'Invalid value';
                                  }
                                }
                                return null;
                              },
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
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                        onSaved: (value) => _notes = value,
                      ),
                      const SizedBox(height: ThemeConstants.largePadding),

                      // Add Meal Button
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
                        onPressed: _addMeal,
                        child: Text(
                          'Add Meal',
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
