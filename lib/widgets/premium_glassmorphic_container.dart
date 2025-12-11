// lib/widgets/premium_glassmorphic_container.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/colors.dart';
import '../constants/app_constants.dart';
import 'package:flutter/gestures.dart';

class PremiumGlassmorphicContainer extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double blur;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final bool showBorder;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final int backgroundStyle;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final BorderRadius? customBorderRadius;
  final bool enableHoverEffect;

  const PremiumGlassmorphicContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.blur = 16,
    this.onTap,
    this.gradientColors,
    this.showBorder = true,
    this.borderWidth = 1,
    this.shadows,
    this.backgroundStyle = 0,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.customBorderRadius,
    this.enableHoverEffect = false,
  });

  @override
  State<PremiumGlassmorphicContainer> createState() =>
      _PremiumGlassmorphicContainerState();
}

class _PremiumGlassmorphicContainerState
    extends State<PremiumGlassmorphicContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: AppConstants.shortDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = true);
    }
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _getBackgroundColor(isDark);
    final borderRadiusGeometry =
        widget.customBorderRadius ?? BorderRadius.circular(widget.borderRadius);

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AppConstants.shortDuration,
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: borderRadiusGeometry,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: Container(
                  decoration:
                      _buildDecoration(isDark, bgColor, borderRadiusGeometry),
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    final baseColor =
        isDark ? AppColors.darkSurfacePrimary : AppColors.lightSurfacePrimary;

    return baseColor.withOpacity(0.85);
  }

  BoxDecoration _buildDecoration(
    bool isDark,
    Color bgColor,
    BorderRadius borderRadius,
  ) {
    return BoxDecoration(
      gradient: _buildGradient(),
      color: widget.backgroundStyle != 2 ? bgColor : null,
      borderRadius: borderRadius,
      border: _buildBorder(isDark),
      boxShadow: _buildShadows(isDark),
    );
  }

  Gradient? _buildGradient() {
    if (widget.backgroundStyle == 2 && widget.gradientColors != null) {
      return LinearGradient(
        begin: widget.gradientBegin,
        end: widget.gradientEnd,
        colors: widget.gradientColors!,
      );
    }
    return null;
  }

  Border? _buildBorder(bool isDark) {
    if (!widget.showBorder) return null;

    final borderOpacity = _isHovered ? 0.15 : 0.1;
    final borderColor = isDark
        ? Colors.white.withOpacity(borderOpacity)
        : Colors.white.withOpacity(borderOpacity + 0.5);

    return Border.all(
      color: borderColor,
      width: widget.borderWidth,
    );
  }

  List<BoxShadow> _buildShadows(bool isDark) {
    if (widget.shadows != null) return widget.shadows!;

    final shadowIntensity = _isHovered ? 1.2 : 1.0;

    return [
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black)
            .withOpacity((isDark ? 0.3 : 0.08) * shadowIntensity),
        blurRadius: 24 * shadowIntensity,
        offset: Offset(0, 8 * shadowIntensity),
      ),
      BoxShadow(
        color: (isDark ? Colors.black : Colors.black)
            .withOpacity((isDark ? 0.15 : 0.04) * shadowIntensity),
        blurRadius: 8 * shadowIntensity,
        offset: Offset(0, 2 * shadowIntensity),
      ),
    ];
  }
}
