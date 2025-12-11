// lib/widgets/enhanced_note_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'dart:ui';
import '../models/note_model.dart';
import '../theme/colors.dart';
import '../utils/quill_utils.dart';
import '../utils/haptic_manager.dart';
import '../utils/animation_presets.dart';
import '../constants/app_constants.dart';

class EnhancedNoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPin;
  final VoidCallback? onLongPress;
  final int index;
  final bool isSelectionMode;
  final bool isSelected;

  const EnhancedNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onPin,
    this.onLongPress,
    required this.index,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  State<EnhancedNoteCard> createState() => _EnhancedNoteCardState();
}

class _EnhancedNoteCardState extends State<EnhancedNoteCard>
    with TickerProviderStateMixin {
  late final AnimationController _pressController;
  late final AnimationController _selectionController;
  late final Animation<double> _scaleAnimation;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pressController = AnimationPresets.createController(
      vsync: this,
      duration: AppConstants.shortDuration,
    );

    _selectionController = AnimationPresets.createController(
      vsync: this,
      duration: AppConstants.mediumDuration,
    );

    _scaleAnimation = AnimationPresets.buttonPress(_pressController);
  }

  @override
  void didUpdateWidget(EnhancedNoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      widget.isSelected
          ? _selectionController.forward()
          : _selectionController.reverse();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    HapticManager.buttonLongPress();
    if (widget.onLongPress != null) {
      widget.onLongPress!();
    } else {
      setState(() => _showActions = !_showActions);
    }
  }

  void _handleTap() {
    HapticManager.buttonPress();
    widget.onTap();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = _getGradientColors();
    final primaryColor = gradientColors[0];

    return AnimatedBuilder(
      animation: Listenable.merge([_pressController, _selectionController]),
      builder: (context, child) {
        final selectionProgress = _selectionController.value;
        final scaleValue =
            _scaleAnimation.value * (1.0 - selectionProgress * 0.02);

        return Transform.scale(
          scale: scaleValue,
          child: Container(
            decoration: _buildContainerDecoration(
              primaryColor,
              selectionProgress,
              isDark,
            ),
            child: Material(
              color: Colors.transparent,
              child: _buildInkWell(isDark, gradientColors),
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: widget.index * 50),
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.1,
          duration: 450.ms,
          delay: Duration(milliseconds: widget.index * 50),
          curve: Curves.easeOutCubic,
        );
  }

  List<Color> _getGradientColors() {
    return AppColors
        .noteGradients[widget.note.colorIndex % AppColors.noteGradients.length];
  }

  BoxDecoration _buildContainerDecoration(
    Color primaryColor,
    double selectionProgress,
    bool isDark,
  ) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppConstants.largeRadius),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.12 + selectionProgress * 0.2),
          blurRadius: 24 + selectionProgress * 16,
          offset: const Offset(0, 8),
          spreadRadius: selectionProgress * 4,
        ),
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildInkWell(bool isDark, List<Color> gradientColors) {
    return InkWell(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      borderRadius: BorderRadius.circular(AppConstants.largeRadius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: _buildCardDecoration(isDark, gradientColors),
            child: Stack(
              children: [
                _BackgroundDecorations(
                  gradientColors: gradientColors,
                  isDark: isDark,
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        note: widget.note,
                        gradientColors: gradientColors,
                        isDark: isDark,
                      ),
                      const Gap(12),
                      Expanded(
                        child: _Content(
                          note: widget.note,
                          showActions: _showActions,
                          isSelectionMode: widget.isSelectionMode,
                          isDark: isDark,
                          onPin: _handlePinAction,
                          onDelete: _handleDeleteAction,
                          gradientColors: gradientColors,
                        ),
                      ),
                      _Footer(
                        note: widget.note,
                        gradientColors: gradientColors,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                if (widget.isSelected)
                  _SelectionIndicator(gradientColors: gradientColors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePinAction() {
    HapticManager.toggleSwitch();
    widget.onPin();
    setState(() => _showActions = false);
  }

  void _handleDeleteAction() {
    HapticManager.deleteAction();
    widget.onDelete();
    setState(() => _showActions = false);
  }

  BoxDecoration _buildCardDecoration(bool isDark, List<Color> gradientColors) {
    return BoxDecoration(
      color: widget.note.backgroundStyle != 2
          ? (isDark
              ? AppColors.darkSurfacePrimary.withOpacity(0.9)
              : AppColors.lightSurfacePrimary.withOpacity(0.95))
          : null,
      gradient: widget.note.backgroundStyle == 2
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withOpacity(0.9),
                gradientColors[1].withOpacity(0.85),
              ],
            )
          : null,
      borderRadius: BorderRadius.circular(AppConstants.largeRadius),
      border: Border.all(
        color: widget.isSelected
            ? gradientColors[0].withOpacity(0.8)
            : (isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.5)),
        width: widget.isSelected ? 2 : 1,
      ),
    );
  }
}

class _BackgroundDecorations extends StatelessWidget {
  final List<Color> gradientColors;
  final bool isDark;

  const _BackgroundDecorations({
    required this.gradientColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: _DecorativeCircle(
            size: 100,
            colors: [
              gradientColors[0].withOpacity(0.15),
              gradientColors[0].withOpacity(0.0),
            ],
          ),
        ),
        Positioned(
          bottom: -25,
          left: -25,
          child: _DecorativeCircle(
            size: 80,
            colors: [
              gradientColors[1].withOpacity(0.1),
              gradientColors[1].withOpacity(0.0),
            ],
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _DecorativeCircle({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Note note;
  final List<Color> gradientColors;
  final bool isDark;

  const _Header({
    required this.note,
    required this.gradientColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AccentBar(colors: gradientColors),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NoteTitle(
                title: note.title,
                isDark: isDark,
              ),
              if (note.isPinned) ...[
                const Gap(6),
                _PinnedBadge(color: gradientColors[0]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AccentBar extends StatelessWidget {
  final List<Color> colors;

  const _AccentBar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _NoteTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _NoteTitle({
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.isEmpty ? 'Untitled' : title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
    );
  }
}

class _PinnedBadge extends StatelessWidget {
  final Color color;

  const _PinnedBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.push_pin_rounded, size: 10, color: color),
          const Gap(4),
          Text(
            'Pinned',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Note note;
  final bool showActions;
  final bool isSelectionMode;
  final bool isDark;
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final List<Color> gradientColors;

  const _Content({
    required this.note,
    required this.showActions,
    required this.isSelectionMode,
    required this.isDark,
    required this.onPin,
    required this.onDelete,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    if (showActions && !isSelectionMode) {
      return _ActionsView(
        note: note,
        onPin: onPin,
        onDelete: onDelete,
        gradientColors: gradientColors,
      );
    }

    return _PreviewText(
      content: note.content,
      isDark: isDark,
      isSelectionMode: isSelectionMode,
    );
  }
}

class _ActionsView extends StatelessWidget {
  final Note note;
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final List<Color> gradientColors;

  const _ActionsView({
    required this.note,
    required this.onPin,
    required this.onDelete,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          onPressed: onPin,
          icon:
              note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
          label: note.isPinned ? 'Unpin' : 'Pin',
          color: gradientColors[0],
        ),
        const Gap(8),
        _ActionButton(
          onPressed: onDelete,
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: Colors.red,
        ),
      ],
    );
  }
}

class _PreviewText extends StatelessWidget {
  final String content;
  final bool isDark;
  final bool isSelectionMode;

  const _PreviewText({
    required this.content,
    required this.isDark,
    required this.isSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: QuillUtils.getPreviewRichText(
        content,
        baseStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)
                  .withOpacity(isSelectionMode ? 0.5 : 1.0),
              height: 1.5,
            ),
      ),
      maxLines: AppConstants.previewLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationPresets.createController(
      vsync: this,
      duration: AppConstants.shortDuration,
    );
    _scaleAnimation = AnimationPresets.buttonPress(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: Material(
          color: widget.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: _handlePress,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 16, color: widget.color),
                const Gap(6),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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

class _Footer extends StatelessWidget {
  final Note note;
  final List<Color> gradientColors;
  final bool isDark;

  const _Footer({
    required this.note,
    required this.gradientColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: isDark
              ? AppColors.darkDivider.withOpacity(0.2)
              : AppColors.lightDivider.withOpacity(0.3),
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimestampChip(
              date: note.updatedAt,
              isDark: isDark,
            ),
            _WordCountChip(
              count: note.wordCount,
              color: gradientColors[0],
            ),
          ],
        ),
      ],
    );
  }
}

class _TimestampChip extends StatelessWidget {
  final DateTime date;
  final bool isDark;

  const _TimestampChip({
    required this.date,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 12,
          color:
              isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
        const Gap(4),
        Text(
          _formatDate(date),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }
}

class _WordCountChip extends StatelessWidget {
  final int count;
  final Color color;

  const _WordCountChip({
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$count words',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final List<Color> gradientColors;

  const _SelectionIndicator({required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 14,
      right: 14,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
