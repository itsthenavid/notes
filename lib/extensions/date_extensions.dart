// lib/extensions/date_extensions.dart

import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  bool get isPast {
    return isBefore(DateTime.now());
  }

  bool get isFuture {
    return isAfter(DateTime.now());
  }

  String get relativeDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';

    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays < 7 && difference.inDays >= 0) {
      return DateFormat('EEEE').format(this);
    }

    if (isThisYear) {
      return DateFormat('MMM d').format(this);
    }

    return DateFormat('MMM d, yyyy').format(this);
  }

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      final absDiff = difference.abs();
      if (absDiff.inMinutes < 1) return 'In a moment';
      if (absDiff.inMinutes < 60) return 'In ${absDiff.inMinutes}m';
      if (absDiff.inHours < 24) return 'In ${absDiff.inHours}h';
      if (absDiff.inDays < 7) return 'In ${absDiff.inDays}d';
      return relativeDate;
    }

    if (difference.inSeconds < 30) return 'Just now';
    if (difference.inMinutes < 1) return 'Less than a minute ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return relativeDate;
  }

  String get formattedDateTime {
    try {
      return DateFormat('MMM d, yyyy • h:mm a').format(this);
    } catch (e) {
      return toString();
    }
  }

  String get formattedDate {
    try {
      return DateFormat('EEEE, MMMM d, yyyy').format(this);
    } catch (e) {
      return toString();
    }
  }

  String get compactDate {
    try {
      if (isToday) return 'Today';
      if (isYesterday) return 'Yesterday';
      if (isThisYear) return DateFormat('MMM d').format(this);
      return DateFormat('MMM d, yyyy').format(this);
    } catch (e) {
      return toString();
    }
  }

  String get shortTime {
    try {
      return DateFormat('h:mm a').format(this);
    } catch (e) {
      return toString();
    }
  }

  String get mediumTime {
    try {
      return DateFormat('HH:mm').format(this);
    } catch (e) {
      return toString();
    }
  }

  String get fullDateTime {
    try {
      return DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(this);
    } catch (e) {
      return toString();
    }
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  bool get isLeapYear {
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
  }

  String get dayOfWeekName {
    return DateFormat('EEEE').format(this);
  }

  String get monthName {
    return DateFormat('MMMM').format(this);
  }

  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceFirstDay = difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }
}
