// ===== FILE GUIDE: lib/widgets/announcement_card.dart
// WHAT IT DOES : Announcement card.
// MANAGES      : Shows one announcement with optional edit/delete actions.
// USED BY      : Faculty announcements, university updates.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../theme/app_colors.dart';
import 'time_util.dart';

/// Announcement / notice card used on dashboards and announcement lists.
class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onTap;
  final List<Widget>? actions;

  AnnouncementCard({super.key, required this.announcement, this.onTap, this.actions});

  @override
  Widget build(BuildContext context) {
    final isAdmin = announcement.authorRole == 'Admin';
    final accent = isAdmin ? AppColors.navy : AppColors.lavender;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(isAdmin ? Icons.campaign_rounded : Icons.class_rounded, color: accent, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                announcement.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (announcement.pinned) ...[
                              SizedBox(width: 6),
                              Icon(Icons.push_pin_rounded, size: 14, color: AppColors.warning),
                            ],
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${announcement.authorName} · ${timeAgo(announcement.date)}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                announcement.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
              ),
              if (announcement.courseCode != null || actions != null) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    if (announcement.courseCode != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          announcement.courseCode!,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ),
                    Spacer(),
                    ...?actions,
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
