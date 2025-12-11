// lib/widgets/custom_app_bar.dart
// Final polished Living Glass AppBar
// - zero-gap preferredSize (safe)
// - performant painters & animations
// - premium animated glass back button
// - null-safe, compile-ready

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final ScrollController? scrollController;
  final bool updateStatusBar;
  final Color? backgroundColor;
  final TextStyle? titleStyle;

  /// Visual height excluding status bar
  static const double height = 84.0;

  /// How much scroll (pixels) maps to full glass reveal [0..1]
  static const double _scrollThreshold = 135.0;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.scrollController,
    this.updateStatusBar = true,
    this.backgroundColor,
    this.titleStyle,
  });

  /// Preferred size must reflect the real on-screen height (status bar + height).
  /// We cannot access BuildContext inside getter, so we read platform padding safely.
  @override
  Size get preferredSize {
    final double topPadding = _safeTopPadding();
    return Size.fromHeight(CustomAppBar.height + topPadding);
  }

  static double _safeTopPadding() {
    try {
      // platformDispatcher.views is available in Flutter stable; get first view's padding
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isNotEmpty) {
        return views.first.padding.top;
      }
    } catch (_) {
      // fallback
    }
    return 0.0;
  }

  /// Convenience for runtime use with context
  static double totalHeight(BuildContext context) =>
      height + MediaQuery.of(context).padding.top;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  final ValueNotifier<double> _scrollProgress = ValueNotifier<double>(0.0);

  late final AnimationController _auroraController;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());

    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _scrollProgress.dispose();
    _auroraController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final sc = widget.scrollController;
    if (sc == null || !sc.hasClients) return;

    final offset = sc.offset;
    final raw = (offset / CustomAppBar._scrollThreshold).clamp(0.0, 1.0);
    // let the UI animate smoothing; store raw value (still uses easing when building)
    final eased = Curves.easeOutCubic.transform(raw);
    if (_scrollProgress.value != eased) {
      _scrollProgress.value = eased;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double topPadding = MediaQuery.of(context).padding.top;

    // update status bar style if requested
    if (widget.updateStatusBar) {
      final overlay =
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
      SystemChrome.setSystemUIOverlayStyle(
        overlay.copyWith(statusBarColor: Colors.transparent),
      );
    }

    return SizedBox(
      height: CustomAppBar.height + topPadding,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          // Living glass background (fills whole area including status bar)
          Positioned.fill(
            child: ValueListenableBuilder<double>(
              valueListenable: _scrollProgress,
              builder: (context, progress, _) {
                // use a tiny tween inside the layer builder for smoother visual interpolation
                final visualProgress = progress.clamp(0.0, 1.0);
                return _LivingGlassLayer(
                  isDark: isDark,
                  progress: visualProgress,
                  auroraCtrl: _auroraController,
                  shimmerCtrl: _shimmerController,
                );
              },
            ),
          ),

          // Foreground content: placed at topPadding and with fixed height
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            height: CustomAppBar.height,
            child: _GlassContent(
              isDark: isDark,
              showBackButton: widget.showBackButton,
              onBackPressed: widget.onBackPressed,
              title: widget.title,
              titleStyle: widget.titleStyle,
              actions: widget.actions,
              scrollProgress: _scrollProgress,
            ),
          ),
        ],
      ),
    );
  }
}

/* --------------------------------------------------------------------------
   Living glass layer: frosted background, aurora painter and rim highlight.
   Avoids heavy blur if progress is nearly zero.
   -------------------------------------------------------------------------- */
class _LivingGlassLayer extends StatelessWidget {
  final bool isDark;
  final double progress; // [0..1]
  final AnimationController auroraCtrl;
  final AnimationController shimmerCtrl;

  const _LivingGlassLayer({
    required this.isDark,
    required this.progress,
    required this.auroraCtrl,
    required this.shimmerCtrl,
  });

  @override
  Widget build(BuildContext context) {
    // Keep a faint presence at very small progress to avoid snapping.
    final visible = progress > 0.01;
    final double blur = (progress < 0.02) ? 0.0 : 28.0 * progress;
    final double radius = 28.0 * progress;

    return AnimatedOpacity(
      opacity: visible ? progress.clamp(0.0, 1.0) : 0.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            // Slightly adapt base tint with progress for depth.
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white)
                  .withOpacity(0.13 * (0.6 + progress * 0.4)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // Aurora blobs behind glass
                AnimatedBuilder(
                  animation: auroraCtrl,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _AuroraPainter(
                        animationValue: auroraCtrl.value,
                        isDark: isDark,
                        opacity: progress * 0.55,
                      ),
                    );
                  },
                ),

