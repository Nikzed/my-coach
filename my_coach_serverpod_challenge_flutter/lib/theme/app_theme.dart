import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// MyCoach App Theme - Inspired by military discipline meets warm encouragement
/// Uses a dark theme with copper/bronze accent colors
class AppTheme {
  AppTheme._();

  // Color Palette - "Burnished Discipline"
  static const Color _backgroundDark = Color(0xFF0D0D0F);
  static const Color _surfaceDark = Color(0xFF1A1A1E);
  static const Color _surfaceElevated = Color(0xFF252529);
  static const Color _copper = Color(0xFFD4A574);
  static const Color _copperLight = Color(0xFFE8C9A8);
  static const Color _copperDark = Color(0xFFB8956A);
  static const Color _textPrimary = Color(0xFFF5F5F5);
  static const Color _textSecondary = Color(0xFFA0A0A8);
  static const Color _textMuted = Color(0xFF6B6B73);
  static const Color _success = Color(0xFF4CAF50);
  static const Color _error = Color(0xFFE57373);
  static const Color _warning = Color(0xFFFFB74D);

  // Sergeant coach color - Military red
  static const Color sergeantPrimary = Color(0xFFDC3545);    // Red
  static const Color sergeantSecondary = Color(0xFFFF6B6B);  // Light Red

  // Melly coach color - Warm supportive
  static const Color mellyPrimary = Color(0xFF6B8E23);
  static const Color mellySecondary = Color(0xFF9ACD32);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: _copper,
        onPrimary: _backgroundDark,
        secondary: _copperLight,
        onSecondary: _backgroundDark,
        surface: _surfaceDark,
        onSurface: _textPrimary,
        error: _error,
        onError: _backgroundDark,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.bitter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: _copper),
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2A2A30), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _copper,
          foregroundColor: _backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _copper,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: _copper, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _copper,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _copper,
        foregroundColor: _backgroundDark,
        elevation: 4,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A30), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _copper, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: _textMuted,
          fontSize: 16,
        ),
        labelStyle: GoogleFonts.inter(
          color: _textSecondary,
          fontSize: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A30),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceElevated,
        selectedColor: _copper.withValues(alpha: 0.3),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _textSecondary,
        ),
        side: const BorderSide(color: Color(0xFF2A2A30)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceElevated,
        contentTextStyle: GoogleFonts.inter(
          color: _textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.bitter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: _textSecondary,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _copper;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(_backgroundDark),
        side: const BorderSide(color: _textMuted, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      // WoltModalSheet theme
      extensions: [
        const WoltModalSheetThemeData(
          backgroundColor: _surfaceDark,
          modalBarrierColor: Colors.black54,
          topBarShadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          sabGradientColor: _surfaceDark,
        ),
      ],
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.bitter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: _textPrimary,
      ),
      displayMedium: GoogleFonts.bitter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: -1,
        color: _textPrimary,
      ),
      displaySmall: GoogleFonts.bitter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: _textPrimary,
      ),
      headlineLarge: GoogleFonts.bitter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: _textPrimary,
      ),
      headlineMedium: GoogleFonts.bitter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      headlineSmall: GoogleFonts.bitter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _textSecondary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _textMuted,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: _textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _textMuted,
      ),
    );
  }

  // Custom colors for easy access
  static const Color background = _backgroundDark;
  static const Color surface = _surfaceDark;
  static const Color surfaceElevated = _surfaceElevated;
  static const Color accent = _copper;
  static const Color accentLight = _copperLight;
  static const Color accentDark = _copperDark;
  static const Color textPrimary = _textPrimary;
  static const Color textSecondary = _textSecondary;
  static const Color textMuted = _textMuted;
  static const Color success = _success;
  static const Color error = _error;
  static const Color warning = _warning;
}

/// Extension for getting coach-specific colors
extension CoachColors on String {
  Color get coachPrimaryColor {
    switch (toLowerCase()) {
      case 'sergeant':
        return AppTheme.sergeantPrimary;
      case 'melly':
        return AppTheme.mellyPrimary;
      default:
        return AppTheme.accent;
    }
  }

  Color get coachSecondaryColor {
    switch (toLowerCase()) {
      case 'sergeant':
        return AppTheme.sergeantSecondary;
      case 'melly':
        return AppTheme.mellySecondary;
      default:
        return AppTheme.accentLight;
    }
  }
}
