// lib/utils/haptic_manager.dart

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  warning,
  error,
}

class HapticManager {
  HapticManager._();

  static bool _isEnabled = true;
  static DateTime? _lastHapticTime;
  static const Duration _minimumInterval = Duration(milliseconds: 50);

  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  static bool get isEnabled => _isEnabled;

  static Future<void> trigger(HapticType type) async {
    if (!_isEnabled || kIsWeb) return;

    final now = DateTime.now();
    if (_lastHapticTime != null &&
        now.difference(_lastHapticTime!) < _minimumInterval) {
      return;
    }

    _lastHapticTime = now;

    try {
      switch (type) {
        case HapticType.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticType.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticType.selection:
          await HapticFeedback.selectionClick();
          break;
        case HapticType.success:
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          break;
        case HapticType.warning:
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.mediumImpact();
          break;
        case HapticType.error:
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Haptic feedback error: $e');
      }
    }
  }

  static Future<void> light() => trigger(HapticType.light);
  static Future<void> medium() => trigger(HapticType.medium);
  static Future<void> heavy() => trigger(HapticType.heavy);
  static Future<void> selection() => trigger(HapticType.selection);
  static Future<void> success() => trigger(HapticType.success);
  static Future<void> warning() => trigger(HapticType.warning);
  static Future<void> error() => trigger(HapticType.error);

  static Future<void> buttonPress() => light();
  static Future<void> buttonLongPress() => heavy();
  static Future<void> toggleSwitch() => selection();
  static Future<void> sliderChange() => selection();
  static Future<void> dropdownOpen() => light();
  static Future<void> modalOpen() => medium();
  static Future<void> modalClose() => light();
  static Future<void> deleteAction() => heavy();
  static Future<void> saveAction() => medium();
  static Future<void> cancelAction() => light();
}
