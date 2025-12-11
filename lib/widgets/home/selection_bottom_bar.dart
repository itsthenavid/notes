// lib/widgets/home/selection_bottom_bar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../theme/colors.dart';
import '../../constants/app_constants.dart';

class SelectionBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final bool allPinned;
  final bool isDark;

  const SelectionBottomBar({
    super.key,
    required this.selectedCount,
    required this.onPin,
    required this.onDelete,
    required this.allPinned,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppConstants.xlRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfacePrimary.withOpacity(0.95)
                : AppColors.lightSurfacePrimary.withOpacity(0.95),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.darkDivider.withOpacity(0.3)
                    : AppColors.lightDivider.withOpacity(0.5),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: _BottomBarButton(
                    icon: allPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    label: allPinned ? 'Unpin' : 'Pin',
                    color:
                        isDark ? AppColors.darkAccent : AppColors.lightAccent,
                    onPressed: onPin,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _BottomBarButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: const Color(0xFFEF4444),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.5);
  }
}

class _BottomBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _BottomBarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const Gap(8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
