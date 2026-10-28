// ===== FILE GUIDE: lib/screens/faculty/courses/student_details_screen.dart
// WHAT IT DOES : One student as seen by the teacher.
// MANAGES      : Profile info and attendance for that course.
// USED BY      : Course students list, Enrollment Manager roster.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../services/attendance_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/attendance_card.dart';
import '../../../widgets/dashboard_widgets.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/profile_header.dart';
import '../../../widgets/section_header.dart';

/// Faculty view of an individual student and their attendance in a course.
class StudentDetailsScreen extends StatelessWidget {
  final String studentId;
  final String courseId;
  StudentDetailsScreen({super.key, required this.studentId, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final student = DummyData.userById(studentId);
    if (student == null) {
      return Scaffold(
        body: EmptyState(icon: Icons.person_off_rounded, title: 'Student not found'),
      );
    }
    final course = DummyData.courseById(courseId);
    final records = DummyData.courseAttendance[courseId] ?? [];
    final matches = records.where((r) => r.studentId == studentId);
    final record = matches.isEmpty ? null : matches.first;
    final summary = record == null ? null : AttendanceService.summarize(record);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        children: [
          Stack(
            children: [
              ProfileHeader(
                user: student,
                chips: [
                  if (student.studentId != null) student.studentId!,
                  if (student.semester != null) 'Semester ${student.semester}',
                  if (course != null) course.code,
                ],
              ),
              Positioned(
                top: 44,
                left: 8,
                child: IconButton(
                  tooltip: 'Back',
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Student Information'),
                AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      InfoRow(icon: Icons.badge_rounded, label: 'Student ID', value: student.studentId ?? '—'),
                      Divider(height: 1),
                      InfoRow(icon: Icons.apartment_rounded, label: 'Department', value: student.department ?? '—'),
                      Divider(height: 1),
                      InfoRow(icon: Icons.email_rounded, label: 'Email', value: student.email),
                      Divider(height: 1),
                      InfoRow(icon: Icons.phone_rounded, label: 'Phone', value: student.phone),
                    ],
                  ),
                ),
                SizedBox(height: 22),
                SectionHeader(title: 'Attendance in ${'this course'}'),
                if (summary != null)
                  AttendanceCard(summary: summary, courseTitle: course?.title, courseCode: course?.code)
                else
                  EmptyState(
                    icon: Icons.fact_check_outlined,
                    title: 'No attendance record',
                    message: 'This student has no attendance recorded for this course yet.',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
