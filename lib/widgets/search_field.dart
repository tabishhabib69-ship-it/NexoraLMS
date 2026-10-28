// ===== FILE GUIDE: lib/widgets/search_field.dart
// WHAT IT DOES : Older search field.
// MANAGES      : Rounded text field with a search icon.
// USED BY      : Course students list.
// ======================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded search field used across list screens.
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  SearchField({super.key, required this.hint, required this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.search_rounded, size: 21),
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}
