import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'dart:ui';
import '../providers/note_provider.dart';
import '../theme/colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/premium_glassmorphic_container.dart';
import '../constants/app_constants.dart';
import '../extensions/date_extensions.dart';
import 'package:intl/intl.dart';
import '../utils/quill_utils.dart';
import 'add_edit_note_screen.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;
  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _deleteController;
  // کنترلرهای جداگانه برای دکمه‌های لایک و پین
  late AnimationController _favController;
  late AnimationController _pinController;

  late ScrollController _scrollController;
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _entryController = AnimationController(
      vsync: this,
      duration: AppConstants.xlDuration,
    )..forward();

    _deleteController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumDuration,
    );

    // تعریف کنترلر مجزا برای دکمه پین
    _pinController = AnimationController(
      vsync: this,
      duration: AppConstants.shortDuration,
    );

    // تعریف کنترلر مجزا برای دکمه لایک
    _favController = AnimationController(
      vsync: this,
      duration: AppConstants.shortDuration,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entryController.dispose();
    _deleteController.dispose();
    _favController.dispose(); // آزادسازی کنترلر لایک
    _pinController.dispose(); // آزادسازی کنترلر پین
    super.dispose();
  }

  void _handlePinTap() {
    HapticFeedback.mediumImpact();
    // استفاده از کنترلر پین
    _pinController.forward().then((_) => _pinController.reverse());
    final noteProvider = context.read<NoteProvider>();
    noteProvider.togglePin(widget.noteId);
  }

  void _handleFavoriteTap() {
    HapticFeedback.mediumImpact();
    // استفاده از کنترلر لایک
    _favController.forward().then((_) => _favController.reverse());
    final noteProvider = context.read<NoteProvider>();
    noteProvider.toggleFavorite(widget.noteId);
  }

  void _handleEditTap() {
    HapticFeedback.lightImpact();
    final noteProvider = context.read<NoteProvider>();
    final note = noteProvider.getNoteById(widget.noteId);
    if (note == null) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => AddEditNoteScreen(note: note),
        transitionDuration: AppConstants.mediumDuration,
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _handleDeleteConfirm() {
    HapticFeedback.heavyImpact();
    context.read<NoteProvider>().deleteNote(widget.noteId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<NoteProvider>(
      builder: (context, noteProvider, _) {
        final note = noteProvider.getNoteById(widget.noteId);

        if (note == null) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
              title: 'Note Not Found',
              showBackButton: true,
              scrollController: _scrollController,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  const Gap(16),
                  Text(
                    'This note no longer exists',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final gradientColors = AppColors
            .noteGradients[note.colorIndex % AppColors.noteGradients.length];

        return PopScope(
          canPop: !_showDeleteConfirm,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && _showDeleteConfirm) {
              setState(() => _showDeleteConfirm = false);
            }
          },
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
              title: '',
              showBackButton: true,
              scrollController: _scrollController,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Row(
                    children: [
                      // دکمه لایک (Favorite)
                      ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 0.92).animate(
                            _favController), // استفاده از _favController
                        child: _ActionButton(
                          icon: note.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          isActive: note.isFavorite,
                          gradientColors: gradientColors,
                          isDark: isDark,
                          onTap: _handleFavoriteTap,
                        ),
                      ),
                      const Gap(10),
                      // دکمه پین (Pin)
                      ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 0.92).animate(
                            _pinController), // استفاده از _pinController
                        child: _ActionButton(
                          icon: note.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.push_pin_outlined,
                          isActive: note.isPinned,
                          gradientColors: gradientColors,
                          isDark: isDark,
                          onTap: _handlePinTap,
                        ),
                      ),
                      const Gap(10),
                      // دکمه ویرایش (Edit)
                      _ActionButton(
                        icon: Icons.edit_rounded,
                        isActive: true, // همیشه فعال
                        gradientColors: gradientColors,
                        isDark: isDark,
                        onTap: _handleEditTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: CustomAppBar.totalHeight(context) + 20,
                left: 24,
                right: 24,
                bottom: 20,
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, note, gradientColors, isDark),
                  const Gap(32),
                  _buildStatCards(context, note, gradientColors, isDark),
                  const Gap(32),
                  _buildContentSection(context, note, gradientColors, isDark),
                  const Gap(36),
                  _buildTimestampSection(context, note, isDark),
                  const Gap(32),
                  if (!_showDeleteConfirm)
                    _buildDeleteButton(context, isDark)
                  else
                    _buildDeleteConfirmation(context, isDark),
                  const Gap(40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, note, List<Color> gradientColors, bool isDark) {
    return FadeTransition(
      opacity: _entryController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _entryController, curve: Curves.easeOutCubic)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Container(
                  width: 5,
                  height: 60 * value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.5 * value),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Gap(18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title.isEmpty ? 'Untitled Note' : note.title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                  ),
                  const Gap(12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          gradientColors[0].withOpacity(0.15),
                          gradientColors[1].withOpacity(0.08),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.microRadius),
                    ),
                    child: Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(note.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: gradientColors[0],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(
      BuildContext context, note, List<Color> gradientColors, bool isDark) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Words',
              value: '${note.wordCount}',
              gradientColors: gradientColors,
              isDark: isDark,
            ),
          ),
          const Gap(14),
          Expanded(
            child: _StatCard(
              label: 'Characters',
              value: '${note.characterCount}',
              gradientColors: gradientColors,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(
      BuildContext context, note, List<Color> gradientColors, bool isDark) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
          CurvedAnimation(
              parent: _entryController,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
        ),
        child: PremiumGlassmorphicContainer(
          gradientColors: gradientColors,
          borderRadius: AppConstants.largeRadius,
          padding: const EdgeInsets.all(26),
          blur: AppConstants.blurLight,
          backgroundStyle: note.backgroundStyle,
          shadows: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.15),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: gradientColors[0].withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          child: note.plainContent.isEmpty
              ? Text(
                  'No content',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary)
                            .withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                        fontSize: 15,
                      ),
                )
              : Text(
                  QuillUtils.extractPlainText(note.content),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                        height: 1.6,
                        fontSize: 15,
                      ),
                ),
        ),
      ),
    );
  }

  Widget _buildTimestampSection(BuildContext context, note, bool isDark) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceSecondary.withOpacity(0.4)
              : AppColors.lightSurfaceSecondary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius + 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _TimestampItem(
                label: 'Created',
                date: note.createdAt,
                isDark: isDark,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: (isDark ? AppColors.darkDivider : AppColors.lightDivider)
                  .withOpacity(0.3),
            ),
            Expanded(
              child: _TimestampItem(
                label: 'Updated',
                date: note.updatedAt,
                isDark: isDark,
                alignRight: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, bool isDark) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() => _showDeleteConfirm = true);
          },
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius - 2),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultRadius - 2),
              border: Border.all(color: Colors.red.withOpacity(0.35), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_outline_rounded,
                    size: 22, color: Colors.red),
                const Gap(10),
                Text(
                  'Delete Note',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteConfirmation(BuildContext context, bool isDark) {
    return PremiumGlassmorphicContainer(
      backgroundColor: isDark
          ? AppColors.darkSurfacePrimary.withOpacity(0.9)
          : AppColors.lightSurfacePrimary.withOpacity(0.9),
      borderRadius: AppConstants.defaultRadius + 2,
      padding: const EdgeInsets.all(24),
      blur: 15,
      shadows: [
        BoxShadow(
          color: Colors.red.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: const Icon(Icons.warning_rounded,
                    size: 24, color: Colors.red),
              ),
              const Gap(14),
              Text(
                'Confirm Deletion',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            'This action cannot be undone. Your note will be permanently deleted.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.7,
                ),
          ),
          const Gap(24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showDeleteConfirm = false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDark ? AppColors.darkText : AppColors.lightText,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.smallRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleDeleteConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.smallRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Delete',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final List<Color> gradientColors;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.isActive,
    required this.gradientColors,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            gradient: isActive ? LinearGradient(colors: gradientColors) : null,
            color: !isActive
                ? (isDark
                    ? AppColors.darkSurfaceSecondary.withOpacity(0.8)
                    : AppColors.lightSurfaceSecondary.withOpacity(0.8))
                : null,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isActive
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
            size: 19,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> gradientColors;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.gradientColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicContainer(
      backgroundColor: isDark
          ? AppColors.darkSurfaceSecondary.withOpacity(0.6)
          : AppColors.lightSurfaceSecondary.withOpacity(0.5),
      borderRadius: AppConstants.defaultRadius + 2,
      padding: const EdgeInsets.all(18),
      showBorder: true,
      blur: 15,
      shadows: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.15)
              : Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
          ),
          const Gap(10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: gradientColors[0],
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
          ),
        ],
      ),
    );
  }
}

class _TimestampItem extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isDark;
  final bool alignRight;

  const _TimestampItem({
    required this.label,
    required this.date,
    required this.isDark,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
        const Gap(8),
        Text(
          date.formattedDateTime,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }
}
