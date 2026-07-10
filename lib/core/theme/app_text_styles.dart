import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'glass_colors.dart';

/// Monospace utility style for prices/category tags/eyebrows. Deliberately
/// not wired into [TextTheme] so it never leaks into buttons or other
/// generic labels.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = GlassColors.textPrimaryLight,
    double letterSpacing = 0.6,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
