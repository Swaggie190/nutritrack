import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/constants/app_constants.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  double _height = 170.0;
  double _weight = 70.0;
  User? _user;
  String? _errorMessage;

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
            _nameController.text = _user!.name;
            _emailController.text = _user!.email;
            _height = _user!.height!;
            _weight = _user!.weight!;
            _calorieController.text = _user!.dailyCalorieGoal.toString();
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to load user data: $e';
        });
      }
    }
  }

  Widget _buildMeasurementSlider({
    required String label,
    required double value,
    required void Function(double) onChanged,
    required double min,
    required double max,
    required String unit,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: ThemeConstants.bodyStyle),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: ThemeConstants.statNumberStyle,
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: ThemeConstants.primaryColor,
            inactiveTrackColor: ThemeConstants.primaryColor.withOpacity(0.2),
            thumbColor: ThemeConstants.primaryColor,
            overlayColor: ThemeConstants.primaryColor.withOpacity(0.1),
            valueIndicatorColor: ThemeConstants.primaryColor,
            valueIndicatorTextStyle: ThemeConstants.bodyStyle.copyWith(
              color: Colors.white,
            ),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: '${value.toStringAsFixed(1)} $unit',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        if (_user != null) {
          final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

          // Handle email update separately due to Firebase authentication requirements
          if (_emailController.text != _user!.email && currentUser != null) {
            try {
              await currentUser.verifyBeforeUpdateEmail(_emailController.text);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Verification email sent. Please check your inbox to confirm the email change.'),
                  duration: Duration(seconds: 5),
                ),
              );
            } catch (e) {
              setState(() {
                _errorMessage = 'Failed to update email: $e';
              });
              return;
            }
          }

          final updatedUser = {
            'name': _nameController.text,
            'email': _user!.email, // Keep the old email until verified
            'height': _height,
            'weight': _weight,
            'dailyCalorieGoal': int.tryParse(_calorieController.text) ??
                AppConstants.defaultDailyCalorieGoal,
          };

          await Provider.of<UserService>(context, listen: false)
              .updateUser(context, _user!, updatedUser);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update profile: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: ThemeConstants.headingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(ThemeConstants.largePadding),
            child: Card(
              elevation: ThemeConstants.largeElevation,
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.largePadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Update my Profile',
                        style: ThemeConstants.subheadingStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ThemeConstants.largePadding),
                      if (_errorMessage != null)
                        Container(
                          padding:
                              const EdgeInsets.all(ThemeConstants.smallPadding),
                          decoration: BoxDecoration(
                            color: ThemeConstants.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.defaultBorderRadius),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: ThemeConstants.bodyStyle.copyWith(
                              color: ThemeConstants.errorColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: ThemeConstants.defaultPadding),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: ThemeConstants.bodyStyle,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.defaultBorderRadius),
                          ),
                        ),
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: ThemeConstants.bodyStyle,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.defaultBorderRadius),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: ThemeConstants.largePadding),
                      _buildMeasurementSlider(
                        label: 'Height',
                        value: _height,
                        onChanged: (value) => setState(() => _height = value),
                        min: 120,
                        max: 220,
                        unit: 'cm',
                        divisions: 100,
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),
                      _buildMeasurementSlider(
                        label: 'Weight',
                        value: _weight,
                        onChanged: (value) => setState(() => _weight = value),
                        min: 30,
                        max: 150,
                        unit: 'kg',
                        divisions: 120,
                      ),
                      const SizedBox(height: ThemeConstants.defaultPadding),
                      TextField(
                        controller: _calorieController,
                        decoration: InputDecoration(
                          labelText: 'Daily Calorie Goal (kcal)',
                          labelStyle: ThemeConstants.bodyStyle,
                          prefixIcon:
                              const Icon(Icons.local_fire_department_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.defaultBorderRadius),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: ThemeConstants.largePadding),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: ThemeConstants.defaultPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeConstants.defaultBorderRadius),
                          ),
                        ),
                        onPressed: _updateUser,
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _calorieController.dispose();
    super.dispose();
  }
}
