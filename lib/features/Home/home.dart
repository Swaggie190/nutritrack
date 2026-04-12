import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutritrack/features/Home/health_tip.dart';
import 'package:nutritrack/features/Home/health_tips_data.dart';
import 'package:nutritrack/widgets/custom_bottom_nav.dart';
import 'package:nutritrack/widgets/service_unavailable_dialog.dart';
import '../../core/constants/theme_constants.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HealthTip currentTip;
  String userName =
      'User'; //default userName if the actual name could not be fetched
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectDailyTip();
    _loadUserName();
  }

  //fetching user name from firebase
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

  //Selecting the Health tip message randomly depending on the day
  void _selectDailyTip() {
    final today = DateTime.now().day;
    final tipIndex = today % HealthTipsData.tips.length;
    currentTip = HealthTipsData.tips[tipIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName,
            style: ThemeConstants.headingStyle.copyWith(color: Colors.white)),
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
      body: Column(
        children: [
          // Modern Welcome Banner with Gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeConstants.primaryColor,
                  ThemeConstants.primaryColor.withValues(alpha: 0.8),
                  ThemeConstants.secondaryColor.withValues(alpha: 0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeConstants.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 40,
                            width: 40,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.restaurant_menu,
                                    size: 40, color: ThemeConstants.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back! 👋',
                                style: ThemeConstants.bodyStyle.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userName,
                                style: ThemeConstants.headingStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Grid (Improved Layout)
                  Text(
                    'Quick Actions',
                    style: ThemeConstants.subheadingStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.4,
                    children: [
                      _buildModernActionCard(
                        context,
                        'Track Meal',
                        Icons.restaurant_menu,
                        ThemeConstants.primaryColor,
                        () => Navigator.pushNamed(context, '/add_meal'),
                      ),
                      _buildModernActionCard(
                        context,
                        'View Meals',
                        Icons.list_alt,
                        ThemeConstants.secondaryColor,
                        () => Navigator.pushNamed(context, '/meals'),
                      ),
                      _buildModernActionCard(
                        context,
                        'BMI Calculator',
                        Icons.monitor_weight,
                        ThemeConstants.warningColor,
                        () => Navigator.pushNamed(context, '/bmi_calculator'),
                      ),
                      _buildModernActionCard(
                        context,
                        'Restaurants',
                        Icons.restaurant,
                        ThemeConstants.successColor,
                        () => Navigator.pushNamed(context, '/restaurants'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Daily Health Tip Card (Modern Design)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ThemeConstants.primaryColor.withValues(alpha: 0.1),
                          ThemeConstants.secondaryColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeConstants.primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ThemeConstants.primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline,
                                  color: ThemeConstants.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Daily Health Tip',
                                style: ThemeConstants.cardTitleStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: ThemeConstants.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentTip.message,
                            style: ThemeConstants.bodyStyle.copyWith(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                          if (currentTip.source != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              '— ${currentTip.source}',
                              style: ThemeConstants.statLabelStyle.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Old Quick Actions (Hidden, kept for compatibility)
                  Visibility(
                    visible: false,
                    child: Column(
                      children: [
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
                                    () => Navigator.pushNamed(
                                        context, '/bmi_calculator'),
                                  ),
                                  const SizedBox(
                                      width: ThemeConstants.smallPadding),
                                  _buildQuickActionCard(
                                    context,
                                    'Nearby\nRestaurants',
                                    Icons.restaurant,
                                    ThemeConstants.successColor,
                                    () => Navigator.pushNamed(
                                        context, '/restaurants'),
                                    //_showServiceUnavailableDialog,
                                  ),
                                  const SizedBox(
                                      width: ThemeConstants.smallPadding),
                                  _buildQuickActionCard(
                                    context,
                                    'Find\nDietitian',
                                    Icons.local_hospital,
                                    ThemeConstants.errorColor,
                                    () => showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const ServiceUnavailable(),
                                    ),
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
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeConstants.primaryColor,
        child: const Icon(Icons.support_agent),
        onPressed: () => Navigator.pushNamed(context, '/chat'),
      ),
      //Buttom Navbar
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildModernActionCard(BuildContext context, String title,
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: ThemeConstants.bodyStyle.copyWith(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
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
