import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutritrack/features/Home/health_tip.dart';
import 'package:nutritrack/features/Home/health_tips_data.dart';
import 'package:nutritrack/widgets/custom_bottom_nav.dart';
import '../../core/constants/theme_constants.dart';
import '../../core/constants/app_constants.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HealthTip currentTip;
  String userName = 'User';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectDailyTip();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          setState(() {
            userName = user.displayName!.split(' ')[0];
          });
        } else {
          final userDoc =
              await _firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists && userDoc.data()?['name'] != null) {
            setState(() {
              userName =
                  userDoc.data()?['name'].toString().split(' ')[0] ?? 'User';
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading user name: $e');
      }
    }
  }

  void _selectDailyTip() {
    final today = DateTime.now().day;
    final tipIndex = today % HealthTipsData.tips.length;
    currentTip = HealthTipsData.tips[tipIndex];
  }

  void _showServiceUnavailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Service Unavailable',
              style: ThemeConstants.subheadingStyle),
          content: Text(
            'This service is not yet available. Please check back later!',
            style: ThemeConstants.bodyStyle,
          ),
          actions: [
            TextButton(
              child: Text('OK',
                  style: ThemeConstants.bodyStyle.copyWith(
                    color: ThemeConstants.primaryColor,
                  )),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  break;
                case 'profile':
                  Navigator.pushReplacementNamed(context, '/profile');
                  break;
                case 'help':
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text('Settings', style: ThemeConstants.bodyStyle),
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Profile', style: ThemeConstants.bodyStyle),
                ),
              ),
              PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: const Icon(Icons.help),
                  title: Text('Help', style: ThemeConstants.bodyStyle),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $userName! 👋',
              style: ThemeConstants.headingStyle,
            ),
            const SizedBox(height: ThemeConstants.defaultPadding),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Health Tip Card
                    Card(
                      elevation: ThemeConstants.defaultElevation,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(ThemeConstants.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb,
                                    color: ThemeConstants.primaryColor,
                                    size: 24),
                                const SizedBox(
                                    width: ThemeConstants.smallPadding),
                                Text('Daily Health Tip',
                                    style: ThemeConstants.cardTitleStyle),
                              ],
                            ),
                            const SizedBox(height: ThemeConstants.smallPadding),
                            Text(currentTip.message,
                                style: ThemeConstants.bodyStyle),
                            if (currentTip.source != null) ...[
                              const SizedBox(
                                  height: ThemeConstants.smallPadding),
                              Text(
                                'Source: ${currentTip.source}',
                                style: ThemeConstants.statLabelStyle,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: ThemeConstants.defaultPadding),

                    // Quick Actions Section
                    Card(
                      elevation: ThemeConstants.defaultElevation,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(ThemeConstants.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quick Actions',
                                style: ThemeConstants.cardTitleStyle),
                            const SizedBox(
                                height: ThemeConstants.defaultPadding),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildQuickActionCard(
                                    context,
                                    'Track Meal',
                                    Icons.restaurant_menu,
                                    ThemeConstants.primaryColor,
                                    () => Navigator.pushReplacementNamed(
                                        context, '/meals'),
                                  ),
                                  const SizedBox(
                                      width: ThemeConstants.smallPadding),
                                  _buildQuickActionCard(
                                    context,
                                    'Check BMI',
                                    Icons.monitor_weight,
                                    ThemeConstants.secondaryColor,
                                    () => Navigator.pushReplacementNamed(
                                        context, '/bmi_calculator'),
                                  ),
                                  const SizedBox(
                                      width: ThemeConstants.smallPadding),
                                  _buildQuickActionCard(
                                    context,
                                    'Set Goals',
                                    Icons.flag,
                                    ThemeConstants.warningColor,
                                    () {},
                                  ),
                                  const SizedBox(
                                      width: ThemeConstants.smallPadding),
                                  _buildQuickActionCard(
                                    context,
                                    'Nearby\nRestaurants',
                                    Icons.restaurant,
                                    ThemeConstants.successColor,
                                    _showServiceUnavailableDialog,
                                  ),
                                  const SizedBox(
                                      width: ThemeConstants.smallPadding),
                                  _buildQuickActionCard(
                                    context,
                                    'Find\nDietitian',
                                    Icons.local_hospital,
                                    ThemeConstants.errorColor,
                                    _showServiceUnavailableDialog,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeConstants.primaryColor,
        child: const Icon(Icons.support_agent),
        onPressed: () => Navigator.pushNamed(context, '/chat'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title,
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(ThemeConstants.defaultBorderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: ThemeConstants.smallPadding),
            Text(
              title,
              style: ThemeConstants.bodyStyle.copyWith(
                color: color.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
