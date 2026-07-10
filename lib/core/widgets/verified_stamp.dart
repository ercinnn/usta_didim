import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';

/// The "Usta Onaylı" verified badge shown next to a provider's name wherever
/// `providers.is_verified` is true. Absence of the badge *is* the unverified
/// state — there is no separate "not verified" badge.
class VerifiedStamp extends StatelessWidget {
  const VerifiedStamp({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Usta Onaylı',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [GlassColors.success, GlassColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: size * 0.62,
        ),
      ),
    );
  }
}
