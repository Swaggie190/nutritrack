import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/services/user_service.dart';
import 'package:nutritrack/data/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  double? _height;
  double? _weight;
  int? _dailyCalorieGoal;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final userService = Provider.of<UserService>(context, listen: false);
      try {
        _user = await userService.getUser(firebaseUser.uid);
        if (_user != null) {
          setState(() {
            _name = _user!.name;
            _email = _user!.email;
            _height = _user!.height;
            _weight = _user!.weight;
            _dailyCalorieGoal = _user!.dailyCalorieGoal;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    }
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (_user != null) {
        try {
          final updatedUser = {
            'name': _name,
            'email': _email,
            'height': _height,
            'weight': _weight,
            'dailyCalorieGoal': _dailyCalorieGoal,
          };
          await Provider.of<UserService>(context, listen: false)
              .updateUser(context, _user!, updatedUser);
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update user: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                initialValue: _name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                initialValue: _email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                initialValue: _height?.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
                onSaved: (value) => _height = double.tryParse(value ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                initialValue: _weight?.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
                onSaved: (value) => _weight = double.tryParse(value ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Daily Calorie Goal (kcal)'),
                initialValue: _dailyCalorieGoal?.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your daily calorie goal';
                  }
                  return null;
                },
                onSaved: (value) =>
                    _dailyCalorieGoal = int.tryParse(value ?? ''),
              ),
              const SizedBox(height: ThemeConstants.defaultPadding),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.primaryColor),
                  onPressed: _updateUser,
                  child: Text('Save', style: ThemeConstants.bodyStyle)),
            ],
          ),
        ),
      ),
    );
  }
}
