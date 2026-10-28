// ===== FILE GUIDE: lib/screens/faculty/courses/course_students_screen.dart
// WHAT IT DOES : Students enrolled in a course.
// MANAGES      : Roster with per-student attendance summary and search.
// USED BY      : Faculty course hub.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/attendance.dart';
import '../../../models/user.dart';
import '../../../services/attendance_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/color_util.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/search_field.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/user_avatar.dart';
import 'passing_criteria_screen.dart';
import 'student_details_screen.dart';

/// Enrolled students for a course, with per-student attendance summaries.
class CourseStudentsScreen extends StatefulWidget {
  final String courseId;
  CourseStudentsScreen({super.key, required this.courseId});

  @override
  State<CourseStudentsScreen> createState() => _CourseStudentsScreenState();
}

class _CourseStudentsScreenState extends State<CourseStudentsScreen> {
  String _query = '';

  /// Students enrolled in this course, derived from attendance records when
  /// available, otherwise from the general student list.
  List<MapEntry<AppUser, AttendanceRecord?>> get _rows {
    final records = DummyData.courseAttendance[widget.courseId] ?? [];

    List<AppUser> students;
    if (records.isNotEmpty) {
      students = records.map((r) => DummyData.userById(r.studentId)).whereType<AppUser>().toList();
    } else {
      students = DummyData.users.where((u) => u.role == UserRole.student).toList();
    }

    return students
        .map((s) {
          final matches = records.where((r) => r.studentId == s.id);
          final record = matches.isEmpty ? null : matches.first;
          return MapEntry(s, record);
        })
        .where((e) {
          final q = _query.toLowerCase();
          return e.key.name.toLowerCase().contains(q) || (e.key.studentId ?? '').toLowerCase().contains(q);
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final course = DummyData.courseById(widget.courseId);
    final rows = _rows;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(course?.code ?? 'Course'),
        actions: [
          IconButton(
            tooltip: 'Passing criteria',
            icon: Icon(Icons.rule_rounded, color: AppColors.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PassingCriteriaScreen(courseId: widget.courseId)),
            ),
          ),
          SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          if (course != null)
            Container(
              margin: EdgeInsets.fromLTRB(18, 4, 18, 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorFromHex(course.color), colorFromHex(course.color).withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${course.code} · ${course.enrolledCount} enrolled',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: SearchField(hint: 'Search students by name or ID...', onChanged: (v) => setState(() => _query = v)),
          ),
          Expanded(
            child: rows.isEmpty
                ? EmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'No students found',
                    message: 'Try a different name or student ID.',
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(18, 4, 18, 24),
                    children: [
                      SectionHeader(title: '${rows.length} student${rows.length == 1 ? '' : 's'}'),
                      ...rows.map((e) => _studentTile(e.key, e.value)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _studentTile(AppUser student, AttendanceRecord? record) {
    final summary = record == null ? null : AttendanceService.summarize(record);
    Color pctColor = AppColors.textMuted;
    if (summary != null) {
      switch (summary.status) {
        case AttendanceStatus.good:
          pctColor = AppColors.success;
          break;
        case AttendanceStatus.warning:
          pctColor = AppColors.warning;
          break;
        case AttendanceStatus.critical:
          pctColor = AppColors.danger;
          break;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailsScreen(studentId: student.id, courseId: widget.courseId),
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                UserAvatar(name: student.name, colorHex: student.avatarColor, size: 46),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 3),
                      Text(
                        student.studentId ?? student.email,
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (summary != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: pctColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${summary.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: pctColor),
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
