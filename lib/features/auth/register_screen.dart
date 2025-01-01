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
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String? errorMessage;

  void handleRegister(BuildContext context) async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);

      // Step 1: Register the user
      try {
        await userService.registerUser(
          context,
          emailController.text.trim(),
          passwordController.text.trim(),
          nameController.text.trim(),
          double.parse(heightController.text.trim()),
          double.parse(weightController.text.trim()),
        );
        print("User registered successfully");
      } catch (e) {
        print("Error during user registration: $e");
        throw Exception("Error in registerUser: $e");
      }

      // Step 2: Navigate to home
      try {
        Navigator.pushReplacementNamed(context, '/home');
        print("Navigation to home successful");
      } catch (e) {
        print("Error during navigation: $e");
        throw Exception("Error in navigation: $e");
      }
    } catch (e) {
      // Handle errors and display error message
      print("handleRegister encountered an error: $e");
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: ThemeConstants.errorColor),
                ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: ThemeConstants.bodyStyle,
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: ThemeConstants.bodyStyle,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: ThemeConstants.bodyStyle,
                ),
                obscureText: true,
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: 'Height',
                  labelStyle: ThemeConstants.bodyStyle,
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  labelStyle: ThemeConstants.bodyStyle,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: ThemeConstants.defaultPadding),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryColor),
                onPressed: () => handleRegister(context), // Pass context
                child: const Text('Register', style: ThemeConstants.bodyStyle),
              ),
            ],
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
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
