import 'package:flutter/material.dart';
import 'package:nutritrack/core/services/auth_service.dart';
import '../../core/constants/theme_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/meal_service.dart';
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

        await mealService.addMeal(
          userId: userId,
          name: _name,
          calories: _calories,
          notes: _notes,
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meal added successfully'),
            backgroundColor: ThemeConstants.successColor,
          ),
        );
      } catch (e) {
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
                      TextFormField(
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
                        onPressed: _addMeal,
                        child: Text(
                          'Add Meal',
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
