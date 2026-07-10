import 'package:flutter/material.dart';

/// 8pt spacing grid, corner radii, and motion constants for the
/// Glassmorphism UI.
class GlassSpacing {
  GlassSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double radiusSm = 20;
  static const double radiusMd = 24;
  static const double radiusLg = 28;

  static const double blurSigma = 16;

  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeOutCubic;

  /// Content is centered and constrained to this width on wide/web viewports.
  static const double maxContentWidth = 720;
}
