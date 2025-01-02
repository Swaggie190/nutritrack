import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutritrack/core/constants/app_constants.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/services/user_service.dart'; // Import UserService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  void handleLogin(BuildContext context) async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = await userService.signInUser(
          context, emailController.text.trim(), passwordController.text.trim());
      if (userId != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: ThemeConstants.errorColor),
              ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: ThemeConstants.bodyStyle,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: ThemeConstants.bodyStyle,
              ),
              obscureText: true,
            ),
            const SizedBox(height: ThemeConstants.defaultPadding),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.primaryColor),
                onPressed: () => handleLogin(context), // Pass context
                child: Text('Login', style: ThemeConstants.bodyStyle)),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Don\'t have an account? Register',
                  style: ThemeConstants.subheadingStyle),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
