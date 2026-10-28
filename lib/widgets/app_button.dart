// ===== FILE GUIDE: lib/widgets/app_button.dart
// WHAT IT DOES : Older standard button.
// MANAGES      : Filled/outlined button with loading state.
// USED BY      : Older forms (admin add/edit, announcements, edit profile, ...).
// ======================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Primary filled action button used across the app.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Color? background;
  final Color? foreground;
  final bool expand;

  AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.background,
    this.foreground,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? AppColors.primary;
    final fg = foreground ?? Colors.white;
    final child = loading
        ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), SizedBox(width: 8)],
              Text(
                label,
                style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          );

    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        minimumSize: Size(expand ? double.infinity : 0, 52),
        padding: expand ? null : EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: child,
    );
  }
}

/// Secondary outlined action button.
class AppOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  AppOutlineButton({super.key, required this.label, this.onPressed, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: c,
        side: BorderSide(color: c),
        minimumSize: Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), SizedBox(width: 8)],
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
