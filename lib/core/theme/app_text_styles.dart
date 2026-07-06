import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Utility text style for the "stamped ticket" vocabulary: category eyebrows,
/// prices, ticket/request numbers. Deliberately not wired into [TextTheme]
/// so it never leaks into buttons or other generic labels.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.ink,
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
