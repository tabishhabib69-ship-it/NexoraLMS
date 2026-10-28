// ===== FILE GUIDE: lib/widgets/custom_app_bar.dart
// WHAT IT DOES : Old app bar.
// STATUS       : NOT USED anymore — replaced by AdminPageHeader + CircleBackButton. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Standard app bar with an optional subtitle and trailing actions.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;

  CustomAppBar({super.key, required this.title, this.subtitle, this.actions, this.showBack = true, this.leading});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 6);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      leading:
          leading ??
          (showBack && canPop
              ? IconButton(
                  tooltip: 'Back',
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
            ),
        ],
      ),
      actions: actions,
    );
  }
}
