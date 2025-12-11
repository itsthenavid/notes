// lib/extensions/string_extensions.dart

extension StringExtensions on String {
  int get wordCount {
    if (trim().isEmpty) return 0;
    return trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  int get paragraphCount {
    if (trim().isEmpty) return 0;
    return trim()
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .length;
  }

  String truncate(int length, {String suffix = '...'}) {
    if (isEmpty || this.length <= length) return this;
    return '${substring(0, length)}$suffix';
  }

  String get smartTruncate {
    const maxLength = 150;
    if (trim().isEmpty) return '';
    if (length <= maxLength) return this;

    final truncated = substring(0, maxLength);
    final lastSpace = truncated.lastIndexOf(' ');

    if (lastSpace > maxLength * 0.7) {
      return '${truncated.substring(0, lastSpace)}...';
    }

    return '$truncated...';
  }

  bool get isValidTitle {
    final trimmed = trim();
    return trimmed.isNotEmpty && trimmed.length <= 100;
  }

  String get capitalize {
    if (isEmpty) return '';
    if (length == 1) return toUpperCase();
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase {
    if (isEmpty) return '';
    return split(' ')
        .map((word) => word.isEmpty ? '' : word.capitalize)
        .join(' ');
  }

  String removeExtraSpaces() {
    if (isEmpty) return '';
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool containsIgnoreCase(String other) {
    if (isEmpty) return false;
    return toLowerCase().contains(other.toLowerCase());
  }

  String get initials {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));

    if (words.isEmpty) return '';

    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0].substring(0, 1).toUpperCase() : '';
    }

    return words
        .take(2)
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  Duration get readingTime {
    const wordsPerMinute = 200;
    final count = wordCount;
    final minutes = (count / wordsPerMinute).ceil();
    return Duration(minutes: minutes > 0 ? minutes : 1);
  }

  String get readingTimeText {
    final duration = readingTime;
    final minutes = duration.inMinutes;

    if (minutes < 1) return '< 1 min read';
    if (minutes == 1) return '1 min read';
    return '$minutes min read';
  }

  String get reversed {
    if (isEmpty) return '';
    return split('').reversed.join();
  }

  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  bool get isAlphabetic {
    if (isEmpty) return false;
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  bool get isAlphanumeric {
    if (isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  String get withoutSpecialChars {
    if (isEmpty) return '';
    return replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  String get withoutNumbers {
    if (isEmpty) return '';
    return replaceAll(RegExp(r'[0-9]'), '');
  }

  String get withoutLetters {
    if (isEmpty) return '';
    return replaceAll(RegExp(r'[a-zA-Z]'), '');
  }

  String get firstWord {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    return words.isNotEmpty ? words.first : '';
  }

  String get lastWord {
    if (isEmpty) return '';
    final words = trim().split(RegExp(r'\s+'));
    return words.isNotEmpty ? words.last : '';
  }

  List<String> get words {
    if (isEmpty) return [];
    return trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  String repeatString(int times) {
    if (isEmpty || times <= 0) return '';
    return List.filled(times, this).join();
  }
}
