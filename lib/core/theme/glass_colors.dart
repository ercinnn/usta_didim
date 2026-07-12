import 'package:flutter/material.dart';

/// Design tokens for the Glassmorphism / "Liquid Glass" UI.
class GlassColors {
  GlassColors._();

  static const primary = Color(0xFF2563EB);
  static const accent = Color(0xFF3B82F6);

  static const backgroundGradientLightStart = Color(0xFFEEF4FF);
  static const backgroundGradientLightEnd = Color(0xFFDCEBFF);
  static const backgroundGradientDarkStart = Color(0xFF0B1220);
  static const backgroundGradientDarkEnd = Color(0xFF111827);

  static const glassFillLight = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)
  static const glassBorderLight = Color(0x33FFFFFF); // rgba(255,255,255,0.20)
  static const glassFillDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const glassBorderDark = Color(0x26FFFFFF); // rgba(255,255,255,0.15)

  static const textPrimaryLight = Color(0xFF0F172A);
  static const textSecondaryLight = Color(0xFF475569);
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFF94A3B8);

  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const neutral = Color(0xFF94A3B8);

  static LinearGradient backgroundGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundGradientDarkStart, backgroundGradientDarkEnd],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundGradientLightStart, backgroundGradientLightEnd],
          );
  }

  static Color glassFill(Brightness brightness) =>
      brightness == Brightness.dark ? glassFillDark : glassFillLight;

  static Color glassBorder(Brightness brightness) =>
      brightness == Brightness.dark ? glassBorderDark : glassBorderLight;

  static Color textPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondaryLight;
}
