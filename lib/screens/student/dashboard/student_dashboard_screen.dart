// ===== FILE GUIDE: lib/screens/student/dashboard/student_dashboard_screen.dart
// WHAT IT DOES : Student Home (PDF page 2).
// MANAGES      : Greeting, credits/CGPA/attendance strip, week strip, quick actions, course cards, AI insights, upcoming deadlines, recommendations card, announcements.
// USED BY      : student_shell.dart (Home tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../models/announcement.dart';
import '../../../models/course.dart';
import '../../../services/academic_service.dart';
import '../../../services/attendance_service.dart';
import '../../../services/schedule_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../timetable/timetable_screen.dart';
import '../ai/uni_ai_screen.dart';
import '../assignments/assignment_detail_screen.dart';
import '../assignments/assignments_screen.dart';
import '../attendance/student_attendance_screen.dart';
import '../courses/course_details_screen.dart';
import '../courses/student_courses_screen.dart';
import '../lost_found/lost_found_screen.dart';
import '../notifications/notifications_screen.dart';
import '../planner/exam_planner_screen.dart';
import '../planner/recommendations_screen.dart';
import '../search/global_search_screen.dart';
import '../../../services/my_data.dart';

/// Student home (PDF page 2): greeting, academic snapshot, week strip,
/// courses, deadlines, AI insights and announcements.
class StudentDashboardScreen extends StatefulWidget {
  /// Switches the shell tab (1 Feed, 2 Chat, 3 Me).
  final ValueChanged<int> onOpenTab;

  const StudentDashboardScreen({super.key, required this.onOpenTab});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  DateTime _day = DateTime.now();

  Future<void> _push(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = MyData.user;
    final first = user.name.split(' ').first;
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final dueToday = AcademicService.upcomingTasks.where((a) => a.due.isBefore(endOfToday)).length;
    final unread = MyData.notifications.where((n) => !n.read).length;
    final attendance = AttendanceService.aggregate(MyData.attendance);
    final cgpa = AcademicService.cgpa;
    final hasHistory = MyData.termResults.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatLongDay(now),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hello, $first!',
                          maxLines: 1,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        dueToday == 0
                            ? 'Nothing due today · Nice work'
                            : '$dueToday task${dueToday == 1 ? '' : 's'} due today · Stay focused',
                        style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                CircleIconButton(icon: Icons.search_rounded, onTap: () => _push(GlobalSearchScreen())),
                SizedBox(width: 8),
                CircleIconButton(
                  icon: Icons.notifications_none_rounded,
                  showDot: unread > 0,
                  onTap: () => _push(NotificationsScreen()),
                ),
                SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'My profile',
                  child: GestureDetector(
                    onTap: () => widget.onOpenTab(3),
                    child: Container(
                      padding: EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow,
                      ),
                      child: InitialsCircle(initials: initialsOf(user.name), size: 47),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Academic snapshot
            Stack(
              clipBehavior: Clip.none,
              children: [
                StatStrip(
                  items: [
                    (
                      value: hasHistory ? '${AcademicService.completedCredits}' : '—',
                      label: 'Credits · of ${DummyData.programCredits}',
                      color: AppColors.textPrimary,
                    ),
                    (
                      value: hasHistory ? cgpa.toStringAsFixed(2) : '—',
                      label: hasHistory && cgpa >= 3.5 ? "CGPA · Dean's List" : 'CGPA',
                      color: AppColors.primary,
                    ),
                    (
                      value: attendance.totalClasses == 0 ? '—' : '${attendance.percentage.round()}%',
                      label: 'Attend. · This term',
                      color: AppColors.sand,
                    ),
                  ],
                ),
                if (hasHistory) Positioned(top: -9, right: 18, child: DemoTag(label: 'SAMPLE DATA')),
              ],
            ),
            SizedBox(height: 20),

            WeekStrip(
              selected: _day,
              onSelect: (d) {
                setState(() => _day = d);
                _push(TimetableScreen(initialDay: d));
              },
            ),
            SizedBox(height: 24),

            // Quick actions
            _QuickGrid(
              actions: [
                (Icons.menu_book_rounded, 'Courses', () => _push(StudentCoursesScreen())),
                (Icons.calendar_month_rounded, 'Timetable', () => _push(TimetableScreen())),
                (Icons.insights_rounded, 'Attendance', () => _push(StudentAttendanceScreen())),
                (Icons.assignment_outlined, 'Assignments', () => _push(AssignmentsScreen())),
                (Icons.auto_awesome_rounded, 'Ask Uni-AI', () => _push(UniAiScreen())),
                (Icons.dynamic_feed_rounded, 'Campus Feed', () => widget.onOpenTab(1)),
                (Icons.event_note_rounded, 'Exam Plan', () => _push(ExamPlannerScreen())),
                (Icons.travel_explore_rounded, 'Lost & Found', () => _push(LostFoundScreen())),
              ],
            ),
            SizedBox(height: 24),

            // Courses
            SectionTitle('My Courses', action: 'See all', onAction: () => _push(StudentCoursesScreen())),
            if (AcademicService.studentCourses.isEmpty)
              SoftCard(
                child: EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'No courses yet',
                  message:
                      'You are not enrolled in any course this semester. Browse the catalog to see what is offered.',
                  actionLabel: 'Course catalog',
                  onAction: () => _push(StudentCoursesScreen()),
                ),
              )
            else
              SizedBox(
                height: 212,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: AcademicService.studentCourses.length,
                  separatorBuilder: (_, _) => SizedBox(width: 14),
                  itemBuilder: (_, i) {
                    final c = AcademicService.studentCourses[i];
                    return _CourseTile(
                      course: c,
                      index: i,
                      onTap: () => _push(CourseDetailsScreen(course: c)),
                    );
                  },
                ),
              ),
            SizedBox(height: 26),

