// lib/screens/add_edit_note_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import '../providers/note_provider.dart';
import '../models/note_model.dart';
import '../theme/colors.dart';
import '../widgets/custom_app_bar.dart';
import '../constants/app_constants.dart';
import '../extensions/date_extensions.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final QuillController _contentController;
  late final FocusNode _titleFocus;
  late final FocusNode _contentFocus;
  late final ScrollController _scrollController;

  late final AnimationController _fabAnimController;
  late final AnimationController _toolbarAnimController;
  late final AnimationController _colorPickerAnimController;
  late final AnimationController _entryAnimController;
  late final AnimationController _pulseAnimController;
  late final AnimationController _shakeAnimController;

  late int _selectedColorIndex;
  late int _selectedBackgroundStyle;
  late final DateTime _displayDate;

  bool _showOptions = false;
  bool _isKeyboardVisible = false;
  bool _isBoldActive = false;
  bool _isItalicActive = false;
  bool _isListActive = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeListeners();
    _displayDate = widget.note?.createdAt ?? DateTime.now();
    _scheduleInitialFocus();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = _createQuillController();
    _scrollController = ScrollController();
    _selectedColorIndex = widget.note?.colorIndex ??
        Random().nextInt(AppColors.noteColors.length);
    _selectedBackgroundStyle = widget.note?.backgroundStyle ?? 0;
    _titleFocus = FocusNode();
    _contentFocus = FocusNode();
  }

  QuillController _createQuillController() {
    if (widget.note != null && widget.note!.content.isNotEmpty) {
      try {
        final deltaJson = jsonDecode(widget.note!.content);
        return QuillController(
          document: Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        return QuillController.basic();
      }
    }
    return QuillController.basic();
  }

  void _initializeAnimations() {
    _fabAnimController = AnimationController(
      duration: AppConstants.mediumDuration,
      vsync: this,
    );
    _toolbarAnimController = AnimationController(
      duration: AppConstants.longDuration,
      vsync: this,
    )..forward();
    _colorPickerAnimController = AnimationController(
      duration: AppConstants.mediumDuration,
      vsync: this,
    );
    _entryAnimController = AnimationController(
      duration: AppConstants.xlDuration,
      vsync: this,
    )..forward();
    _pulseAnimController = AnimationController(
      duration: AppConstants.shortDuration,
      vsync: this,
    );
    _shakeAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _initializeListeners() {
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onContentChanged);
  }

  void _scheduleInitialFocus() {
    if (widget.note == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _titleFocus.requestFocus();
        });
      });
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onContentChanged() {
    _updateFormatStates();
    setState(() {});
  }

  void _updateFormatStates() {
    final style = _contentController.getSelectionStyle();
    setState(() {
      _isBoldActive = style.attributes.containsKey('bold');
      _isItalicActive = style.attributes.containsKey('italic');
      _isListActive = style.attributes.containsKey('list');
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _scrollController.dispose();
    _fabAnimController.dispose();
    _toolbarAnimController.dispose();
    _colorPickerAnimController.dispose();
    _entryAnimController.dispose();
    _pulseAnimController.dispose();
    _shakeAnimController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final contentJson =
        jsonEncode(_contentController.document.toDelta().toJson());
    final plainContent = _contentController.document.toPlainText().trim();

    if (title.isEmpty && plainContent.isEmpty) return;

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final newNote = Note(
      id: widget.note?.id,
      title: title,
      content: contentJson,
      colorIndex: _selectedColorIndex,
      backgroundStyle: _selectedBackgroundStyle,
      createdAt: widget.note?.createdAt,
      updatedAt: DateTime.now(),
      isPinned: widget.note?.isPinned ?? false,
      isFavorite: widget.note?.isFavorite ?? false,
      isArchived: widget.note?.isArchived ?? false,
      tags: widget.note?.tags ?? [],
    );

    if (widget.note == null) {
      await noteProvider.addNote(newNote);
    } else {
      await noteProvider.updateNote(newNote);
    }
  }

  void _handleBackPress() async {
    HapticFeedback.lightImpact();
    await _saveNote();
    if (mounted) Navigator.pop(context);
  }

  void _handleManualSave() async {
    HapticFeedback.mediumImpact();
    if (_titleController.text.trim().isEmpty &&
        _contentController.document.toPlainText().trim().isEmpty) {
      _shakeAnimController.forward(from: 0);
      _showSnackBar('Note is empty!', Colors.orange,
          icon: Icons.warning_rounded);
      return;
    }

    await _fabAnimController.forward(from: 0);
    await _saveNote();

    if (mounted) {
      HapticFeedback.heavyImpact();
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message, Color color, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 20),
            if (icon != null) const Gap(8),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        margin: const EdgeInsets.all(20),
        duration: AppConstants.snackBarDuration,
      ),
    );
  }

  void _toggleFormat(Attribute attribute, bool isActive) {
    HapticFeedback.selectionClick();
    _pulseAnimController.forward(from: 0);
    if (isActive) {
      _contentController.formatSelection(Attribute.clone(attribute, null));
    } else {
      _contentController.formatSelection(attribute);
    }
    _updateFormatStates();
  }

  void _dismissOptions() {
    if (_showOptions) {
      HapticFeedback.lightImpact();
      setState(() => _showOptions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = AppColors.noteColors[_selectedColorIndex];
    final gradientColors = AppColors.noteGradients[_selectedColorIndex];
    _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) _handleBackPress();
      },
      child: GestureDetector(
        onTap: _dismissOptions,
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: _getBackgroundColor(isDark, baseColor),
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(
            title: '',
            showBackButton: true,
            onBackPressed: _handleBackPress,
            scrollController: _scrollController,
            actions: [_buildSaveButton(gradientColors)],
          ),
          body: Stack(
            children: [
              if (_selectedBackgroundStyle == 2)
                _buildAnimatedBackground(isDark, baseColor),
              SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: CustomAppBar.totalHeight(context) + 16,
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(context, isDark, gradientColors),
                    const Gap(12),
                    _buildMetadata(isDark),
                    const Gap(24),
                    _buildDividerLine(isDark),
                    const Gap(32),
                    _buildContentField(context, isDark),
                    const Gap(140),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomToolbar(context, isDark, gradientColors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark, Color baseColor) {
    switch (_selectedBackgroundStyle) {
      case 0:
        return isDark ? AppColors.darkBg : AppColors.lightBg;
      case 1:
        return baseColor.withOpacity(isDark ? 0.05 : 0.08);
      case 2:
        return isDark ? AppColors.darkBg : AppColors.lightBg;
      default:
        return isDark ? AppColors.darkBg : AppColors.lightBg;
    }
  }

  Widget _buildAnimatedBackground(bool isDark, Color baseColor) {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor.withOpacity(0.15 * value),
                  (isDark ? AppColors.darkBg : AppColors.lightBg)
                      .withOpacity(value),
                  baseColor.withOpacity(0.08 * value),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaveButton(List<Color> gradientColors) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, top: 2),
      child: AnimatedBuilder(
        animation: _shakeAnimController,
        builder: (context, child) {
          final shake = sin(_shakeAnimController.value * pi * 4) * 4;
          return Transform.translate(offset: Offset(shake, 0), child: child);
        },
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(
                parent: _entryAnimController, curve: Curves.easeOutBack),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleManualSave,
              borderRadius: BorderRadius.circular(26),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: AnimatedContainer(
                    duration: AppConstants.mediumDuration,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 11),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(0.55),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.92).animate(
                        CurvedAnimation(
                            parent: _fabAnimController,
                            curve: Curves.easeOutCubic),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded,
                              color: Colors.white, size: 18.5),
                          Gap(8),
                          Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.2,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(
      BuildContext context, bool isDark, List<Color> gradientColors) {
    double lineHeight = 52;
    final titleText = _titleController.text;

    if (titleText.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: titleText,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.18,
            letterSpacing: -0.5,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        maxLines: null,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 94);
      lineHeight = textPainter.height + 20;
    }

    return FadeTransition(
      opacity: _entryAnimController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return AnimatedContainer(
                    duration: AppConstants.mediumDuration,
                    width: 4,
                    height: lineHeight * value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          gradientColors[0].withOpacity(value),
                          gradientColors[1].withOpacity(value * 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withOpacity(0.55 * value),
                          blurRadius: 12,
                          spreadRadius: 1.2,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Gap(18),
              Expanded(
                child: TextField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  maxLines: null,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    hintText: 'Note title...',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkTextTertiary.withOpacity(0.25)
                          : AppColors.lightTextTertiary.withOpacity(0.25),
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    HapticFeedback.lightImpact();
                    _contentFocus.requestFocus();
                  },
                  cursorColor: gradientColors[0],
                  cursorWidth: 3.5,
                  cursorRadius: const Radius.circular(2),
                ),
              ),
            ],
          ),
          const Gap(10),
          Container(
            height: 0.5,
            margin: const EdgeInsets.only(left: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDark ? Colors.white : Colors.black).withOpacity(0),
                  (isDark ? Colors.white : Colors.black)
                      .withOpacity(isDark ? 0.06 : 0.08),
                  (isDark ? Colors.white : Colors.black).withOpacity(0),
                ],
              ),
            ),
          ),
          const Gap(14),
        ],
      ),
    );
  }

  Widget _buildMetadata(bool isDark) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryAnimController,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 22.5),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 13,
              color: isDark
                  ? AppColors.darkTextTertiary.withOpacity(0.6)
                  : AppColors.lightTextTertiary.withOpacity(0.6),
            ),
            const Gap(6),
            Text(
              _displayDate.compactDate,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const Gap(12),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTextTertiary.withOpacity(0.4)
                    : AppColors.lightTextTertiary.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
            const Gap(12),
            AnimatedSwitcher(
              duration: AppConstants.shortDuration,
              child: Text(
                '${_contentController.document.toPlainText().length} characters',
                key: ValueKey(_contentController.document.toPlainText().length),
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerLine(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 48),
      child: Container(
        height: 0.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (isDark ? Colors.white : Colors.black).withOpacity(0),
              (isDark ? Colors.white : Colors.black).withOpacity(0.12),
              (isDark ? Colors.white : Colors.black).withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentField(BuildContext context, bool isDark) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entryAnimController,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(
          CurvedAnimation(
            parent: _entryAnimController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            _dismissOptions();
            _contentFocus.requestFocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppConstants.largeRadius - 2),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            margin: const EdgeInsets.only(right: 4),
            constraints: const BoxConstraints(minHeight: 300),
            child: QuillEditor(
              scrollController: ScrollController(),
              controller: _contentController,
              focusNode: _contentFocus,
              config: QuillEditorConfig(
                autoFocus: false,
                expands: false,
                padding: EdgeInsets.zero,
                scrollable: true,
                placeholder: 'Start writing your note here...',
                customStyles: DefaultStyles(
                  paragraph: DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(6, 6),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                  placeHolder: DefaultTextBlockStyle(
                    TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark
                          ? AppColors.darkTextTertiary.withOpacity(0.4)
                          : AppColors.lightTextTertiary.withOpacity(0.4),
                    ),
                    const HorizontalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    const VerticalSpacing(0, 0),
                    null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(
      BuildContext context, bool isDark, List<Color> gradientColors) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _toolbarAnimController, curve: Curves.easeOutCubic),
      ),
      child: AnimatedContainer(
        duration: AppConstants.mediumDuration,
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(
          bottom: _isKeyboardVisible ? 12 : 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutQuint,
              alignment: Alignment.bottomCenter,
              child: _showOptions
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 2.5),
                      child: _buildColorStylePicker(isDark, gradientColors),
                    )
                  : const SizedBox.shrink(),
            ),
            _buildMainToolbar(context, isDark, gradientColors),
          ],
        ),
      ),
    );
  }

  Widget _buildColorStylePicker(bool isDark, List<Color> gradientColors) {
    return FadeTransition(
      opacity: _colorPickerAnimController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
          CurvedAnimation(
              parent: _colorPickerAnimController, curve: Curves.easeOutCubic),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.xlRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfacePrimary.withOpacity(0.90)
                    : AppColors.lightSurfacePrimary.withOpacity(0.90),
                borderRadius: BorderRadius.circular(AppConstants.xlRadius),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.black.withOpacity(0.06),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: 30,
                    spreadRadius: -5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const Gap(8),
                      Text(
                        'ACCENT COLOR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(
                        AppColors.noteColors.length,
                        (index) => _buildColorOption(index, isDark),
                      ),
                    ),
                  ),
                  const Gap(26),
                  Row(
                    children: [
                      Icon(
                        Icons.texture_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const Gap(8),
                      Text(
                        'BACKGROUND STYLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      _buildStyleChip('Solid', 0, isDark),
                      _buildStyleChip('Soft', 1, isDark),
                      _buildStyleChip('Gradient', 2, isDark),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(int index, bool isDark) {
    final isSelected = _selectedColorIndex == index;
    final baseColor = AppColors.noteColors[index];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedColorIndex = index);
      },
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: AppConstants.mediumDuration,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: AppConstants.mediumDuration,
          width: 48,
          height: 48,
          margin: const EdgeInsets.only(right: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: baseColor.withOpacity(0.5 * value),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: AnimatedContainer(
                    duration: AppConstants.mediumDuration,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.noteGradients[index],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: isDark ? Colors.white : Colors.black,
                              width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(isSelected ? 0.65 : 0.4),
                          blurRadius: isSelected ? 22 : 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: AppConstants.shortDuration,
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              key: ValueKey('check'),
                              color: Colors.white,
                              size: 26,
                            )
                          : const SizedBox.shrink(key: ValueKey('empty')),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleChip(String label, int index, bool isDark) {
    final isSelected = _selectedBackgroundStyle == index;
    final gradientColors = AppColors.noteGradients[_selectedColorIndex];

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedBackgroundStyle = index);
      },
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: AppConstants.shortDuration,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            gradient:
                isSelected ? LinearGradient(colors: gradientColors) : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.12)),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainToolbar(
      BuildContext context, bool isDark, List<Color> gradientColors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.darkSurfaceSecondary.withOpacity(0.85),
                      AppColors.darkSurfacePrimary.withOpacity(0.75),
                    ]
                  : [
                      AppColors.lightSurfacePrimary.withOpacity(0.85),
                      AppColors.lightSurfaceSecondary.withOpacity(0.75),
                    ],
            ),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.06),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildToolIcon(
                icon: Icons.palette_outlined,
                isActive: _showOptions,
                isDark: isDark,
                gradientColors: gradientColors,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _showOptions = !_showOptions;
                    if (_showOptions) {
                      _colorPickerAnimController.forward(from: 0);
                    }
                  });
                },
              ),
              _buildDivider(isDark),
              _buildToolIcon(
                icon: Icons.format_bold_rounded,
                isDark: isDark,
                isActive: _isBoldActive,
                gradientColors: gradientColors,
                onTap: () => _toggleFormat(Attribute.bold, _isBoldActive),
              ),
              _buildToolIcon(
                icon: Icons.format_italic_rounded,
                isDark: isDark,
                isActive: _isItalicActive,
                gradientColors: gradientColors,
                onTap: () => _toggleFormat(Attribute.italic, _isItalicActive),
              ),
              _buildToolIcon(
                icon: Icons.format_list_bulleted_rounded,
                isDark: isDark,
                isActive: _isListActive,
                gradientColors: gradientColors,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _pulseAnimController.forward(from: 0);
                  if (_isListActive) {
                    _contentController
                        .formatSelection(Attribute.clone(Attribute.ul, null));
                  } else {
                    _contentController.formatSelection(Attribute.ul);
                  }
                  _updateFormatStates();
                },
              ),
              _buildDivider(isDark),
              _buildToolIcon(
                icon: Icons.image_outlined,
                isDark: isDark,
                gradientColors: gradientColors,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _showSnackBar('Images coming soon!', Colors.purpleAccent,
                      icon: Icons.auto_awesome);
                },
              ),
              _buildDivider(isDark),
              _buildToolIcon(
                icon: Icons.keyboard_hide_rounded,
                isDark: isDark,
                gradientColors: gradientColors,
                onTap: () {
                  HapticFeedback.lightImpact();
                  FocusScope.of(context).unfocus();
                  _dismissOptions();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1.5,
      height: 26,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? Colors.white : Colors.black).withOpacity(0),
            (isDark ? Colors.white : Colors.black).withOpacity(0.12),
            (isDark ? Colors.white : Colors.black).withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIcon({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isActive ? 1.1 : 1.0,
        duration: AppConstants.shortDuration,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      gradientColors[0].withOpacity(0.25),
                      gradientColors[1].withOpacity(0.15),
                    ],
                  )
                : null,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: AnimatedSwitcher(
            duration: AppConstants.shortDuration,
            child: Icon(
              icon,
              key: ValueKey('$icon$isActive'),
              color: isActive
                  ? gradientColors[0]
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              size: 23,
            ),
          ),
        ),
      ),
    );
  }
}
