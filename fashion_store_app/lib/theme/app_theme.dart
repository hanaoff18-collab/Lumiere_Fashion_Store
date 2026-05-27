import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Editorial luxury palette: ink, warm paper, champagne gold accents.
abstract final class AppColors {
  static const primary = Color(0xFF1A1D2E);
  static const primaryDark = Color(0xFF12141F);
  static const secondary = Color(0xFF8B7355);
  static const accent = Color(0xFFC4A574);
  static const tertiary = Color(0xFF5E6B8E);
  static const success = Color(0xFF2D6A5D);
  static const surface = Color(0xFFF7F5F1);
  static const surfaceContainer = Color(0xFFEEEBE5);
  static const outline = Color(0xFFD9D4CA);
  static const textPrimary = Color(0xFF14141A);
  static const textSecondary = Color(0xFF5C5F6E);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2130),
      Color(0xFF2A3142),
      Color(0xFF3D3548),
    ],
  );

  static const splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF151720),
      Color(0xFF252A38),
      Color(0xFF3D3545),
    ],
  );

  static const offerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5C4A3A),
      Color(0xFF8B7355),
      Color(0xFFC4A574),
    ],
  );

  /// Soft mesh for hero / cards (used with low opacity overlays).
  static const meshAccent = Color(0xFFB8956E);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.surface,
    ),
  );

  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      color: AppColors.textPrimary,
      height: 1.45,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      color: AppColors.textSecondary,
      height: 1.45,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.45)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        foregroundColor: AppColors.secondary,
        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.9)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.85)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.85)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          );
        }
        return GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return IconThemeData(color: AppColors.textSecondary.withValues(alpha: 0.88), size: 24);
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
