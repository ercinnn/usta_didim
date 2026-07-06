import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A row of 5 stars. Pass [onChanged] for an interactive picker, or omit it
/// for a read-only display (used for both submitting and showing a review).
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 28,
    this.onChanged,
  });

  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final icon = Icon(
          starValue <= rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: AppColors.terracotta,
          size: size,
        );
        if (onChanged == null) return icon;
        return InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () => onChanged!(starValue),
          child: Padding(padding: const EdgeInsets.all(2), child: icon),
        );
      }),
    );
  }
}
