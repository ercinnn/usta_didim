import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'glass_colors.dart';
import 'glass_spacing.dart';

/// Material 3 theme for the Glassmorphism / "Liquid Glass" redesign.
///
/// Provides the app-wide defaults (colors, input fields, buttons, app bar);
/// the frosted-glass surfaces themselves come from the `Glass*` widgets in
/// `lib/core/widgets/`, which read these tokens directly via [GlassColors].
class GlassTheme {
  GlassTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: GlassColors.primary,
      onPrimary: Colors.white,
      secondary: GlassColors.accent,
      onSecondary: Colors.white,
      tertiary: GlassColors.accent,
      onTertiary: Colors.white,
      error: GlassColors.error,
      onError: Colors.white,
      surface: isDark ? GlassColors.backgroundGradientDarkEnd : Colors.white,
      onSurface: GlassColors.textPrimary(brightness),
      surfaceContainerHighest: isDark
          ? GlassColors.backgroundGradientDarkStart
          : GlassColors.backgroundGradientLightStart,
      outline: GlassColors.glassBorder(brightness),
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: GlassColors.textPrimary(brightness),
      displayColor: GlassColors.textPrimary(brightness),
    ).copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: GlassColors.textPrimary(brightness),
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: GlassColors.textPrimary(brightness),
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: GlassColors.textPrimary(brightness),
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: GlassColors.textSecondary(brightness),
      ),
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
      borderSide: BorderSide(color: GlassColors.glassBorder(brightness)),
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark
          ? GlassColors.backgroundGradientDarkStart
          : GlassColors.backgroundGradientLightStart,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: GlassColors.textPrimary(brightness),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: GlassColors.textPrimary(brightness)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: GlassColors.primary,
        unselectedLabelColor: GlassColors.textSecondary(brightness),
        indicatorColor: GlassColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: GlassColors.glassFill(brightness),
        elevation: 0,
        margin: const EdgeInsets.symmetric(
          horizontal: GlassSpacing.md,
          vertical: GlassSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassSpacing.radiusMd),
          side: BorderSide(color: GlassColors.glassBorder(brightness)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: GlassColors.glassBorder(brightness),
        thickness: 1,
        space: GlassSpacing.xl,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GlassColors.glassFill(brightness),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GlassSpacing.md,
          vertical: GlassSpacing.md,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: GlassColors.primary, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: GlassColors.error),
        ),
        labelStyle: TextStyle(color: GlassColors.textSecondary(brightness)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GlassColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GlassColors.primary,
          side: const BorderSide(color: GlassColors.primary),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GlassColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GlassColors.primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: GlassColors.textPrimary(brightness),
        contentTextStyle: TextStyle(
          color: isDark ? GlassColors.textPrimaryDark : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: GlassColors.primary,
        textColor: GlassColors.textPrimary(brightness),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GlassColors.primary,
      ),
      colorScheme: colorScheme,
    );
  }
}
