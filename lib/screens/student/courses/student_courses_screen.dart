// ===== FILE GUIDE: lib/screens/student/courses/student_courses_screen.dart
// WHAT IT DOES : Student course list.
// MANAGES      : Search and This semester / Course catalog filter; opens a course.
// USED BY      : Dashboard (Courses, See all).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/course.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../planner/recommendations_screen.dart';
import 'course_details_screen.dart';
import '../../../services/my_data.dart';

/// Course listing with search and semester filter.
class StudentCoursesScreen extends StatefulWidget {
  const StudentCoursesScreen({super.key});

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  String _query = '';
  int _filter = 0; // 0 current term, 1 all catalog

  List<Course> get _courses {
    final base = _filter == 0 ? [for (final id in MyData.courseIds) ?DummyData.courseById(id)] : DummyData.courses;
    final q = _query.toLowerCase();
    return base
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q) ||
              c.facultyName.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton(), Spacer()]),
            SizedBox(height: 16),
            AdminPageHeader(
              eyebrow:
                  '${DummyData.semesters.firstWhere((s) => s.isActive).name} · Semester ${MyData.user.semester ?? '-'}',
              title: 'My Courses',
              actions: [
                PillButton(
                  label: 'For you',
                  icon: Icons.recommend_rounded,
                  filled: false,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecommendationsScreen())),
                ),
              ],
            ),
            SizedBox(height: 18),
            SearchBox(hint: 'Search code, title or instructor…', onChanged: (v) => setState(() => _query = v)),
            SizedBox(height: 14),
            FilterPills(
              labels: ['This semester', 'Course catalog'],
              index: _filter,
              padding: EdgeInsets.zero,
              onChanged: (i) => setState(() => _filter = i),
            ),
            SizedBox(height: 18),
            if (courses.isEmpty)
              EmptyState(icon: Icons.search_off_rounded, title: 'No courses found', message: 'Try a different search.'),
            for (var i = 0; i < courses.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: _CourseRow(course: courses[i], index: i),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final Course course;
  final int index;

  const _CourseRow({required this.course, required this.index});

  @override
  Widget build(BuildContext context) {
    final enrolled = MyData.courseIds.contains(course.id);
    final progress = DummyData.courseProgress[course.id];
    return SoftCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: course))),
      child: Row(
        children: [
          GradientIconTile(
            icon: Icons.layers_outlined,
            gradient: index.isEven ? AppColors.wineGradient : AppColors.sandGradient,
            size: 54,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.sand),
                ),
                SizedBox(height: 2),
                Text(
                  course.title,
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 3),
                Text(
                  '${course.facultyName} · ${course.credits} credit hours',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                if (progress != null) ...[
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: GradientProgress(value: progress, height: 7)),
                      SizedBox(width: 10),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ] else if (!enrolled) ...[
                  SizedBox(height: 8),
                  StatusPill(
                    label: 'Not enrolled',
                    foreground: AppColors.textSecondary,
                    background: AppColors.surfaceAlt,
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
