import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';
import '../theme/glass_spacing.dart';

/// `TextFormField` with the frosted-glass decoration baked in. Passes through
/// the same params existing forms already use (`controller`, `validator`,
/// `keyboardType`, `obscureText`, `maxLines`, `onChanged`) so call sites swap
/// in without touching their validation/state logic.
class GlassTextField extends StatelessWidget {
  const GlassTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.enabled = true,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool autofocus;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = BorderRadius.circular(GlassSpacing.radiusSm);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: GlassColors.glassBorder(brightness)),
    );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? null : minLines,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      autofocus: autofocus,
      enabled: enabled,
      autofillHints: autofillHints,
      style: TextStyle(color: GlassColors.textPrimary(brightness)),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
        filled: true,
        fillColor: GlassColors.glassFill(brightness),
        border: border,
        enabledBorder: border,
        disabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: GlassColors.primary, width: 2),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: GlassColors.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: GlassColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GlassSpacing.md,
          vertical: GlassSpacing.md,
        ),
        labelStyle: TextStyle(color: GlassColors.textSecondary(brightness)),
        hintStyle: TextStyle(color: GlassColors.textSecondary(brightness)),
      ),
    );
  }
}
