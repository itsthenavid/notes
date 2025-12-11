// lib/utils/home_dialogs.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../widgets/home/bottom_sheet_container.dart';
import '../widgets/home/sort_option.dart';
import '../widgets/home/delete_dialog.dart';
import '../widgets/home/about_sheet.dart';
import '../constants/app_constants.dart';
import '../theme/colors.dart';
import 'dart:ui';

class HomeDialogs {
  /// Show sorting options bottom sheet
  static void showSortMenu(BuildContext context, bool isDark) {
    final provider = context.read<NoteProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetContainer(
        isDark: isDark,
        title: 'Sort By',
        children: _buildSortOptions(provider, context, isDark),
      ),
    );
  }

  /// Show filtering options bottom sheet
  static void showFilterSheet(BuildContext context, bool isDark) {
    final provider = context.read<NoteProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetContainer(
        isDark: isDark,
        title: 'Filter Notes',
        children: _buildFilterOptions(provider, context, isDark),
      ),
    );
  }

  /// Show more options menu with smooth transitions between views
  static void showMoreMenu(BuildContext context, bool isDark,
      Function(String, IconData) showSnackBar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _MoreMenuSheet(
          isDark: isDark,
          showSnackBar: showSnackBar,
        );
      },
    );
  }

  /// Show delete confirmation dialog for a single note
  static void showDeleteDialog(
    BuildContext context,
    bool isDark,
    String noteId,
    Function(String, IconData) showSnackBar,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete Note?',
        message:
            'This action cannot be undone. Your note will be permanently deleted.',
        onDelete: () {
          context.read<NoteProvider>().deleteNote(noteId);
          Navigator.pop(context);
          showSnackBar('Note deleted', Icons.delete_rounded);
        },
        isDark: isDark,
      ),
    );
  }

  /// Show delete confirmation dialog for multiple selected notes
  static void showBatchDeleteDialog(
    BuildContext context,
    bool isDark,
    int selectedCount,
    VoidCallback onDelete,
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'Delete $selectedCount Notes?',
        message:
            'This action cannot be undone. All selected notes will be permanently deleted.',
        onDelete: () {
          Navigator.pop(context);
          onDelete();
        },
        isDark: isDark,
      ),
    );
  }

  /// Build sort options for the sort menu
  static List<Widget> _buildSortOptions(
      NoteProvider provider, BuildContext context, bool isDark) {
    return [
      SortOption(
        title: 'Most Recent',
        icon: Icons.schedule_rounded,
        isSelected: provider.sortOrder == SortOrder.newest,
        onTap: () {
          HapticFeedback.selectionClick();
          provider.setSortOrder(SortOrder.newest);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
      SortOption(
        title: 'Oldest First',
        icon: Icons.history_rounded,
        isSelected: provider.sortOrder == SortOrder.oldest,
        onTap: () {
          HapticFeedback.selectionClick();
          provider.setSortOrder(SortOrder.oldest);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
      SortOption(
        title: 'Alphabetical',
        icon: Icons.sort_by_alpha_rounded,
        isSelected: provider.sortOrder == SortOrder.alphabetical,
        onTap: () {
          HapticFeedback.selectionClick();
          provider.setSortOrder(SortOrder.alphabetical);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
      SortOption(
        title: 'Word Count',
        icon: Icons.text_fields_rounded,
        isSelected: provider.sortOrder == SortOrder.wordCount,
        onTap: () {
          HapticFeedback.selectionClick();
          provider.setSortOrder(SortOrder.wordCount);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
    ];
  }

  /// Build filter options for the filter menu
  static List<Widget> _buildFilterOptions(
      NoteProvider provider, BuildContext context, bool isDark) {
    return [
      SortOption(
        title: 'All Notes',
        icon: Icons.note_rounded,
        isSelected: provider.filterType == FilterType.all,
        onTap: () {
          HapticFeedback.selectionClick();
          provider.setFilterType(FilterType.all);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
      SortOption(
        title: 'Pinned',
        icon: Icons.push_pin_rounded,
        isSelected: provider.filterType == FilterType.pinned,
        onTap: () {
          HapticFeedback.selectionClick();
          provider.setFilterType(FilterType.pinned);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
      SortOption(
        title: 'Favorites',
        icon: Icons.favorite_rounded,
        isSelected: provider.filterType == FilterType.favorites,
        onTap: () {
          HapticFeedback.selectionClick();
          provider.setFilterType(FilterType.favorites);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
      SortOption(
        title: 'Archived',
        icon: Icons.archive_rounded,
        isSelected: provider.filterType == FilterType.archived,
        onTap: () {
          HapticFeedback.selectionClick();
          provider.setFilterType(FilterType.archived);
          Navigator.pop(context);
        },
        isDark: isDark,
      ),
    ];
  }
}

/// Stateful widget for More Menu sheet with proper state management
class _MoreMenuSheet extends StatefulWidget {
  final bool isDark;
  final Function(String, IconData) showSnackBar;

  const _MoreMenuSheet({
    required this.isDark,
    required this.showSnackBar,
  });

  @override
  State<_MoreMenuSheet> createState() => _MoreMenuSheetState();
}

class _MoreMenuSheetState extends State<_MoreMenuSheet> {
  bool _showAbout = false;
  double _sheetHeightFraction = 0.32;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _sheetHeightFraction,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.32, 0.85],
      builder: (context, scrollController) {
        return _buildMoreMenuSheet(
          context: context,
          isDark: widget.isDark,
          showAbout: _showAbout,
          showSnackBar: widget.showSnackBar,
          onAboutTap: () {
            setState(() {
              _showAbout = true;
              _sheetHeightFraction = 0.85;
            });
          },
          onBack: () {
            setState(() {
              _showAbout = false;
              _sheetHeightFraction = 0.32;
            });
          },
        );
      },
    );
  }

  /// Build the main sheet content with smooth transitions between views
  Widget _buildMoreMenuSheet({
    required BuildContext context,
    required bool isDark,
    required bool showAbout,
    required Function(String, IconData) showSnackBar,
    required VoidCallback onAboutTap,
    required VoidCallback onBack,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.xlRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfacePrimary.withOpacity(0.95)
                : AppColors.lightSurfacePrimary.withOpacity(0.95),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.xlRadius),
            ),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.darkDivider.withOpacity(0.3)
                    : AppColors.lightDivider.withOpacity(0.5),
              ),
            ),
          ),
          child: Column(
            children: [
              _buildDragHandle(isDark),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: showAbout
                      ? AboutSheet(
                          key: const ValueKey('about'),
                          isDark: isDark,
                          onBack: onBack,
                        )
                      : _buildMoreMenuContent(
                          key: const ValueKey('more'),
                          context: context,
                          isDark: isDark,
                          showSnackBar: showSnackBar,
                          onAboutTap: onAboutTap,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build drag handle for the bottom sheet
  Widget _buildDragHandle(bool isDark) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Build the main menu content
  Widget _buildMoreMenuContent({
    required Key key,
    required BuildContext context,
    required bool isDark,
    required Function(String, IconData) showSnackBar,
    required VoidCallback onAboutTap,
  }) {
    return SingleChildScrollView(
      key: key,
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(12),
            Text(
              'More',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Gap(16),
            _buildMenuOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                showSnackBar('Coming soon', Icons.settings_outlined);
              },
              isDark: isDark,
            ),
            _buildMenuOption(
              icon: Icons.backup_outlined,
              title: 'Backup & Restore',
              onTap: () {
                Navigator.pop(context);
                showSnackBar('Coming soon', Icons.backup_outlined);
              },
              isDark: isDark,
            ),
            _buildMenuOption(
              icon: Icons.info_outline_rounded,
              title: 'About',
              onTap: onAboutTap,
              isDark: isDark,
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  /// Build a single menu option item with proper theming
  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
