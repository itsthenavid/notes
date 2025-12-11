// lib/utils/color_utils.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ColorUtils {
  ColorUtils._();

  static int getRandomColorIndex() {
    return math.Random().nextInt(AppColors.noteColors.length);
  }

  static int getColorIndexByHash(String? text) {
    if (text == null || text.isEmpty) return getRandomColorIndex();
    final hash = text.hashCode.abs();
    return hash % AppColors.noteColors.length;
  }

  static int getColorIndexByTime(DateTime date) {
    final seed = date.day + date.month * 31 + date.year * 365;
    return seed.abs() % AppColors.noteColors.length;
  }

  static int getColorIndexById(String id) {
    if (id.isEmpty) return 0;
    final hash = id.hashCode.abs();
    return hash % AppColors.noteColors.length;
  }

  static Color adjustBrightness(Color color, double factor) {
    assert(
        factor >= 0.0 && factor <= 2.0, 'Factor must be between 0.0 and 2.0');
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * factor).clamp(0.0, 1.0))
        .toColor();
  }

  static Color adjustSaturation(Color color, double factor) {
    assert(
        factor >= 0.0 && factor <= 2.0, 'Factor must be between 0.0 and 2.0');
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation * factor).clamp(0.0, 1.0))
        .toColor();
  }

  static bool isDark(Color color) => color.computeLuminance() < 0.5;

  static bool isLight(Color color) => !isDark(color);

  static Color getContrastColor(Color background) {
    return isDark(background) ? Colors.white : Colors.black;
  }

  static Color getTextColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  static List<Color> generateGradient(Color baseColor, {int steps = 2}) {
    assert(steps > 0, 'Steps must be positive');
    final hsl = HSLColor.fromColor(baseColor);
    return List.generate(steps, (i) {
      final factor = 1.0 + (i * 0.15);
      return hsl
          .withLightness((hsl.lightness * factor).clamp(0.0, 1.0))
          .toColor();
    });
  }

  static Color blendColors(Color color1, Color color2, double ratio) {
    assert(ratio >= 0.0 && ratio <= 1.0, 'Ratio must be between 0.0 and 1.0');
    return Color.lerp(color1, color2, ratio) ?? color1;
  }

  static Color applyOpacity(Color color, double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0,
        'Opacity must be between 0.0 and 1.0');
    return color.withOpacity(opacity);
  }

  static Color getGlowColor(Color baseColor, {double opacity = 0.3}) {
    return baseColor.withOpacity(opacity.clamp(0.0, 1.0));
  }

  static List<BoxShadow> getColoredShadows(
    Color color, {
    bool isDark = false,
    double intensity = 0.4,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity.clamp(0.0, 1.0)),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hsl = HSLColor.fromColor(color);
    final newLightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hsl = HSLColor.fromColor(color);
    final newLightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }

  static Color saturate(Color color, [double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hsl = HSLColor.fromColor(color);
    final newSaturation = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(newSaturation).toColor();
  }

  static Color desaturate(Color color, [double amount = 0.1]) {
    assert(amount >= 0.0 && amount <= 1.0);
    final hsl = HSLColor.fromColor(color);
    final newSaturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(newSaturation).toColor();
  }

  static Color greyscale(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(0.0).toColor();
  }

  static Color complement(Color color) {
    final hsl = HSLColor.fromColor(color);
    final newHue = (hsl.hue + 180) % 360;
    return hsl.withHue(newHue).toColor();
  }

  static List<Color> analogous(Color color, {int count = 2}) {
    final hsl = HSLColor.fromColor(color);
    const step = 30.0;
    return List.generate(count, (i) {
      final offset = (i + 1) * step;
      final newHue = (hsl.hue + offset) % 360;
      return hsl.withHue(newHue).toColor();
    });
  }

  static List<Color> triadic(Color color) {
    final hsl = HSLColor.fromColor(color);
    return [
      color,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  static double getColorDistance(Color color1, Color color2) {
    final r = (color1.red - color2.red).abs();
    final g = (color1.green - color2.green).abs();
    final b = (color1.blue - color2.blue).abs();
    return math.sqrt(r * r + g * g + b * b);
  }

  static bool areColorsSimilar(
    Color color1,
    Color color2, {
    double threshold = 50.0,
  }) {
    return getColorDistance(color1, color2) < threshold;
  }

  static Color interpolate(Color start, Color end, double progress) {
    assert(progress >= 0.0 && progress <= 1.0);
    return Color.lerp(start, end, progress) ?? start;
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static Color withAlphaFraction(Color color, double alpha) {
    return color.withOpacity(alpha.clamp(0.0, 1.0));
  }
}
