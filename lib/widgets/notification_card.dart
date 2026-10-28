// ===== FILE GUIDE: lib/widgets/notification_card.dart
// WHAT IT DOES : Old notification row.
// STATUS       : NOT USED anymore — replaced by notifications_screen.dart cards. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/notification.dart';
import '../theme/app_colors.dart';
import 'time_util.dart';

/// Notification row for the notification centre.
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  NotificationCard({super.key, required this.notification, this.onTap});

  Color get _accent {
    switch (notification.type) {
      case NotificationType.announcement:
        return AppColors.lavender;
      case NotificationType.faculty:
        return AppColors.primary;
      case NotificationType.message:
        return AppColors.info;
      case NotificationType.university:
        return AppColors.navy;
      case NotificationType.attendance:
      case NotificationType.assignment:
      case NotificationType.exam:
        return AppColors.danger;
    }
  }

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.faculty:
        return Icons.school_rounded;
      case NotificationType.message:
        return Icons.chat_bubble_rounded;
      case NotificationType.university:
        return Icons.account_balance_rounded;
      case NotificationType.attendance:
        return Icons.fact_check_rounded;
      case NotificationType.assignment:
        return Icons.assignment_outlined;
      case NotificationType.exam:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.read ? AppColors.surface : _accent.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _accent, size: 21),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: notification.read ? FontWeight.w600 : FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(timeAgo(notification.date), style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      notification.body,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        notification.type.label,
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _accent),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 9,
                  height: 9,
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
