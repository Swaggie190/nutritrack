import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutritrack/core/constants/app_constants.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  double height = 170.0; // Default height in cm
  double weight = 70.0; // Default weight in kg
  String? errorMessage;

  void handleRegister(BuildContext context) async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);

      try {
        await userService.registerUser(
          context,
          emailController.text.trim(),
          passwordController.text.trim(),
          nameController.text.trim(),
          height,
          weight,
        );
        print("User registered successfully");
      } catch (e) {
        print("Error during user registration: $e");
        throw Exception("Error in registerUser: $e");
      }

      try {
        Navigator.pushReplacementNamed(context, '/home');
        print("Navigation to home successful");
      } catch (e) {
        print("Error during navigation: $e");
        throw Exception("Error in navigation: $e");
      }
    } catch (e) {
      print("handleRegister encountered an error: $e");
      setState(() {
        errorMessage = e.toString();
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create Account',
                      style: ThemeConstants.headingStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ThemeConstants.largePadding),
                    if (errorMessage != null)
                      Container(
                        padding:
                            const EdgeInsets.all(ThemeConstants.smallPadding),
                        decoration: BoxDecoration(
                          color: ThemeConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.defaultBorderRadius),
                        ),
                        child: Text(
                          errorMessage!,
                          style: ThemeConstants.bodyStyle.copyWith(
                            color: ThemeConstants.errorColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: ThemeConstants.defaultPadding),
                    TextField(
                      controller: nameController,
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
                      controller: emailController,
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
                    const SizedBox(height: ThemeConstants.defaultPadding),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: ThemeConstants.bodyStyle,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              ThemeConstants.defaultBorderRadius),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: ThemeConstants.largePadding),
                    _buildMeasurementSlider(
                      label: 'Height',
                      value: height,
                      onChanged: (value) => setState(() => height = value),
                      min: 120,
                      max: 220,
                      unit: 'cm',
                      divisions: 100,
                    ),
                    const SizedBox(height: ThemeConstants.defaultPadding),
                    _buildMeasurementSlider(
                      label: 'Weight',
                      value: weight,
                      onChanged: (value) => setState(() => weight = value),
                      min: 30,
                      max: 150,
                      unit: 'kg',
                      divisions: 120,
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
                      onPressed: () => handleRegister(context),
                      child: Text('Register',
                          style: ThemeConstants.bodyStyle
                              .copyWith(color: Colors.white)),
                    ),
                  ],
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
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
