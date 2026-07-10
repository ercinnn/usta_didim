import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';

/// Frosted translucent app bar: content scrolls underneath a blurred bar
/// instead of a solid one. Drop-in for `AppBar` — same `title`/`actions`/
/// `bottom`/`leading` surface, so screens keep their existing navigation
/// (back buttons, tabs) unchanged.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: GlassColors.glassFill(brightness),
            border: Border(
              bottom: BorderSide(color: GlassColors.glassBorder(brightness)),
            ),
          ),
          child: AppBar(
            title: title,
            actions: actions,
            bottom: bottom,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
      ),
    );
  }
}
