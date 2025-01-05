import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutritrack/data/models/user.dart' as nutritrack_user;
import 'package:nutritrack/core/constants/theme_constants.dart';
import 'package:nutritrack/core/services/user_service.dart';
import 'package:nutritrack/widgets/custom_bottom_nav.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile',
            style: ThemeConstants.headingStyle.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/update_user'),
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

      //Get user id in real time
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (authSnapshot.hasData && authSnapshot.data != null) {
            return _buildUserProfileStream(context, authSnapshot.data!.uid);
          }

          return _buildLoggedOutState(context);
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  //This allows for real time update of user informations automatically
  Widget _buildUserProfileStream(BuildContext context, String userId) {
    return StreamBuilder<nutritrack_user.User?>(
      stream: Provider.of<UserService>(context, listen: false)
          .getUserStream(userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userSnapshot.hasError) {
          return _buildErrorState(context, userSnapshot.error);
        }
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return _buildNoDataState(context);
        }

        return _buildProfileContent(context, userSnapshot.data!);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, nutritrack_user.User user) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildProfileHeader(user),
          _buildProfileDetails(user),
          _buildSecuritySection(context, user),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(nutritrack_user.User user) {
    return Container(
      padding: const EdgeInsets.all(ThemeConstants.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeConstants.primaryColor,
            ThemeConstants.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 57,
              backgroundColor: ThemeConstants.secondaryColor,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: ThemeConstants.headingStyle.copyWith(
                  color: Colors.white,
                  fontSize: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: ThemeConstants.defaultPadding),
          Text(
            user.name,
            style: ThemeConstants.headingStyle.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          Text(
            user.email,
            style: ThemeConstants.bodyStyle.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(nutritrack_user.User user) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: ThemeConstants.cardTitleStyle),
          const SizedBox(height: ThemeConstants.defaultPadding),
          _buildInfoCard([
            _buildInfoRow('Height', '${user.height ?? 'N/A'} cm', Icons.height),
            _buildInfoRow(
                'Weight', '${user.weight ?? 'N/A'} kg', Icons.monitor_weight),
            _buildInfoRow('Daily Goal',
                '${user.dailyCalorieGoal ?? 'N/A'} kcal', Icons.track_changes),
          ]),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(
      BuildContext context, nutritrack_user.User user) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Security Settings', style: ThemeConstants.cardTitleStyle),
          const SizedBox(height: ThemeConstants.defaultPadding),
          _buildSecurityCard(context, user),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context, nutritrack_user.User user) {
    return Card(
      elevation: ThemeConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline,
                    color: ThemeConstants.primaryColor, size: 24),
                const SizedBox(width: ThemeConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: ThemeConstants.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last changed: Not available',
                        style: ThemeConstants.bodyStyle.copyWith(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.defaultPadding),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                side: BorderSide(color: ThemeConstants.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(ThemeConstants.defaultBorderRadius),
                ),
              ),
              onPressed: () => _handleResetPassword(context, user.email),
              child: Text(
                'Reset Password',
                style: ThemeConstants.bodyStyle.copyWith(
                  color: ThemeConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetPassword(BuildContext context, String email) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.resetPassword(email);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent to $email',
              style: ThemeConstants.bodyStyle.copyWith(color: Colors.white),
            ),
            backgroundColor: ThemeConstants.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send reset email: ${e.toString()}',
              style: ThemeConstants.bodyStyle.copyWith(color: Colors.white),
            ),
            backgroundColor: ThemeConstants.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: ThemeConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: ThemeConstants.smallPadding),
      child: Row(
        children: [
          Icon(icon, color: ThemeConstants.primaryColor, size: 24),
          const SizedBox(width: ThemeConstants.defaultPadding),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: ThemeConstants.bodyStyle),
                Text(
                  value,
                  style: ThemeConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ThemeConstants.defaultBorderRadius),
              ),
            ),
            onPressed: () => Navigator.pushNamed(context, '/bmi_calculator'),
            child: Text(
              'Calculate BMI',
              style: ThemeConstants.bodyStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error loading profile: $error',
            style: ThemeConstants.bodyStyle
                .copyWith(color: ThemeConstants.errorColor),
          ),
          const SizedBox(height: ThemeConstants.defaultPadding),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
            child: Text('Retry', style: ThemeConstants.bodyStyle),
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
          Text('User data not found', style: ThemeConstants.bodyStyle),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text('Back to Login', style: ThemeConstants.bodyStyle),
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
          Text('Not logged in', style: ThemeConstants.bodyStyle),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text('Go to Login', style: ThemeConstants.bodyStyle),
          ),
        ],
      ),
    );
  }
}
