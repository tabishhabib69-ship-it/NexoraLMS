// ===== FILE GUIDE: lib/screens/faculty/attendance/faculty_attendance_screen.dart
// WHAT IT DOES : Mark attendance.
// MANAGES      : Pick a course, mark present/absent for each student, save the session.
// USED BY      : Faculty dashboard and course hub.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/attendance.dart';
import '../../../models/user.dart';
import '../../../services/attendance_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/user_avatar.dart';
import '../../../services/my_data.dart';

/// Faculty attendance management: pick a course, mark present/absent, save,
/// and view overall + per-student course attendance.
class FacultyAttendanceScreen extends StatefulWidget {
  FacultyAttendanceScreen({super.key});

  @override
  State<FacultyAttendanceScreen> createState() => _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends State<FacultyAttendanceScreen> {
  late String _courseId = MyData.courseIds.first;
  late List<AttendanceSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  List<AppUser> _studentsFor(String courseId) {
    final records = DummyData.courseAttendance[courseId] ?? [];
    if (records.isNotEmpty) {
      return records.map((r) => DummyData.userById(r.studentId)).whereType<AppUser>().toList();
    }
    return DummyData.users.where((u) => u.role == UserRole.student).toList();
  }

  void _loadSessions() {
    final students = _studentsFor(_courseId);
    _sessions = students.map((s) => AttendanceSession(studentId: s.id, studentName: s.name, present: true)).toList();
  }

  void _selectCourse(String id) {
    setState(() {
      _courseId = id;
      _loadSessions();
    });
  }

  void _setAll(bool value) => setState(() {
    for (final s in _sessions) {
      s.present = value;
    }
  });

  void _save() {
    final present = _sessions.where((s) => s.present).length;
    setState(() {
      final list = DummyData.courseAttendance[_courseId] ?? [];
      final records = <AttendanceRecord>[];
      for (final s in _sessions) {
        final existing = list.where((r) => r.studentId == s.studentId);
        final base = existing.isEmpty
            ? AttendanceRecord(studentId: s.studentId, courseId: _courseId, totalClasses: 0, attended: 0)
            : existing.first;
        records.add(base.copyWith(totalClasses: base.totalClasses + 1, attended: base.attended + (s.present ? 1 : 0)));
      }
      DummyData.courseAttendance[_courseId] = records;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Attendance saved · $present/${_sessions.length} present')));
  }

  @override
  Widget build(BuildContext context) {
    final myCourses = DummyData.courses.where((c) => MyData.courseIds.contains(c.id)).toList();
    final course = DummyData.courseById(_courseId);
    final overall = _overallFor(_courseId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(automaticallyImplyLeading: false, title: Text('Attendance')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          SectionHeader(title: 'Select Course'),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: myCourses.map((c) {
                final sel = c.id == _courseId;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.code),
                    selected: sel,
                    onSelected: (_) => _selectCourse(c.id),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 18),

          // Overall course attendance
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.lavender]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course?.title ?? '',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Class average attendance',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${overall.toStringAsFixed(1)}%',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: overall / 100,
                          strokeWidth: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${overall.toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22),

          // Mark attendance for today's session
          Row(
            children: [
              Expanded(
                child: SectionHeader(title: 'Mark Today\'s Session', padding: EdgeInsets.zero),
              ),
              TextButton(onPressed: () => _setAll(true), child: Text('All present')),
              TextButton(onPressed: () => _setAll(false), child: Text('All absent')),
            ],
          ),
          SizedBox(height: 6),
          if (_sessions.isEmpty)
            EmptyState(icon: Icons.people_outline_rounded, title: 'No students enrolled')
          else
            ..._sessions.map(_studentRow),
          SizedBox(height: 16),
          FilledButton.icon(onPressed: _save, icon: Icon(Icons.save_rounded), label: Text('Save Attendance')),
          SizedBox(height: 20),

          // Per-student standing
          SectionHeader(title: 'Student Attendance Standing'),
          ..._standingRows(),
        ],
      ),
    );
  }

  double _overallFor(String courseId) {
    final records = DummyData.courseAttendance[courseId] ?? [];
    if (records.isEmpty) return 0;
    final pcts = records.map((r) => AttendanceService.percentage(attended: r.attended, total: r.totalClasses)).toList();
    return pcts.reduce((a, b) => a + b) / pcts.length;
  }

  List<Widget> _standingRows() {
    final records = DummyData.courseAttendance[_courseId] ?? [];
    if (records.isEmpty) {
      return [
        EmptyState(
          icon: Icons.insights_rounded,
          title: 'No attendance recorded yet',
          message: 'Mark a session above to generate statistics.',
        ),
      ];
    }
    return records.map((r) {
      final student = DummyData.userById(r.studentId);
      final s = AttendanceService.summarize(r);
      Color color;
      switch (s.status) {
        case AttendanceStatus.good:
          color = AppColors.success;
          break;
        case AttendanceStatus.warning:
          color = AppColors.warning;
          break;
        case AttendanceStatus.critical:
          color = AppColors.danger;
          break;
      }
      return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              if (student != null) ...[
                UserAvatar(name: student.name, colorHex: student.avatarColor, size: 40, fontSize: 14),
                SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student?.name ?? r.studentId,
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: s.percentage / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${s.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
                  ),
                  Text(
                    '${s.attended}/${s.totalClasses}',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _studentRow(AttendanceSession session) {
    final student = DummyData.userById(session.studentId);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          UserAvatar(name: session.studentName, colorHex: student?.avatarColor ?? '#3B6FE0', size: 42, fontSize: 14),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.studentName,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(student?.studentId ?? '', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _toggle(session, true, 'P', AppColors.success),
          SizedBox(width: 6),
          _toggle(session, false, 'A', AppColors.danger),
        ],
      ),
    );
  }

  Widget _toggle(AttendanceSession session, bool presentValue, String label, Color color) {
    final active = session.present == presentValue;
    return GestureDetector(
      onTap: () => setState(() => session.present = presentValue),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active ? color : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? color : AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
