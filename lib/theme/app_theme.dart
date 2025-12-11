// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        bgColor: AppColors.lightBg,
        primaryColor: AppColors.lightAccent,
        secondaryColor: AppColors.lightAccentSecondary,
        surfaceColor: AppColors.lightSurfacePrimary,
        surfaceVariant: AppColors.lightSurfaceSecondary,
        textColor: AppColors.lightText,
        textSecondary: AppColors.lightTextSecondary,
        textTertiary: AppColors.lightTextTertiary,
        dividerColor: AppColors.lightDivider,
        errorColor: const Color(0xFFEF4444),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.lightBg,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        dividerOpacity: 0.5,
        borderOpacity: 0.5,
      );

  static ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        bgColor: AppColors.darkBg,
        primaryColor: AppColors.darkAccent,
        secondaryColor: AppColors.darkAccentSecondary,
        surfaceColor: AppColors.darkSurfacePrimary,
        surfaceVariant: AppColors.darkSurfaceSecondary,
        textColor: AppColors.darkText,
        textSecondary: AppColors.darkTextSecondary,
        textTertiary: AppColors.darkTextTertiary,
        dividerColor: AppColors.darkDivider,
        errorColor: const Color(0xFFFB7185),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.darkBg,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        dividerOpacity: 0.3,
        borderOpacity: 0.3,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bgColor,
    required Color primaryColor,
    required Color secondaryColor,
    required Color surfaceColor,
    required Color surfaceVariant,
    required Color textColor,
    required Color textSecondary,
    required Color textTertiary,
    required Color dividerColor,
    required Color errorColor,
    required SystemUiOverlayStyle systemOverlayStyle,
    required double dividerOpacity,
    required double borderOpacity,
  }) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = _buildTextTheme(
      baseColor: textColor,
      secondaryColor: textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        surfaceContainerHighest: surfaceVariant,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        error: errorColor,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme,
      appBarTheme: _buildAppBarTheme(
        textColor: textColor,
        systemOverlayStyle: systemOverlayStyle,
      ),
      inputDecorationTheme: _buildInputTheme(
        fillColor: surfaceVariant,
        dividerColor: dividerColor,
        primaryColor: primaryColor,
        errorColor: errorColor,
        textTertiary: textTertiary,
        borderOpacity: borderOpacity,
      ),
      floatingActionButtonTheme: _buildFABTheme(primaryColor),
      dividerTheme: _buildDividerTheme(dividerColor, dividerOpacity),
      cardTheme: _buildCardTheme(surfaceColor),
      chipTheme: _buildChipTheme(surfaceVariant, primaryColor),
      snackBarTheme: _buildSnackBarTheme(isDark, surfaceColor, textColor),
      iconTheme: IconThemeData(color: textColor, size: 24),
      primaryIconTheme: IconThemeData(color: primaryColor, size: 24),
      elevatedButtonTheme: _buildElevatedButtonTheme(primaryColor),
      outlinedButtonTheme:
          _buildOutlinedButtonTheme(isDark, primaryColor, dividerColor),
      textButtonTheme: _buildTextButtonTheme(primaryColor),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.xlRadius),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? Colors.white : Colors.black87,
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
        textStyle: TextStyle(
          color: isDark ? Colors.black : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return null;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withOpacity(0.3),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: primaryColor.withOpacity(0.3),
      ),
    );
  }

  static TextTheme _buildTextTheme({
    required Color baseColor,
    required Color secondaryColor,
  }) {
    return GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: _textStyle(
        color: baseColor,
        size: 40,
        weight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.5,
      ),
      displayMedium: _textStyle(
        color: baseColor,
        size: 36,
        weight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.0,
      ),
      displaySmall: _textStyle(
        color: baseColor,
        size: 32,
        weight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.8,
      ),
      headlineLarge: _textStyle(
        color: baseColor,
        size: 28,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      headlineMedium: _textStyle(
        color: baseColor,
        size: 24,
        weight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      ),
      headlineSmall: _textStyle(
        color: baseColor,
        size: 20,
        weight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      titleLarge: _textStyle(
        color: baseColor,
        size: 18,
        weight: FontWeight.w600,
        height: 1.4,
      ),
      titleMedium: _textStyle(
        color: baseColor,
        size: 16,
        weight: FontWeight.w600,
        height: 1.4,
      ),
      titleSmall: _textStyle(
        color: baseColor,
        size: 14,
        weight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: _textStyle(
        color: baseColor,
        size: 16,
        weight: FontWeight.w400,
        height: 1.6,
      ),
      bodyMedium: _textStyle(
        color: baseColor,
        size: 14,
        weight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: _textStyle(
        color: secondaryColor,
        size: 13,
        weight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: _textStyle(
        color: secondaryColor,
        size: 14,
        weight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: _textStyle(
        color: secondaryColor,
        size: 12,
        weight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: _textStyle(
        color: secondaryColor,
        size: 11,
        weight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  static TextStyle _textStyle({
    required Color color,
    required double size,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      color: color,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static AppBarTheme _buildAppBarTheme({
    required Color textColor,
    required SystemUiOverlayStyle systemOverlayStyle,
  }) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: systemOverlayStyle,
      iconTheme: IconThemeData(color: textColor, size: 24),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme({
    required Color fillColor,
    required Color dividerColor,
    required Color primaryColor,
    required Color errorColor,
    required Color textTertiary,
    required double borderOpacity,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: _buildInputBorder(),
      enabledBorder: _buildInputBorder(
        borderColor: dividerColor.withOpacity(borderOpacity),
      ),
      focusedBorder: _buildInputBorder(borderColor: primaryColor, width: 2),
      errorBorder: _buildInputBorder(borderColor: errorColor),
      focusedErrorBorder: _buildInputBorder(borderColor: errorColor, width: 2),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: textTertiary,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  static OutlineInputBorder _buildInputBorder({
    Color? borderColor,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      borderSide: borderColor == null
          ? BorderSide.none
          : BorderSide(color: borderColor, width: width),
    );
  }

  static FloatingActionButtonThemeData _buildFABTheme(Color primaryColor) {
    return FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  static DividerThemeData _buildDividerTheme(Color color, double opacity) {
    return DividerThemeData(
      color: color.withOpacity(opacity),
      thickness: 1,
      space: 1,
    );
  }

  static CardThemeData _buildCardTheme(Color surfaceColor) {
    return CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ChipThemeData _buildChipTheme(
    Color surfaceVariant,
    Color primaryColor,
  ) {
    return ChipThemeData(
      backgroundColor: surfaceVariant,
      selectedColor: primaryColor.withOpacity(0.15),
      disabledColor: surfaceVariant.withOpacity(0.5),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme(
    bool isDark,
    Color surfaceColor,
    Color textColor,
  ) {
    return SnackBarThemeData(
      backgroundColor: isDark ? surfaceColor : textColor,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: isDark ? textColor : Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(Color primaryColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(
    bool isDark,
    Color primaryColor,
    Color dividerColor,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: dividerColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(Color primaryColor) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
