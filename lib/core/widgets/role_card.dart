import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';
import '../theme/glass_spacing.dart';

/// Selectable card for picking an [AppRole]-like choice (customer vs.
/// provider) during sign-up / profile completion.
class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final foreground = selected ? Colors.white : GlassColors.textPrimary(brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
      child: AnimatedContainer(
        duration: GlassSpacing.animationDuration,
        curve: GlassSpacing.animationCurve,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [GlassColors.primary, GlassColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : GlassColors.glassFill(brightness),
          borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
          border: Border.all(
            color: selected ? Colors.transparent : GlassColors.glassBorder(brightness),
            width: selected ? 0 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
