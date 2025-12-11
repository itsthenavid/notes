// lib/widgets/home/sort_option.dart

import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class SortOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const SortOption({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isSelected
            ? accent
            : (isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? accent : null,
        ),
      ),
      trailing:
          isSelected ? Icon(Icons.check_circle_rounded, color: accent) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
