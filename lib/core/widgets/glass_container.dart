import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';
import '../theme/glass_spacing.dart';

/// Frosted-glass surface: blurred backdrop + translucent fill + thin border
/// + soft shadow. The base building block every other Glass widget composes.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GlassSpacing.md),
    this.margin,
    this.borderRadius = GlassSpacing.radiusMd,
    this.blurSigma = GlassSpacing.blurSigma,
    this.onTap,
    this.width,
    this.height,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fill = color ?? GlassColors.glassFill(brightness);
    final border = borderColor ?? GlassColors.glassBorder(brightness);
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: AnimatedContainer(
            duration: GlassSpacing.animationDuration,
            curve: GlassSpacing.animationCurve,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: radius,
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: brightness == Brightness.dark ? 0.35 : 0.08,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: onTap == null
                ? Padding(padding: padding, child: child)
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: radius,
                      child: Padding(padding: padding, child: child),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
