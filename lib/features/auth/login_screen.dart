import 'package:flutter/material.dart';
import 'package:nutritrack/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:nutritrack/core/constants/app_constants.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/services/user_service.dart';

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

  void handleForgotPassword(BuildContext context) async {
    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email address';
      });
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.resetPassword(emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent',
            style: ThemeConstants.bodyStyle.copyWith(color: Colors.white),
          ),
          backgroundColor: ThemeConstants.successColor,
        ),
      );
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
                      'Welcome Back',
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => handleForgotPassword(context),
                        child: Text(
                          'Forgot Password?',
                          style: ThemeConstants.bodyStyle.copyWith(
                            color: ThemeConstants.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.defaultPadding),
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
                      onPressed: () => handleLogin(context),
                      child: Text('Login',
                          style: ThemeConstants.bodyStyle
                              .copyWith(color: Colors.white)),
                    ),
                    const SizedBox(height: ThemeConstants.defaultPadding),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Don\'t have an account? Register',
                        style: ThemeConstants.bodyStyle.copyWith(
                          color: ThemeConstants.secondaryColor,
                        ),
                      ),
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
    super.dispose();
  }
}
