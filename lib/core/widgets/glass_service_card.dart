import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';
import '../theme/glass_spacing.dart';
import 'glass_container.dart';

/// Frosted-glass list card for request/offer/job listings — the Glassmorphism
/// replacement for `TicketCard`. Same role: an `eyebrow` category label with
/// an `accentColor` (usually a status color), a body `child`, and an optional
/// `trailing` widget (e.g. a verified stamp or count badge).
class GlassServiceCard extends StatelessWidget {
  const GlassServiceCard({
    super.key,
    required this.eyebrow,
    required this.child,
    this.trailing,
    this.accentColor = GlassColors.primary,
    this.onTap,
  });

  final String eyebrow;
  final Widget child;
  final Widget? trailing;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return GlassContainer(
      margin: const EdgeInsets.symmetric(
        horizontal: GlassSpacing.md,
        vertical: GlassSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(
        GlassSpacing.md,
        GlassSpacing.sm,
        GlassSpacing.md,
        GlassSpacing.md,
      ),
      borderRadius: GlassSpacing.radiusMd,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: GlassSpacing.sm),
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
              Expanded(
                child: Text(
                  eyebrow.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: accentColor,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: GlassSpacing.sm),
          Divider(color: GlassColors.glassBorder(brightness), height: 1),
          const SizedBox(height: GlassSpacing.sm),
          child,
        ],
      ),
    );
  }
}
