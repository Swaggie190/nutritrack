import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutritrack/core/services/meal_service.dart';
import 'package:nutritrack/data/models/meal.dart';
import 'package:nutritrack/data/reposotories/meal_repository.dart';
import 'package:nutritrack/features/Home/home.dart';
import 'package:nutritrack/core/services/auth_service.dart';
import 'package:nutritrack/features/auth/register_screen.dart';
import 'package:nutritrack/features/meals/meal_stats_screen.dart';
import 'package:nutritrack/features/profile/bmi_calculator_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutritrack/core/services/user_service.dart';
import 'package:nutritrack/data/reposotories/user_repository.dart';
import 'package:nutritrack/features/auth/login_screen.dart';
import 'package:nutritrack/features/profile/profile_screen.dart';
import 'package:nutritrack/features/meals/meal_screen.dart';
import 'package:nutritrack/features/meals/add_meal_screen.dart';
import 'package:nutritrack/features/meals/meal_edit_card.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/theme_constants.dart';
import 'core/services/storage_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(
          create: (_) => StorageService(prefs),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(auth),
        ),
        Provider<UserRepository>(
          create: (_) => UserRepository(firestore),
        ),
        Provider<MealService>(
          create: (context) => MealService(
            MealRepository(
              context.read<FirebaseFirestore>(),
            ),
          ),
        ),
        Provider<UserService>(
          create: (context) => UserService(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<UserRepository>(context, listen: false),
          ),
        ),
        Provider<FirebaseFirestore>.value(value: firestore),
      ],
      child: const NutriTrackApp(),
    ),
  );
}

class NutriTrackApp extends StatelessWidget {
  const NutriTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeConstants.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => _handleAuthState(context),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => _handleAuthState(context),
        '/profile': (context) => const ProfileScreen(),
        '/meals': (context) => const MealScreen(),
        '/add_meal': (context) => const AddMealScreen(),
        '/meal_statistics': (context) => const MealStatisticsScreen(),
        '/edit_meal': (context) => MealEditCard(
            meal: ModalRoute.of(context)!.settings.arguments as Meal),
        '/bmi_calculator': (context) => const BMICalculatorCard(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments;
          if (args is User) {
            return MaterialPageRoute(
              builder: (context) => HomeScreen(user: args),
            );
          }
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _handleAuthState(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return const LoginScreen();
        }

        // Create a nullable Future<User?> variable
        Future<User?>? userFuture;
        try {
          userFuture = Provider.of<UserService>(context, listen: false)
              .getUser(firebaseUser.uid) as Future<User?>?;
        } catch (e) {
          print('Error setting up user future: $e');
          userFuture = null;
        }

        return FutureBuilder<User?>(
          future: userFuture,
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasData && userSnapshot.data != null) {
              return HomeScreen(user: userSnapshot.data!);
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
