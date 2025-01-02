import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutritrack/data/models/user.dart' as nutritrack_user;
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/services/user_service.dart';
import 'package:nutritrack/widgets/custom_bottom_nav.dart';

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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authSnapshot.hasData && authSnapshot.data != null) {
            final userId = authSnapshot.data!.uid;
            final userService =
                Provider.of<UserService>(context, listen: false);

            return StreamBuilder<nutritrack_user.User?>(
              stream: userService.getUserStream(userId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  return _buildErrorState(context, userSnapshot.error);
                } else if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return _buildNoDataState(context);
                }

                return _buildProfileContent(context, userSnapshot.data!);
              },
            );
          } else {
            return _buildLoggedOutState(context);
          }
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildProfileContent(BuildContext context, nutritrack_user.User user) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(
          ThemeConstants.defaultPadding), // Moved padding here
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: ThemeConstants.primaryColor,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: ThemeConstants.defaultPadding),
            Text('Name: ${user.name}', style: ThemeConstants.bodyStyle),
            Text('Email: ${user.email}', style: ThemeConstants.bodyStyle),
            Text('Height: ${user.height ?? 'N/A'} cm',
                style: ThemeConstants.bodyStyle),
            Text('Weight: ${user.weight ?? 'N/A'} kg',
                style: ThemeConstants.bodyStyle),
            Text(
              'Daily Calorie Goal:\n${user.dailyCalorieGoal ?? 'N/A'} kcal',
              style: ThemeConstants.bodyStyle,
              textAlign: TextAlign.center, // Center the text within its box
            ),
            const SizedBox(height: ThemeConstants.largePadding),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/bmi_calculator');
              },
              child: Text('View BMI', style: ThemeConstants.bodyStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error loading profile: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('User data not found'),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Not logged in'),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }
}
