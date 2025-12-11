// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // Light Mode
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurfacePrimary = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF1F5F9);
  static const Color lightSurfaceTertiary = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);
  static const Color lightAccent = Color(0xFF6366F1);
  static const Color lightAccentSecondary = Color(0xFF8B5CF6);
  static const Color lightAccentDark = Color(0xFF4F46E5);
  static const Color lightAccentSoft = Color(0xFFE0E7FF);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightGlow = Color(0xFF6366F1);

  // Dark Mode
  static const Color darkBg = Color(0xFF0C0F14);
  static const Color darkSurfacePrimary = Color(0xFF161B26);
  static const Color darkSurfaceSecondary = Color(0xFF1E2433);
  static const Color darkSurfaceTertiary = Color(0xFF2A3142);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkAccent = Color(0xFF818CF8);
  static const Color darkAccentSecondary = Color(0xFFA78BFA);
  static const Color darkAccentDark = Color(0xFF6366F1);
  static const Color darkAccentSoft = Color(0xFF312E81);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkGlow = Color(0xFF818CF8);

// Note Colors
  static const List<Color> noteColors = [
    Color(0xFFF43F5E),
    Color(0xFFF97316),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),

    // DARK GREY (NEW)
    Color(0xFF475569),
  ];

  static const List<List<Color>> noteGradients = [
    [Color(0xFFF43F5E), Color(0xFFFB7185)],
    [Color(0xFFF97316), Color(0xFFFB923C)],
    [Color(0xFFEAB308), Color(0xFFFACC15)],
    [Color(0xFF22C55E), Color(0xFF4ADE80)],
    [Color(0xFF06B6D4), Color(0xFF22D3EE)],
    [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    [Color(0xFFEC4899), Color(0xFFF472B6)],

    // DARK GREY GRADIENT (NEW)
    [Color(0xFF475569), Color(0xFF64748B)],
  ];

  static const List<Color> glassColors = [
    Color(0x1AF43F5E),
    Color(0x1AF97316),
    Color(0x1AEAB308),
    Color(0x1A22C55E),
    Color(0x1A06B6D4),
    Color(0x1A3B82F6),
    Color(0x1A8B5CF6),
    Color(0x1AEC4899),
  ];
}

extension ColorAlpha on Color {
  Color withAlphaFraction(double alpha) => withOpacity(alpha.clamp(0.0, 1.0));
}
