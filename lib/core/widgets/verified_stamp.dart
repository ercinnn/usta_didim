import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The signature "Usta Onaylı" mark: a hand-stamped seal shown next to a
/// provider's name wherever `providers.is_verified` is true. Absence of the
/// stamp *is* the unverified state — there is no separate "not verified"
/// badge, matching how a real workshop seal works.
class VerifiedStamp extends StatelessWidget {
  const VerifiedStamp({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Usta Onaylı',
      child: Transform.rotate(
        angle: -0.14,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.olive,
              width: size * 0.1,
            ),
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.olive,
            size: size * 0.62,
          ),
        ),
      ),
    );
  }
}
