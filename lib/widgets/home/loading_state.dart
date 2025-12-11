// lib/widgets/home/loading_state.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../theme/colors.dart';

class LoadingState extends StatelessWidget {
  final bool isDark;

  const LoadingState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(
                isDark ? AppColors.darkAccent : AppColors.lightAccent,
              ),
            ),
          ),
          const Gap(24),
          Text(
            'Loading notes...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
