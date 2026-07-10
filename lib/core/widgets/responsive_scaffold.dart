import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';
import '../theme/glass_spacing.dart';

/// Scaffold wrapper providing the Glassmorphism gradient background and a
/// centered, width-constrained body on wide/web viewports, so the same
/// widget tree looks right on mobile and desktop/web without per-platform
/// branching. Drop-in for `Scaffold` (same `appBar`/`body`/
/// `floatingActionButton` surface) — screens keep their own state/providers.
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: GlassColors.backgroundGradient(brightness),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: GlassSpacing.maxContentWidth,
                ),
                child: body,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
