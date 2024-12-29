import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nutritrack/widgets/custom_bottom_nav.dart';
import '../../core/constants/theme_constants.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Implement menu action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.defaultPadding),
        child: Column(
          children: [
            Card(
              child: SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 30,
                        title: 'Breakfast',
                        color: Colors.blue,
                      ),
                      PieChartSectionData(
                        value: 35,
                        title: 'Lunch',
                        color: Colors.green,
                      ),
                      PieChartSectionData(
                        value: 35,
                        title: 'Dinner',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Add more statistics widgets here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () => Navigator.pushNamed(context, '/chat'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
