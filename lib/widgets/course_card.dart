// ===== FILE GUIDE: lib/widgets/course_card.dart
// WHAT IT DOES : Old course card.
// STATUS       : NOT USED anymore — replaced by course rows in the new course screens. Safe to delete.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/course.dart';
import '../theme/app_colors.dart';
import 'color_util.dart';

/// Card summarising a course — used in student & faculty course lists.
class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitleOverride;

  CourseCard({super.key, required this.course, this.onTap, this.trailing, this.subtitleOverride});

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(course.color);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  course.code.split('-').last,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 3),
                    Text(
                      subtitleOverride ?? '${course.code} · ${course.facultyName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _chip(Icons.schedule_rounded, course.schedule, color),
                        SizedBox(width: 8),
                        _chip(Icons.groups_rounded, '${course.enrolledCount}', AppColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
