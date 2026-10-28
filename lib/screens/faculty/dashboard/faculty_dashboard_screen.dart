// ===== FILE GUIDE: lib/screens/faculty/dashboard/faculty_dashboard_screen.dart
// WHAT IT DOES : Faculty Home (PDF page 11).
// MANAGES      : Courses/students/to-grade counts, active courses, pending grading, today's classes, quick actions. Also defines pendingGrading().
// USED BY      : faculty_shell.dart (Home tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/course.dart';
import '../../../services/schedule_service.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../timetable/timetable_screen.dart';
import '../announcements/faculty_announcements_screen.dart';
import '../attendance/faculty_attendance_screen.dart';
import '../courses/faculty_course_hub_screen.dart';
import '../grading/create_assignment_screen.dart';
import '../grading/grading_queue_screen.dart';
import '../materials/content_studio_screen.dart';

/// Pending (submitted, ungraded) work per course for the faculty member.
int pendingGrading(String courseId) {
  var n = 0;
  for (final a in DummyData.assignments.where((a) => a.courseId == courseId)) {
    n += (DummyData.submissions[a.id] ?? const {}).values.where((v) => v == null).length;
  }
  return n;
}

/// Faculty portal home (PDF page 11).
class FacultyDashboardScreen extends StatefulWidget {
  /// Switches the shell tab (1 Students, 2 Messages, 3 Profile).
  final ValueChanged<int> onOpenTab;

  const FacultyDashboardScreen({super.key, required this.onOpenTab});

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  Future<void> _push(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionService.currentUser ?? DummyData.faculty;
    final courses = DummyData.courses.where((c) => c.facultyId == user.id).toList();
    final students = courses.fold<int>(0, (s, c) => s + c.enrolledCount);
    final pending = courses.fold<int>(0, (s, c) => s + pendingGrading(c.id));
    final top = MediaQuery.of(context).padding.top;
    final today = ScheduleService.classesOn(DateTime.now());
    final queue = [
      for (final a in DummyData.assignments.where((a) => courses.any((c) => c.id == a.courseId)))
        if ((DummyData.submissions[a.id] ?? const {}).values.any((v) => v == null)) a,
    ];

    return ListView(
      padding: EdgeInsets.only(bottom: 28),
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 190 + top,
              width: double.infinity,
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(20, top + 22, 20, 0),
              child: Stack(
                children: [
                  Positioned(
                    right: -60,
                    top: -70,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FACULTY PORTAL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        user.name,
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${user.department ?? ''} · ${user.designation ?? ''}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 150 + top,
              child: GestureDetector(
                onTap: () => widget.onOpenTab(3),
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: AdminAvatar(initials: initialsOf(user.name), gradient: AppColors.sandGradient, size: 66),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 46),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Stat(value: '${courses.length}', label: 'Courses', color: AppColors.primary),
                  SizedBox(width: 12),
                  _Stat(value: '$students', label: 'Students', color: AppColors.sand),
                  SizedBox(width: 12),
                  _Stat(
                    value: '$pending',
                    label: 'To grade',
                    color: AppColors.primary,
                    onTap: () => _push(GradingQueueScreen()),
                  ),
                ],
              ),
              SizedBox(height: 24),
              SectionTitle('Active Courses'),
              for (var i = 0; i < courses.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _CourseRow(
                    course: courses[i],
                    index: i,
                    pending: pendingGrading(courses[i].id),
                    onTap: () => _push(FacultyCourseHubScreen(course: courses[i])),
                  ),
                ),
              SizedBox(height: 8),
              SoftCard(
                color: AppColors.surfaceAlt,
                outlined: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pending to Grade',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        TextButton(onPressed: () => _push(GradingQueueScreen()), child: Text('View All')),
                      ],
                    ),
                    if (queue.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'All caught up — nothing waiting for grades.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    for (var i = 0; i < queue.length; i++) ...[
                      if (i > 0) Divider(height: 18),
                      InkWell(
                        onTap: () => _push(GradingQueueScreen(initialAssignmentId: queue[i].id)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${queue[i].title} · ${DummyData.courseById(queue[i].courseId)?.code}',
                                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                                ),
                              ),
                              Text(
                                '${(DummyData.submissions[queue[i].id] ?? const {}).values.where((v) => v == null).length} ungraded',
                                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GradientButton(label: 'Upload Material', onPressed: () => _push(ContentStudioScreen())),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _push(GradingQueueScreen()),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        minimumSize: Size.fromHeight(56),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('Grade All'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              SectionTitle(
                "Today's Classes",
                action: 'Timetable',
                onAction: () => _push(TimetableScreen(faculty: true)),
              ),
              if (today.isEmpty) Text('No classes today.', style: TextStyle(color: AppColors.textSecondary)),
              for (final t in today)
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: SoftCard(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        GradientIconTile(icon: Icons.schedule_rounded, size: 42),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${DummyData.courseById(t.courseId)?.code} · ${t.type} · ${t.room}',
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          t.start,
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 18),
              SectionTitle('Quick Actions'),
              SoftCard(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                child: Row(
                  children: [
                    _Action(Icons.post_add_rounded, 'New task', () => _push(CreateAssignmentScreen())),
                    _Action(Icons.fact_check_outlined, 'Attendance', () => _push(FacultyAttendanceScreen())),
                    _Action(Icons.campaign_outlined, 'Announce', () => _push(FacultyAnnouncementsScreen())),
                    _Action(Icons.how_to_reg_outlined, 'Enrollment', () => widget.onOpenTab(1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _Stat({required this.value, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SoftCard(
        onTap: onTap,
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color),
            ),
            SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final Course course;
  final int index;
  final int pending;
  final VoidCallback onTap;

  const _CourseRow({required this.course, required this.index, required this.pending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GradientIconTile(
            icon: index.isEven ? Icons.layers_outlined : Icons.description_outlined,
            gradient: index.isEven ? AppColors.wineGradient : AppColors.sandGradient,
            size: 52,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${course.code}: ${course.title}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 2),
                Text(
                  '${course.enrolledCount} students · Sem ${course.semester}',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          pending > 0
              ? StatusPill(label: '$pending due', foreground: AppColors.primary, background: AppColors.primarySoft)
              : StatusPill(label: 'All good', foreground: AppColors.sandDeep, background: AppColors.mintSoft),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Action(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: AppColors.primary),
              ),
              SizedBox(height: 7),
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
