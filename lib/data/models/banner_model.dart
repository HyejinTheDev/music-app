import 'package:flutter/material.dart';

/// Model cho mỗi banner item
class BannerItem {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final List<Color> gradientColors;

  const BannerItem({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.gradientColors,
  });
}
