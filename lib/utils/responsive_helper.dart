// lib/utils/responsive_helper.dart

import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static bool isValidTitle(String? title) {
    if (title == null || title.trim().isEmpty) return false;
    return title.trim().length <= AppConstants.maxTitleLength;
  }

  static bool isValidContent(String? content) {
    if (content == null) return false;
    return content.length <= AppConstants.maxContentLength;
  }

  static bool isValidTag(String? tag) {
    if (tag == null || tag.trim().isEmpty) return false;
    final trimmed = tag.trim();
    return trimmed.length <= AppConstants.maxTagLength &&
        !trimmed.contains(RegExp(r'[^\w\s-]'));
  }

  static bool isValidNoteSize(String content) {
    return content.length <= AppConstants.maxNoteSize;
  }

  static bool canAddMoreTags(List<String> currentTags) {
    return currentTags.length < AppConstants.maxTagsPerNote;
  }

  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    if (title.trim().length > AppConstants.maxTitleLength) {
      return 'Title must be ${AppConstants.maxTitleLength} characters or less';
    }
    return null;
  }

  static String? validateContent(String? content) {
    if (content == null) {
      return 'Content cannot be null';
    }
    if (content.length > AppConstants.maxContentLength) {
      return 'Content is too long';
    }
    return null;
  }

  static String? validateTag(String? tag, List<String> existingTags) {
    if (tag == null || tag.trim().isEmpty) {
      return 'Tag cannot be empty';
    }

    final trimmed = tag.trim();

    if (trimmed.length > AppConstants.maxTagLength) {
      return 'Tag must be ${AppConstants.maxTagLength} characters or less';
    }

    if (trimmed.contains(RegExp(r'[^\w\s-]'))) {
      return 'Tag can only contain letters, numbers, spaces, and hyphens';
    }

    if (existingTags.contains(trimmed)) {
      return 'Tag already exists';
    }

    if (existingTags.length >= AppConstants.maxTagsPerNote) {
      return 'Maximum ${AppConstants.maxTagsPerNote} tags allowed';
    }

    return null;
  }

  static String? validateNoteCount(int currentCount) {
    if (currentCount >= AppConstants.maxNotesBeforeWarning) {
      return 'You have many notes. Consider archiving old ones for better performance.';
    }
    return null;
  }

  static bool isEmptyNote(String? title, String? content) {
    return (title == null || title.trim().isEmpty) &&
        (content == null || content.trim().isEmpty);
  }

  static bool hasValidContent(String? title, String? content) {
    return !isEmptyNote(title, content);
  }

  static String sanitizeTitle(String? title) {
    if (title == null) return '';
    return title.trim().substring(
          0,
          title.trim().length > AppConstants.maxTitleLength
              ? AppConstants.maxTitleLength
              : title.trim().length,
        );
  }

  static String sanitizeTag(String? tag) {
    if (tag == null) return '';
    return tag.trim().replaceAll(RegExp(r'[^\w\s-]'), '').substring(
          0,
          tag.trim().length > AppConstants.maxTagLength
              ? AppConstants.maxTagLength
              : tag.trim().length,
        );
  }

  static List<String> sanitizeTags(List<String> tags) {
    return tags
        .map((tag) => sanitizeTag(tag))
        .where((tag) => tag.isNotEmpty)
        .take(AppConstants.maxTagsPerNote)
        .toSet()
        .toList();
  }

  static bool isWithinSearchLimit(int resultsCount) {
    return resultsCount <= AppConstants.maxSearchResults;
  }

  static bool isValidFontSize(double? fontSize) {
    if (fontSize == null) return false;
    return fontSize >= AppConstants.minFontSize &&
        fontSize <= AppConstants.maxFontSize;
  }

  static double clampFontSize(double fontSize) {
    return fontSize.clamp(AppConstants.minFontSize, AppConstants.maxFontSize);
  }

  static bool isValidColorIndex(int? colorIndex) {
    if (colorIndex == null) return false;
    return colorIndex >= 0;
  }

  static bool isValidBackgroundStyle(int? style) {
    if (style == null) return false;
    return style >= 0 && style <= 2;
  }
}
