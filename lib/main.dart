import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutritrack/features/Home/home.dart';
import 'package:nutritrack/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutritrack/core/services/user_service.dart'; // Import UserService
import 'package:nutritrack/data/reposotories/user_repository.dart';
import 'package:nutritrack/data/models/user.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/theme_constants.dart';
import 'core/services/storage_service.dart';
import 'features/auth/login_screen.dart';
import 'features/profile/profile_screen.dart';
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
          // Provide UserRepository
          create: (_) => UserRepository(firestore),
        ),
        Provider<UserService>(
          // Provide UserService
          create: (context) => UserService(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<UserRepository>(context, listen: false),
          ),
        ),
        Provider<FirebaseFirestore>.value(value: firestore),
      ],
      child: NutriTrackApp(),
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
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/meals': (context) => MealScreen(),
        '/chat': (context) => ChatScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _handleAuthState(BuildContext context) {
    return StreamBuilder<User?>(
      // Change to StreamBuilder<User?>
      stream: FirebaseAuth.instance
          .authStateChanges()
          .asyncMap((firebaseUser) async {
        if (firebaseUser != null) {
          try {
            final userService =
                Provider.of<UserService>(context, listen: false);
            return await userService
                .getUser(firebaseUser.uid); // Fetch user data
          } catch (e) {
            print('Error fetching user data: $e');
            return null; // Handle error, maybe show an error screen
          }
        }
        return null;
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in and user data is available
          return HomeScreen(
              user: snapshot.data!); // Pass user data to HomeScreen
        } else {
          // User is not logged in or there was an error fetching user data
          return const LoginScreen();
        }
      },
    );
  }
}
