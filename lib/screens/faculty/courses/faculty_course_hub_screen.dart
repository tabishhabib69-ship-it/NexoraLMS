// ===== FILE GUIDE: lib/screens/faculty/courses/faculty_course_hub_screen.dart
// WHAT IT DOES : One course from the teacher's side.
// MANAGES      : Links to students, attendance, materials, new task, grading, announcements, passing criteria.
// USED BY      : Faculty dashboard and course list.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/course.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../announcements/faculty_announcements_screen.dart';
import '../attendance/faculty_attendance_screen.dart';
import '../dashboard/faculty_dashboard_screen.dart' show pendingGrading;
import '../grading/create_assignment_screen.dart';
import '../grading/grading_queue_screen.dart';
import '../materials/content_studio_screen.dart';
import 'course_students_screen.dart';
import 'passing_criteria_screen.dart';

/// One course from the instructor's side, with every management action.
class FacultyCourseHubScreen extends StatefulWidget {
  final Course course;

  const FacultyCourseHubScreen({super.key, required this.course});

  @override
  State<FacultyCourseHubScreen> createState() => _FacultyCourseHubScreenState();
}

class _FacultyCourseHubScreenState extends State<FacultyCourseHubScreen> {
  Future<void> _push(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.course;
    final materials = DummyData.materials.where((m) => m.courseId == c.id).length;
    final tasks = DummyData.assignments.where((a) => a.courseId == c.id).length;
    final pending = pendingGrading(c.id);
    final actions = <(IconData, String, String, VoidCallback)>[
      (
        Icons.people_outline_rounded,
        'Students',
        '${DummyData.rosterFor(c.id).length} on roster (sample)',
        () => _push(CourseStudentsScreen(courseId: c.id)),
      ),
      (Icons.fact_check_outlined, 'Attendance', 'Mark today\'s class', () => _push(FacultyAttendanceScreen())),
      (Icons.folder_open_outlined, 'Materials', '$materials files', () => _push(ContentStudioScreen(courseId: c.id))),
      (
        Icons.post_add_rounded,
        'New assignment / quiz',
        '$tasks set so far',
        () => _push(CreateAssignmentScreen(courseId: c.id)),
      ),
      (
        Icons.grading_rounded,
        'Grading',
        pending == 0 ? 'Nothing pending' : '$pending to grade',
        () => _push(GradingQueueScreen()),
      ),
      (Icons.campaign_outlined, 'Announcements', 'Post to this course', () => _push(FacultyAnnouncementsScreen())),
      (
        Icons.rule_rounded,
        'Passing criteria',
        'Weights & minimum attendance',
        () => _push(PassingCriteriaScreen(courseId: c.id)),
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 14),
            AdminPageHeader(eyebrow: '${c.code} · Semester ${c.semester}', title: c.title),
            SizedBox(height: 16),
            StatStrip(
              items: [
                (value: '${c.enrolledCount}', label: 'Students', color: AppColors.primary),
                (value: '$materials', label: 'Materials', color: AppColors.sand),
                (value: '$pending', label: 'To grade', color: AppColors.primary),
              ],
            ),
            SizedBox(height: 14),
            InfoBanner(icon: Icons.schedule_rounded, text: '${c.schedule} · Room ${c.room}'),
            SizedBox(height: 18),
            SoftCard(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) Divider(height: 1),
                    AdminNavTile(
                      icon: actions[i].$1,
                      title: actions[i].$2,
                      subtitle: actions[i].$3,
                      onTap: actions[i].$4,
                      gradient: i.isEven ? AppColors.wineGradient : AppColors.sandGradient,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
