// ===== FILE GUIDE: lib/widgets/empty_state.dart
// WHAT IT DOES : Empty and loading placeholders.
// MANAGES      : Icon + message (+ optional button) when a list is empty.
// USED BY      : Most list screens.
// ======================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';

/// Friendly placeholder shown when a list has no content.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  EmptyState({super.key, required this.icon, required this.title, this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: AppColors.textMuted),
            ),
            SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            if (message != null) ...[
              SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
            ],
            if (actionLabel != null) ...[
              SizedBox(height: 20),
              AppButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered loading spinner.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            SizedBox(height: 14),
            Text(message!, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
