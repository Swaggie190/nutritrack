import 'package:flutter/material.dart';
import 'package:nutritrack/core/services/auth_service.dart';
import '../../core/constants/theme_constants.dart';
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
            const SnackBar(content: Text('User not logged in')),
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
          const SnackBar(content: Text('Meal added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add meal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
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
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: ThemeConstants.defaultPadding),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryColor),
                onPressed: _addMeal,
                child: const Text('Add Meal', style: ThemeConstants.bodyStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
