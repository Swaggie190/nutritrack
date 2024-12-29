import 'package:flutter/material.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            color:
                currentIndex == 0 ? ThemeConstants.primaryColor : Colors.grey,
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            color:
                currentIndex == 1 ? ThemeConstants.primaryColor : Colors.grey,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            color:
                currentIndex == 2 ? ThemeConstants.primaryColor : Colors.grey,
            onPressed: () => Navigator.pushReplacementNamed(context, '/meals'),
          ),
        ],
      ),
    );
  }
}
