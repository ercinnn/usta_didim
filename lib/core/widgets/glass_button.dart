import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';
import '../theme/glass_spacing.dart';

enum GlassButtonVariant { primary, secondary }

/// Glassmorphism button: gradient-filled [GlassButtonVariant.primary] or a
/// translucent frosted [GlassButtonVariant.secondary]. Drop-in replacement
/// for `FilledButton`/`OutlinedButton` call sites (same `onPressed`/loading
/// semantics), styled with the glass tokens.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = GlassButtonVariant.primary,
    this.icon,
    this.expanded = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final GlassButtonVariant variant;
  final IconData? icon;
  final bool expanded;
  final bool loading;

  bool get _isPrimary => variant == GlassButtonVariant.primary;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final disabled = onPressed == null || loading;
    final foreground = _isPrimary ? Colors.white : GlassColors.primary;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          ),
        ] else ...[
          if (icon != null) ...[
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: GlassSpacing.sm),
          ],
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: foreground,
            ),
          ),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
      child: Semantics(
        button: true,
        enabled: !disabled,
        // The visible label is swapped for a bare spinner while [loading] is
        // true, which would otherwise leave the button with no accessible
        // name for screen readers. Pin an explicit label so it's always
        // announced, and hide the (now redundant) inline text from the tree.
        label: loading ? '$label, yükleniyor' : label,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
          child: AnimatedContainer(
            duration: GlassSpacing.animationDuration,
            curve: GlassSpacing.animationCurve,
            height: 52,
            width: expanded ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: GlassSpacing.lg),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: _isPrimary
                  ? const LinearGradient(
                      colors: [GlassColors.primary, GlassColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _isPrimary ? null : GlassColors.glassFill(brightness),
              borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
              border: _isPrimary
                  ? null
                  : Border.all(color: GlassColors.glassBorder(brightness)),
              boxShadow: _isPrimary && !disabled
                  ? [
                      BoxShadow(
                        color: GlassColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: ExcludeSemantics(
              child: Opacity(
                opacity: disabled && !loading ? 0.5 : 1,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
