import 'package:flutter/material.dart';
import 'package:nutritrack/core/constants/theme_constants.dart';

class ServiceUnavailable extends StatelessWidget {
  const ServiceUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Service Unavailable',
        style: ThemeConstants.subheadingStyle,
      ),
      content: Text(
        'This service is not yet available. Please check back later!',
        style: ThemeConstants.bodyStyle,
      ),
      actions: [
        TextButton(
          child: Text(
            'OK',
            style: ThemeConstants.bodyStyle.copyWith(
              color: ThemeConstants.primaryColor,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
