import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/services/user_service.dart'; // Import UserService
import 'package:nutritrack/data/models/user.dart';
import 'package:nutritrack/widgets/custom_bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/update_user');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await Provider.of<UserService>(context, listen: false)
                    .signOut(context);
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                // Handle logout error if needed.
                print('Logout error: $e');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<firebase_auth.User?>(
        // Use StreamBuilder to listen for auth changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (authSnapshot.hasData && authSnapshot.data != null) {
            final userId = authSnapshot.data!.uid;
            return FutureBuilder<User?>(
              future: Provider.of<UserService>(context, listen: false)
                  .getUser(userId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                } else if (userSnapshot.data == null) {
                  return const Center(
                      child: Text(
                          'User data not found')); // Handle if user data is missing in Firestore
                } else {
                  final user = userSnapshot.data!;
                  return _buildProfileContent(
                      user); // Extract profile content to a separate method
                }
              },
            );
          } else {
            return const Center(
                child:
                    Text('Not logged in')); // Handle if user is not logged in
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildProfileContent(User user) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: ThemeConstants.secondaryColor,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: ThemeConstants.defaultPadding),
          Text('Name: ${user.name}', style: ThemeConstants.bodyStyle),
          Text('Email: ${user.email}', style: ThemeConstants.bodyStyle),
          Text('Height: ${user.height ?? 'N/A'} cm',
              style: ThemeConstants.bodyStyle), // Handle null values
          Text('Weight: ${user.weight ?? 'N/A'} kg',
              style: ThemeConstants.bodyStyle), // Handle null values
          Text('Daily Calorie Goal: ${user.dailyCalorieGoal ?? 'N/A'} kcal',
              style: ThemeConstants.bodyStyle), // Handle null values
          const SizedBox(height: ThemeConstants.largePadding),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.primaryColor),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/bmi_calculator');
            },
            child: const Text('View BMI', style: ThemeConstants.bodyStyle),
          ),
        ],
      ),
    );
  }
}