                // Depth gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              Colors.black.withOpacity(0.08),
                              Colors.black.withOpacity(0.58),
                            ]
                          : [
                              Colors.white.withOpacity(0.36),
                              Colors.white.withOpacity(0.78),
                            ],
                    ),
                  ),
                ),

                // Rotating rim shimmer
                AnimatedBuilder(
                  animation: shimmerCtrl,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _DynamicRimPainter(
                        isDark: isDark,
                        opacity: progress,
                        rotation: shimmerCtrl.value * math.pi * 2.0,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* --------------------------------------------------------------------------
   Aurora painter — large blurred colored blobs that animate.
   Keep shouldRepaint conservative.
   -------------------------------------------------------------------------- */
class _AuroraPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  final double opacity;

  _AuroraPainter({
    required this.animationValue,
    required this.isDark,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.001) return;

    final Paint paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final Color c1 = isDark ? Colors.blueAccent : Colors.blue.shade300;
    final Color c2 = isDark ? Colors.purpleAccent : Colors.purple.shade300;
    final Color c3 = isDark ? Colors.pinkAccent : Colors.pink.shade200;

    final double x = animationValue * 2.0 * math.pi;

    final Offset o1 = Offset(
      size.width * 0.2 + math.sin(x) * size.width * 0.35,
      size.height * 0.5 + math.cos(x) * size.height * 0.25,
    );
    final Offset o2 = Offset(
      size.width * 0.8 - math.sin(x) * size.width * 0.35,
      size.height * 0.4 - math.cos(x) * size.height * 0.25,
    );
    final Offset o3 = Offset(
      size.width * 0.5 + math.cos(x * 1.5) * size.width * 0.25,
      size.height * 0.6 + math.sin(x * 1.5) * size.height * 0.2,
    );

    paint.color = c1.withOpacity(0.17 * opacity);
    canvas.drawCircle(o1, size.width * 0.42, paint);

    paint.color = c2.withOpacity(0.15 * opacity);
    canvas.drawCircle(o2, size.width * 0.34, paint);

    paint.color = c3.withOpacity(0.12 * opacity);
    canvas.drawCircle(o3, size.width * 0.25, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.animationValue != animationValue ||
      old.opacity != opacity ||
      old.isDark != isDark;
}

/* --------------------------------------------------------------------------
   Rotating rim highlight painter
   -------------------------------------------------------------------------- */
class _DynamicRimPainter extends CustomPainter {
  final bool isDark;
  final double opacity;
  final double rotation;

  _DynamicRimPainter({
    required this.isDark,
    required this.opacity,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.001) return;

    final Rect rect = Offset.zero & size;
    final RRect rr = RRect.fromRectAndCorners(
      rect,
      bottomLeft: Radius.circular(28.0 * opacity),
      bottomRight: Radius.circular(28.0 * opacity),
    );

    final Paint sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.55 * opacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(rect);

    canvas.drawRRect(rr, sweepPaint);

    final Paint bottomPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          (isDark ? Colors.white : Colors.black).withOpacity(0.22 * opacity),
        ],
      ).createShader(rect);

    canvas.drawRRect(rr.deflate(0.5), bottomPaint);
  }

  @override
  bool shouldRepaint(covariant _DynamicRimPainter old) =>
      old.rotation != rotation ||
      old.opacity != opacity ||
      old.isDark != isDark;
}

/* --------------------------------------------------------------------------
   Foreground / content row: back button, title, actions
   -------------------------------------------------------------------------- */
class _GlassContent extends StatelessWidget {
  final bool isDark;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String title;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final ValueNotifier<double> scrollProgress;

  const _GlassContent({
    required this.isDark,
    required this.showBackButton,
    required this.onBackPressed,
    required this.title,
    required this.titleStyle,
    required this.actions,
    required this.scrollProgress,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20.0);

    return Padding(
      padding: padding,
      child: SizedBox(
        height: CustomAppBar.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (showBackButton) ...[
              _AnimatedBackButton(
                isDark: isDark,
                onTap: onBackPressed ?? () => Navigator.maybePop(context),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: scrollProgress,
                builder: (context, progress, _) => _ChromaticTitle(
                  title: title,
                  isDark: isDark,
                  style: titleStyle,
                  progress: progress,
                  showBackButton: showBackButton,
                ),
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}

/* --------------------------------------------------------------------------
   Chromatic title effect while appearing
   -------------------------------------------------------------------------- */
class _ChromaticTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  final TextStyle? style;
  final double progress;
  final bool showBackButton;

  const _ChromaticTitle({
    required this.title,
    required this.isDark,
    required this.progress,
    required this.showBackButton,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle base = style ??
        TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : Colors.black,
        );

    final double opacity =
        showBackButton ? (progress - 0.15).clamp(0.0, 1.0) : 1.0;

    if (opacity >= 0.98) {
      return Opacity(
        opacity: opacity,
        child: Text(title,
            style: base, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    }

    final double split = (1.0 - opacity) * 3.0;

    return Stack(
      children: <Widget>[
        Transform.translate(
          offset: Offset(-split, 0),
          child: Text(title,
              style:
                  base.copyWith(color: Colors.red.withOpacity(0.4 * opacity))),
        ),
        Transform.translate(
          offset: Offset(split, 0),
          child: Text(title,
              style:
                  base.copyWith(color: Colors.cyan.withOpacity(0.4 * opacity))),
        ),
        Opacity(
            opacity: opacity,
            child: Text(title,
                style: base, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

/* --------------------------------------------------------------------------
   Premium animated glass back button
   - scale on press
   - backdrop blur that intensifies on press
   - haptic feedback
   -------------------------------------------------------------------------- */
class _AnimatedBackButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedBackButton({required this.isDark, required this.onTap});

  @override
  State<_AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<_AnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _blurStrength;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 160), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _blurStrength = Tween<double>(begin: 6.0, end: 12.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    // Use GestureDetector with MaterialInkWell-like hit area behavior
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: widget.isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
                border: Border.all(
                  color: Colors.white.withOpacity(widget.isDark ? 0.06 : 0.08),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(widget.isDark ? 0.25 : 0.08),
                    blurRadius: 4.0 + (_ctrl.value * 6.0),
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: _blurStrength.value * 0.6,
                      sigmaY: _blurStrength.value * 0.6),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18.0,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
