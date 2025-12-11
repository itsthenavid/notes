// lib/widgets/home/bottom_sheet_container.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../theme/colors.dart';
import '../../constants/app_constants.dart';

class BottomSheetContainer extends StatelessWidget {
  final bool isDark;
  final String title;
  final List<Widget> children;

  const BottomSheetContainer({
    super.key,
    required this.isDark,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppConstants.xlRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfacePrimary.withOpacity(0.95)
                : AppColors.lightSurfacePrimary.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppConstants.xlRadius)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.darkDivider.withOpacity(0.3)
                    : AppColors.lightDivider.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle - فقط در بالاترین سطح
                // اینجا Drag Handle نداریم چون در parent داریم

                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const Gap(16),
                // محتوای اصلی با SingleChildScrollView
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...children,
                        const Gap(20), // فاصله پایین برای Safe Area
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
