import 'package:flutter/material.dart';
import '../core/constants/theme_constants.dart';

/// Reusable statistics card widget
/// Used in: Home, Meal Statistics, Profile screens
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? trend; // e.g., "+5%" or "-2%"
  final bool isCompact;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = ThemeConstants.primaryColor,
    this.onTap,
    this.trend,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: ThemeConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
        child: Container(
          padding: EdgeInsets.all(
            isCompact ? ThemeConstants.smallPadding : ThemeConstants.defaultPadding,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeConstants.defaultBorderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: isCompact ? _buildCompactLayout() : _buildExpandedLayout(),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: ThemeConstants.statNumberStyle.copyWith(
            color: color,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: ThemeConstants.statLabelStyle.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (trend != null) ...[
          const SizedBox(height: 4),
          _buildTrendBadge(),
        ],
      ],
    );
  }

  Widget _buildExpandedLayout() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(width: ThemeConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ThemeConstants.statLabelStyle),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: ThemeConstants.statNumberStyle.copyWith(color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trend != null) ...[
                    const SizedBox(width: 8),
                    _buildTrendBadge(),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
      ],
    );
  }

  Widget _buildTrendBadge() {
    final isPositive = trend!.startsWith('+');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPositive
            ? ThemeConstants.successColor.withOpacity(0.2)
            : ThemeConstants.errorColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        trend!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPositive ? ThemeConstants.successColor : ThemeConstants.errorColor,
        ),
      ),
    );
  }
}