            // AI insights
            _AiInsights(onOpen: _push),
            SizedBox(height: 26),

            // Upcoming deadlines & exams
            SectionTitle('Upcoming', action: 'All tasks', onAction: () => _push(AssignmentsScreen())),
            _Upcoming(onOpen: _push),
            SizedBox(height: 26),

            // Recommendations teaser
            SoftCard(
              onTap: () => _push(RecommendationsScreen()),
              child: Row(
                children: [
                  GradientIconTile(icon: Icons.recommend_rounded, gradient: AppColors.sandGradient),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Courses for you',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Personalized picks for next semester, with reasons',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
            ),
            SizedBox(height: 26),

            // Announcements
            SectionTitle('Announcements'),
            for (final a in DummyData.announcements.take(3))
              Padding(padding: EdgeInsets.only(bottom: 12), child: _AnnouncementTile(a)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- parts --

class _QuickGrid extends StatelessWidget {
  final List<(IconData, String, VoidCallback)> actions;

  const _QuickGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        childAspectRatio: 0.92,
        children: [
          for (final (icon, label, onTap) in actions)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(16)),
                    child: Icon(icon, color: AppColors.primary, size: 24),
                  ),
                  SizedBox(height: 7),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final Course course;
  final int index;
  final VoidCallback onTap;

  const _CourseTile({required this.course, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const gradients = [AppColors.wineGradient, AppColors.roseGradient, AppColors.sandGradient];
    final progress = DummyData.courseProgress[course.id] ?? 0;
    return Semantics(
      button: true,
      label: '${course.code} ${course.title}, ${(progress * 100).round()} percent complete',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 178,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: gradients[index % gradients.length],
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Color(0x332E2729), blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -34,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.code.replaceAll('-', ' · '),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 19, height: 1.15, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    course.facultyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      ProgressRing(
                        value: progress,
                        size: 46,
                        stroke: 4.5,
                        trackColor: Colors.white.withValues(alpha: 0.2),
                        center: Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11.5),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('Complete', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Insight {
  final String title;
  final String detail;
  final String badge;
  final BannerTone tone;
  final VoidCallback? onTap;

  _Insight(this.title, this.detail, this.badge, this.tone, [this.onTap]);
}

class _AiInsights extends StatelessWidget {
  final Future<void> Function(Widget) onOpen;

  const _AiInsights({required this.onOpen});

  List<_Insight> _build() {
    final list = <_Insight>[];
    final tasks = AcademicService.upcomingTasks;
    if (tasks.isNotEmpty) {
      final t = tasks.first;
      final c = DummyData.courseById(t.courseId);
      final days = t.due.difference(DateTime.now()).inHours;
      list.add(
        _Insight(
          days < 36 ? 'Assignment due ${AcademicService.countdown(t.due).toLowerCase()}' : 'Next deadline',
          '${c?.title} · ${t.title}',
          days < 36 ? 'Urgent' : AcademicService.countdown(t.due),
          days < 36 ? BannerTone.danger : BannerTone.warning,
          () => onOpen(AssignmentDetailScreen(assignment: t)),
        ),
      );
    }
    for (final r in MyData.attendance) {
      final s = AttendanceService.summarize(r);
      if (s.status == AttendanceStatus.critical) {
        list.add(
          _Insight(
            'Attendance at risk',
            '${DummyData.courseById(r.courseId)?.title} · ${s.percentage.toStringAsFixed(1)}% — '
                'attend the next ${s.neededToReach} classes',
            'Below 75%',
            BannerTone.danger,
            () => onOpen(StudentAttendanceScreen()),
          ),
        );
      }
    }
    final exams = AcademicService.upcomingExams;
    if (exams.isNotEmpty) {
      final e = exams.first;
      list.add(
        _Insight(
          'Exam reminder',
          '${e.title} · ${formatDateTime(e.date)}',
          AcademicService.countdown(e.date),
          BannerTone.warning,
          () => onOpen(ExamPlannerScreen()),
        ),
      );
    }
    final today = DateTime.now();
    final classes = ScheduleService.classesOn(today);
    for (final c in classes) {
      if (ScheduleService.statusOf(c, today, classes) == SlotStatus.next) {
        final mins = ScheduleService.minutesOf(c.start) - (today.hour * 60 + today.minute);
        final course = DummyData.courseById(c.courseId);
        list.add(
          _Insight(
            'Class starting soon',
            '${course?.title} · Today at ${c.start} · ${c.room}',
            mins < 60 ? '${mins}m away' : '${(mins / 60).floor()}h away',
            BannerTone.success,
            () => onOpen(TimetableScreen()),
          ),
        );
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final insights = _build();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          'AI Insights',
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: AppColors.sandSoft, borderRadius: BorderRadius.circular(20)),
            child: Text(
              '${insights.length} alert${insights.length == 1 ? '' : 's'}',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
        if (insights.isEmpty)
          SoftCard(
            child: EmptyState(
              icon: Icons.celebration_outlined,
              title: 'All clear',
              message: 'No deadlines, exams or attendance risks right now.',
            ),
          ),
        for (final ins in insights)
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SoftCard(
              onTap: ins.onTap,
              padding: EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(color: _fg(ins.tone), shape: BoxShape.circle),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ins.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 3),
                        Text(ins.detail, style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  StatusPill(label: ins.badge, foreground: _fg(ins.tone), background: _bg(ins.tone)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static Color _fg(BannerTone t) => switch (t) {
    BannerTone.danger => AppColors.primary,
    BannerTone.warning => AppColors.warning,
    BannerTone.success => AppColors.success,
    BannerTone.info => AppColors.info,
  };

  static Color _bg(BannerTone t) => switch (t) {
    BannerTone.danger => AppColors.primarySoft,
    BannerTone.warning => AppColors.warningSoft,
    BannerTone.success => AppColors.mintSoft,
    BannerTone.info => AppColors.infoSoft,
  };
}

class _Upcoming extends StatelessWidget {
  final Future<void> Function(Widget) onOpen;

  const _Upcoming({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final items = <(DateTime, Widget)>[];
    for (final t in AcademicService.upcomingTasks.take(3)) {
      final c = DummyData.courseById(t.courseId);
      items.add((
        t.due,
        _UpcomingRow(
          icon: t.type == TaskType.quiz ? Icons.quiz_outlined : Icons.assignment_outlined,
          title: t.title,
          subtitle: '${c?.code} · due ${formatDateTime(t.due)}',
          badge: AcademicService.countdown(t.due),
          onTap: () => onOpen(AssignmentDetailScreen(assignment: t)),
        ),
      ));
    }
    for (final e in AcademicService.upcomingExams.take(2)) {
      items.add((
        e.date,
        _UpcomingRow(
          icon: Icons.event_outlined,
          title: e.title,
          subtitle: '${formatDateTime(e.date)} · ${e.venue} · ${e.seat}',
          badge: AcademicService.countdown(e.date),
          onTap: () => onOpen(ExamPlannerScreen()),
          gradient: AppColors.sandGradient,
        ),
      ));
    }
    items.sort((a, b) => a.$1.compareTo(b.$1));
    if (items.isEmpty) {
      return SoftCard(
        child: EmptyState(
          icon: Icons.event_available_outlined,
          title: 'No upcoming tasks',
          message: 'You are all caught up. Enjoy the break!',
        ),
      );
    }
    return SoftCard(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[if (i > 0) Divider(height: 1), items[i].$2],
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;
  final Gradient gradient;

  const _UpcomingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
    this.gradient = AppColors.wineGradient,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            GradientIconTile(icon: icon, gradient: gradient, size: 42),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            StatusPill(label: badge, foreground: AppColors.primary, background: AppColors.primarySoft),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  final Announcement a;

  const _AnnouncementTile(this.a);

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (a.priority) {
      AnnouncementPriority.urgent => ('Urgent', AppColors.danger, AppColors.dangerSoft),
      AnnouncementPriority.important => ('Important', AppColors.warning, AppColors.warningSoft),
      AnnouncementPriority.normal => ('Notice', AppColors.textSecondary, AppColors.surfaceAlt),
    };
    return SoftCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(label: label, foreground: fg, background: bg),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${a.courseCode ?? 'University'} · ${timeAgo(a.date)}',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
              ),
              if (a.pinned) Icon(Icons.push_pin_rounded, size: 16, color: AppColors.sand),
            ],
          ),
          SizedBox(height: 10),
          Text(
            a.title,
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(a.body, style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary)),
          SizedBox(height: 6),
          Text('— ${a.authorName}', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
