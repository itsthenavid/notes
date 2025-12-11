// lib/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = 'Notes';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  static const Duration microDuration = Duration(milliseconds: 100);
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 600);
  static const Duration xlDuration = Duration(milliseconds: 900);
  static const Duration xxlDuration = Duration(milliseconds: 1200);

  static const double microRadius = 8.0;
  static const double smallRadius = 12.0;
  static const double defaultRadius = 16.0;
  static const double mediumRadius = 20.0;
  static const double largeRadius = 24.0;
  static const double xlRadius = 28.0;
  static const double xxlRadius = 32.0;

  static const double microPadding = 4.0;
  static const double smallPadding = 8.0;
  static const double defaultPadding = 16.0;
  static const double mediumPadding = 20.0;
  static const double largePadding = 24.0;
  static const double xlPadding = 32.0;
  static const double xxlPadding = 40.0;

  static const double blurLight = 12.0;
  static const double blurMedium = 20.0;
  static const double blurHeavy = 30.0;

  static const String storageKeyNotes = 'notes_v2';
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeySort = 'sort_preference';
  static const String storageKeyFilter = 'filter_preference';
  static const String storageKeyFirstLaunch = 'first_launch';
  static const String storageKeyLastBackup = 'last_backup';

  static const int maxTitleLength = 100;
  static const int maxContentLength = 1000000;
  static const int previewLines = 4;
  static const int maxRecentNotes = 50;
  static const int maxSearchResults = 100;
  static const int maxTagsPerNote = 10;
  static const int maxTagLength = 30;

  static const int autosaveDelaySeconds = 2;
  static const int searchDebounceMilliseconds = 300;

  static const double minFontSize = 12.0;
  static const double defaultFontSize = 16.0;
  static const double maxFontSize = 24.0;

  static const double cardElevation = 4.0;
  static const double modalElevation = 8.0;
  static const double appBarElevation = 0.0;

  static const int maxUndoStackSize = 50;

  static const double minSwipeVelocity = 300.0;
  static const double swipeThreshold = 0.4;

  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration toastDuration = Duration(seconds: 1);
  static const Duration tooltipDelay = Duration(milliseconds: 500);

  static const double gridCardAspectRatio = 0.85;
  static const double listCardHeight = 120.0;

  static const int wordsPerMinuteReading = 200;

  static const String fontFamily = 'PlusJakartaSans';
  static const String monospaceFontFamily = 'JetBrainsMono';

  static const Map<String, dynamic> featureFlags = {
    'enableBackup': false,
    'enableSync': false,
    'enableTags': false,
    'enableMarkdown': true,
    'enableVoiceNotes': false,
    'enableCollaboration': false,
  };

  static const List<String> supportedLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko',
    'ar',
    'ku',
    'ckb',
    'fa',
  ];

  static const String defaultLanguage = 'en';

  static const int maxNotesBeforeWarning = 1000;
  static const int maxNoteSize = 5 * 1024 * 1024;

  static bool isFeatureEnabled(String feature) {
    return featureFlags[feature] == true;
  }
}
