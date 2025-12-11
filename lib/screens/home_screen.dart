// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../providers/note_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/enhanced_note_card.dart';
import '../theme/colors.dart';
import '../widgets/premium_search_field.dart';
import '../constants/app_constants.dart';
import '../mixins/selection_mode_mixin.dart';
import '../utils/home_dialogs.dart';
import '../widgets/home/stat_card.dart';
import '../widgets/home/app_bar_button.dart';
import '../widgets/home/loading_state.dart';
import '../widgets/home/empty_state.dart';
import '../widgets/home/no_results_state.dart';
import '../widgets/home/selection_bottom_bar.dart';
import 'add_edit_note_screen.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, SelectionModeMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;
  late AnimationController _fabController;
  late AnimationController _headerController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<NoteProvider>();
      if (!provider.isInitialized) {
        await provider.init();
      }
      if (!mounted) return;
      _fabController.forward();
      _headerController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    _fabController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  /// Display a SnackBar with a custom message and icon
  void _showSnackBar(String message, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const Gap(12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
        margin: const EdgeInsets.all(20),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isSelectionMode) {
          cancelSelection();
        }
      },
      child: GestureDetector(
        onTap: () {
          _searchFocus.unfocus();
          if (isSelectionMode) cancelSelection();
        },
        child: Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: isSelectionMode
              ? _buildSelectionAppBar(context, isDark)
              : CustomAppBar(
                  title: 'Notes',
                  scrollController: _scrollController,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Row(
                        children: [
                          AppBarButton(
                            icon: Icons.filter_list_rounded,
                            onTap: () =>
                                HomeDialogs.showFilterSheet(context, isDark),
                            isDark: isDark,
                          ),
                          const Gap(8),
                          AppBarButton(
                            icon: Icons.sort_rounded,
                            onTap: () =>
                                HomeDialogs.showSortMenu(context, isDark),
                            isDark: isDark,
                          ),
                          const Gap(8),
                          AppBarButton(
                            icon: Icons.more_vert_rounded,
                            onTap: () => HomeDialogs.showMoreMenu(
                                context, isDark, _showSnackBar),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          body: Consumer<NoteProvider>(
            builder: (context, noteProvider, _) {
              if (noteProvider.isLoading) {
                return LoadingState(isDark: isDark);
              }
              if (noteProvider.notes.isEmpty &&
                  _searchController.text.isEmpty) {
                return EmptyState(isDark: isDark);
              }
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: CustomAppBar.totalHeight(context) - 53,
                    ),
                  ),
                  if (!isSelectionMode) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: PremiumSearchBar(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          onChanged: (value) =>
                              noteProvider.setSearchQuery(value),
                          onClear: () => noteProvider.clearSearch(),
                          hintText: 'Search notes...',
                          showFilterButton: true,
                          onFilterTap: () =>
                              HomeDialogs.showFilterSheet(context, isDark),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildStatCards(noteProvider, isDark),
                    ),
                  ],
                  if (noteProvider.notes.isEmpty)
                    SliverFillRemaining(child: NoResultsState(isDark: isDark))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 280,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: AppConstants.gridCardAspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final note = noteProvider.notes[index];
                            return EnhancedNoteCard(
                              note: note,
                              index: index,
                              isSelectionMode: isSelectionMode,
                              isSelected: isNoteSelected(note.id),
                              onTap: () {
                                if (isSelectionMode) {
                                  toggleNoteSelection(note.id);
                                } else {
                                  _navigateToDetail(note.id);
                                }
                              },
                              onLongPress: () {
                                if (!isSelectionMode) {
                                  toggleSelectionMode(note.id);
                                }
                              },
                              onDelete: () => HomeDialogs.showDeleteDialog(
                                context,
                                isDark,
                                note.id,
                                _showSnackBar,
                              ),
                              onPin: () {
                                HapticFeedback.selectionClick();
                                context.read<NoteProvider>().togglePin(note.id);
                              },
                            );
                          },
                          childCount: noteProvider.notes.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          floatingActionButton:
              isSelectionMode ? null : _buildFAB(context, isDark),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: isSelectionMode
              ? SelectionBottomBar(
                  selectedCount: selectedCount,
                  onPin: () => _handleBatchPin(context),
                  onDelete: () => HomeDialogs.showBatchDeleteDialog(
                    context,
                    isDark,
                    selectedCount,
                    () => deleteSelectedNotes(
                      context,
                      (msg, icon) => _showSnackBar(msg, icon),
                    ),
                  ),
                  allPinned: _areAllSelectedPinned(context),
                  isDark: isDark,
                )
              : null,
        ),
      ),
    );
  }

  /// Build statistics cards showing note counts
  Widget _buildStatCards(NoteProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.note_rounded,
              label: 'Total',
              value: '${provider.activeNotes}',
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              isDark: isDark,
            ),
          ),
          const Gap(12),
          Expanded(
            child: StatCard(
              icon: Icons.push_pin_rounded,
              label: 'Pinned',
              value: '${provider.pinnedNotes.length}',
              color: const Color(0xFFF97316),
              isDark: isDark,
            ),
          ),
          const Gap(12),
          Expanded(
            child: StatCard(
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              value: '${provider.favoriteNotes.length}',
              color: const Color(0xFFEC4899),
              isDark: isDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.1);
  }

  /// Build app bar for selection mode
  CustomAppBar _buildSelectionAppBar(BuildContext context, bool isDark) {
    return CustomAppBar(
      title: '$selectedCount selected',
      showBackButton: true,
      scrollController: _scrollController,
      onBackPressed: cancelSelection,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AppBarButton(
            icon: Icons.select_all_rounded,
            onTap: () => toggleSelectAll(context),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  /// Build floating action button for creating new notes
  Widget _buildFAB(BuildContext context, bool isDark) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabController,
        curve: Curves.elasticOut,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                  .withOpacity(0.5),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, anim, secAnim) =>
                    const AddEditNoteScreen(),
                transitionDuration: AppConstants.mediumDuration,
                reverseTransitionDuration: const Duration(milliseconds: 350),
                transitionsBuilder: (context, anim, secAnim, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.edit, size: 24),
        ),
      ),
    );
  }

  /// Navigate to note detail screen
  void _navigateToDetail(String noteId) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) =>
            NoteDetailScreen(noteId: noteId),
        transitionDuration: AppConstants.mediumDuration,
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            child: SlideTransition(
              position:
                  Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero)
                      .animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// Handle batch pinning/unpinning of selected notes
  void _handleBatchPin(BuildContext context) {
    final allPinned = _areAllSelectedPinned(context);
    pinSelectedNotes(
      context,
      !allPinned,
      (msg, icon) => _showSnackBar(msg, icon),
    );
  }

  /// Check if all selected notes are pinned
  bool _areAllSelectedPinned(BuildContext context) {
    final noteProvider = context.read<NoteProvider>();
    final selectedNotes =
        noteProvider.notes.where((note) => isNoteSelected(note.id)).toList();
    return selectedNotes.isNotEmpty &&
        selectedNotes.every((note) => note.isPinned);
  }
}
