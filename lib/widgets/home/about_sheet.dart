// lib/widgets/home/about_sheet.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';
import '../../theme/colors.dart';

const int maxSeeds = 250;

class AboutSheet extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onBack;

  const AboutSheet({super.key, required this.isDark, this.onBack});

  @override
  State<AboutSheet> createState() => _AboutSheetState();
}

class _AboutSheetState extends State<AboutSheet> {
  int seeds = maxSeeds ~/ 2;

  /// Launch a URL in the browser
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const Gap(20),
            _buildSection(
              title: 'Developer Information',
              icon: Icons.person_outline_rounded,
              children: [
                _buildInfoRow(label: 'Name', value: 'Navid'),
                _buildInfoRow(label: 'Project', value: 'Open Source'),
                _buildInfoRow(label: 'License', value: 'MIT License'),
              ],
              isDark: isDark,
            ),
            const Gap(20),
            _buildSection(
              title: 'Links',
              icon: Icons.link_rounded,
              children: [
                _buildLinkRow(
                  label: 'Website',
                  url: 'https://audito.space',
                  onTap: () => _launchURL('https://audito.space'),
                  isDark: isDark,
                ),
                _buildLinkRow(
                  label: 'Profile',
                  url: 'https://audito.space/accounts/profile/navid/',
                  onTap: () => _launchURL(
                      'https://audito.space/accounts/profile/navid/'),
                  isDark: isDark,
                ),
              ],
              isDark: isDark,
            ),
            const Gap(20),
            _buildSection(
              title: 'Bonus: Sunflower Animation :)',
              icon: Icons.psychology_outlined,
              children: [_buildSunflowerGame(isDark)],
              isDark: isDark,
            ),
            const Gap(20),
            _buildAppInfo(isDark),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  /// Build header with back button and title
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        if (widget.onBack != null)
          IconButton(
            onPressed: widget.onBack,
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 22,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        if (widget.onBack != null) const Gap(8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkAccent.withOpacity(0.15)
                : AppColors.lightAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.info_outline_rounded,
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            size: 20,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }

  /// Build a section with title, icon and children
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            ),
            const Gap(8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
        const Gap(10),
        ...children,
      ],
    );
  }

  /// Build a row displaying label-value information
  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkText
                    : AppColors.lightText,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a clickable link row
  Widget _buildLinkRow({
    required String label,
    required String url,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        url,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build interactive sunflower animation
  Widget _buildSunflowerGame(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceSecondary
            : AppColors.lightSurfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Interactive Sunflower',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const Gap(6),
          Text(
            'Drag the slider to see the pattern change',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(14),
          SizedBox(
            height: 120,
            width: 120,
            child: SunflowerWidget(seeds),
          ),
          const Gap(14),
          Text(
            'Showing ${seeds.round()} seeds',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextTertiary,
            ),
          ),
          Slider(
            min: 1,
            max: maxSeeds.toDouble(),
            value: seeds.toDouble(),
            onChanged: (val) {
              setState(() => seeds = val.round());
            },
            activeColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            inactiveColor:
                isDark ? AppColors.darkDivider : AppColors.lightDivider,
            thumbColor: isDark
                ? AppColors.darkSurfacePrimary
                : AppColors.lightSurfacePrimary,
          ),
        ],
      ),
    );
  }

  /// Build app information section with version details
  Widget _buildAppInfo(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceSecondary
            : AppColors.lightSurfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: const Color(0xFFEC4899),
            size: 24,
          ),
          const Gap(10),
          Text(
            'Made with 🫀 by Navid',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
          ),
          const Gap(4),
          Text(
            'Version: β.1',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

/// Interactive sunflower pattern generator
class SunflowerWidget extends StatelessWidget {
  static const tau = math.pi * 2;
  static const scaleFactor = 1 / 40;
  static const size = 120.0;
  static final phi = (math.sqrt(5) + 1) / 2;
  static final rng = math.Random();

  final int seeds;

  const SunflowerWidget(this.seeds, {super.key});

  @override
  Widget build(BuildContext context) {
    final seedWidgets = <Widget>[];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Active seeds (visible)
    for (var i = 0; i < seeds; i++) {
      final theta = i * tau / phi;
      final r = math.sqrt(i) * scaleFactor;
      seedWidgets.add(
        Positioned(
          left: size / 2 + r * math.cos(theta) * size / 2,
          top: size / 2 - r * math.sin(theta) * size / 2,
          child: Dot(true, isDark: isDark),
        ),
      );
    }

    // Inactive seeds (hidden but present for animation)
    for (var j = seeds; j < maxSeeds; j++) {
      final x = math.cos(tau * j / (maxSeeds - 1)) * 0.9;
      final y = math.sin(tau * j / (maxSeeds - 1)) * 0.9;
      seedWidgets.add(
        Positioned(
          left: size / 2 + x * size / 2,
          top: size / 2 - y * size / 2,
          child: Dot(false, isDark: isDark),
        ),
      );
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            isDark
                ? Colors.orange.withOpacity(0.1)
                : Colors.orange.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: seedWidgets,
      ),
    );
  }
}

/// Sunflower seed dot with adaptive colors based on theme
class Dot extends StatelessWidget {
  static const size = 2.5;
  final bool lit;
  final bool isDark;

  const Dot(this.lit, {super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: lit
            ? (isDark ? Colors.orangeAccent : Colors.orange)
            : (isDark ? Colors.grey.shade700 : Colors.grey.shade500),
        shape: BoxShape.circle,
      ),
    );
  }
}
