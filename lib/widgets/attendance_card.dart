// ===== FILE GUIDE: lib/widgets/attendance_card.dart
// WHAT IT DOES : Attendance summary card with a ring.
// MANAGES      : Percentage, attended/missed and status for one course.
// USED BY      : Faculty student details.
// ======================================================================

import 'package:flutter/material.dart';

import '../services/attendance_service.dart';
import '../theme/app_colors.dart';

/// Rich attendance card with a circular progress ring and dynamic stats.
///
/// All figures come from [AttendanceSummary], so the percentage and the
/// "remaining allowed absences" / "classes needed" numbers always reflect the
/// underlying data rather than being fixed at 75%.
class AttendanceCard extends StatelessWidget {
  final AttendanceSummary summary;
  final String? courseTitle;
  final String? courseCode;
  final VoidCallback? onTap;
  final bool compact;

  AttendanceCard({
    super.key,
    required this.summary,
    this.courseTitle,
    this.courseCode,
    this.onTap,
    this.compact = false,
  });

  Color get _statusColor {
    switch (summary.status) {
      case AttendanceStatus.good:
        return AppColors.success;
      case AttendanceStatus.warning:
        return AppColors.warning;
      case AttendanceStatus.critical:
        return AppColors.danger;
    }
  }

  Color get _statusSoft {
    switch (summary.status) {
      case AttendanceStatus.good:
        return AppColors.successSoft;
      case AttendanceStatus.warning:
        return AppColors.warningSoft;
      case AttendanceStatus.critical:
        return AppColors.dangerSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = AttendanceService.clampPct(summary.percentage);
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
          child: Row(
            children: [
              _ring(pct),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (courseTitle != null)
                      Text(
                        courseTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    if (courseCode != null)
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(courseCode!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                    if (courseTitle != null) SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _miniStat('Present', '${summary.attended}', AppColors.success),
                        _miniStat('Absent', '${summary.missed}', AppColors.danger),
                        _miniStat('Total', '${summary.totalClasses}', AppColors.info),
                      ],
                    ),
                    if (!compact) ...[
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: _statusSoft, borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon, size: 15, color: _statusColor),
                            SizedBox(width: 6),
                            Text(
                              summary.status.label,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _statusColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AttendanceService.hint(summary),
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _statusIcon {
    switch (summary.status) {
      case AttendanceStatus.good:
        return Icons.check_circle_rounded;
      case AttendanceStatus.warning:
        return Icons.warning_amber_rounded;
      case AttendanceStatus.critical:
        return Icons.error_rounded;
    }
  }

  Widget _ring(double pct) {
    return SizedBox(
      width: compact ? 66 : 78,
      height: compact ? 66 : 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: pct / 100,
              strokeWidth: 7,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(_statusColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: compact ? 15 : 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (!compact) Text('attended', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6),
          Text('$label ', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
