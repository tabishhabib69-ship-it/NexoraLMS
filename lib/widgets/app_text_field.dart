// ===== FILE GUIDE: lib/widgets/app_text_field.dart
// WHAT IT DOES : Older labelled text field.
// MANAGES      : Label, hint, icon and validation.
// USED BY      : Older forms (admin add/edit, announcements, edit profile, ...).
// ======================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Reusable labelled text field wired to a [TextEditingController].
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;

  AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffix,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: obscure ? 1 : maxLines,
          enabled: enabled,
          onChanged: onChanged,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
