// ===== FILE GUIDE: lib/screens/faculty/courses/faculty_courses_screen.dart
// WHAT IT DOES : List of courses the faculty member teaches.
// MANAGES      : Opens each course hub; link to the teaching timetable.
// USED BY      : Faculty profile.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../timetable/timetable_screen.dart';
import 'faculty_course_hub_screen.dart';

/// Courses taught by the signed-in faculty member.
class FacultyCoursesScreen extends StatelessWidget {
  const FacultyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = SessionService.currentUser ?? DummyData.faculty;
    final courses = DummyData.courses.where((c) => c.facultyId == me.id).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 14),
            AdminPageHeader(
              eyebrow: 'Teaching this semester',
              title: 'My Courses',
              actions: [
                PillButton(
                  label: 'Timetable',
                  icon: Icons.calendar_month_outlined,
                  filled: false,
                  onPressed: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TimetableScreen(faculty: true))),
                ),
              ],
            ),
            SizedBox(height: 18),
            for (var i = 0; i < courses.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SoftCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FacultyCourseHubScreen(course: courses[i])),
                  ),
                  child: Row(
                    children: [
                      GradientIconTile(
                        icon: Icons.layers_outlined,
                        gradient: i.isEven ? AppColors.wineGradient : AppColors.sandGradient,
                        size: 52,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${courses[i].code}: ${courses[i].title}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${courses[i].schedule} · ${courses[i].room}',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
