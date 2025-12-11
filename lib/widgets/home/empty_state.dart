// lib/widgets/home/empty_state.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../theme/colors.dart';

class EmptyState extends StatelessWidget {
  final bool isDark;

  const EmptyState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.darkAccent.withOpacity(0.2),
                          AppColors.darkAccentSecondary.withOpacity(0.1),
                        ]
                      : [
                          AppColors.lightAccent.withOpacity(0.15),
                          AppColors.lightAccentSecondary.withOpacity(0.08),
                        ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 64,
                color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                    duration: 2000.ms, color: Colors.white.withOpacity(0.1))
                .animate()
                .scale(
                    begin: const Offset(0.7, 0.7),
                    duration: 800.ms,
                    curve: Curves.elasticOut)
                .fade(),
            const Gap(32),
            Text(
              'Start Your Journey',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            const Gap(12),
            Text(
              'Capture your thoughts, ideas, and\nmoments in beautiful notes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}
