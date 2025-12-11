// lib/widgets/premium_search_field.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../constants/app_constants.dart';

class PremiumSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;
  final double height;
  final double borderRadius;

  const PremiumSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search...',
    this.showFilterButton = false,
    this.onFilterTap,
    this.height = 56,
    this.borderRadius = 18,
  });

  @override
  State<PremiumSearchBar> createState() => _PremiumSearchBarState();
}

class _PremiumSearchBarState extends State<PremiumSearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _focusAnimation;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _setupListeners();
    _hasText = widget.controller.text.isNotEmpty;
  }

  void _initializeAnimation() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _focusAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  void _setupListeners() {
    widget.focusNode.addListener(_handleFocus);
    widget.controller.addListener(_handleTextChanged);
  }

  void _handleFocus() {
    final focused = widget.focusNode.hasFocus;
    if (focused == _isFocused) return;

    setState(() => _isFocused = focused);
    focused ? _animController.forward() : _animController.reverse();
  }

  void _handleTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocus);
    widget.controller.removeListener(_handleTextChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: _buildShadowDecoration(accent, isDark),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedContainer(
                duration: AppConstants.shortDuration,
                decoration: _buildContainerDecoration(isDark, accent),
                child: _buildContent(isDark, accent),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildShadowDecoration(Color accent, bool isDark) {
    final progress = _focusAnimation.value;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      boxShadow: [
        BoxShadow(
          color: accent.withOpacity(0.15 * progress),
          blurRadius: 20 + (10 * progress),
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.25)
              : Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  BoxDecoration _buildContainerDecoration(bool isDark, Color accent) {
    return BoxDecoration(
      color: isDark
          ? AppColors.darkSurfaceSecondary.withOpacity(0.9)
          : AppColors.lightSurfacePrimary.withOpacity(0.95),
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: Border.all(
        color: _isFocused
            ? accent.withOpacity(0.5)
            : (isDark
                ? AppColors.darkDivider.withOpacity(0.3)
                : AppColors.lightDivider.withOpacity(0.4)),
        width: _isFocused ? 1.5 : 1,
      ),
    );
  }

  Widget _buildContent(bool isDark, Color accent) {
    return Row(
      children: [
        const SizedBox(width: 16),
        _SearchIcon(isFocused: _isFocused, isDark: isDark, accent: accent),
        const SizedBox(width: 12),
        Expanded(child: _buildTextField(isDark, accent)),
        if (_hasText) _buildClearButton(isDark),
        if (widget.showFilterButton && widget.onFilterTap != null)
          _buildFilterButton(isDark, accent),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTextField(bool isDark, Color accent) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      cursorColor: accent,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(2),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color:
              isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildClearButton(bool isDark) {
    return _ClearButton(
      onTap: () {
        widget.controller.clear();
        widget.onClear?.call();
      },
      isDark: isDark,
    );
  }

  Widget _buildFilterButton(bool isDark, Color accent) {
    return _FilterButton(
      onTap: widget.onFilterTap!,
      isDark: isDark,
      accent: accent,
    );
  }
}

class _SearchIcon extends StatelessWidget {
  final bool isFocused;
  final bool isDark;
  final Color accent;

  const _SearchIcon({
    required this.isFocused,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isFocused ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.1),
          child: Icon(
            Icons.search_rounded,
            color: Color.lerp(
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              accent,
              value,
            ),
            size: 22,
          ),
        );
      },
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _ClearButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkTextTertiary.withOpacity(0.15)
                : AppColors.lightTextTertiary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
    )
        .animate()
        .fade(duration: 200.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  final Color accent;

  const _FilterButton({
    required this.onTap,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(Icons.tune_rounded, size: 18, color: accent),
          ),
        ),
      ),
    );
  }
}
