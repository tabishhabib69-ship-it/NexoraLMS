// ===== FILE GUIDE: lib/screens/admin/dashboard/admin_dashboard_screen.dart
// WHAT IT DOES : Admin Control dashboard (PDF page 14).
// MANAGES      : Demo status card, students/faculty/courses/posts counts, approvals, activity, quick actions, recent activity.
// USED BY      : admin_shell.dart (Dashboard tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../models/course.dart';
import '../../../models/user.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../courses/add_edit_course_screen.dart';
import '../faculty_assignment/faculty_assignment_screen.dart';
import '../semesters/semester_management_screen.dart';
import '../users/add_edit_user_screen.dart';
import '../settings/audit_log_screen.dart';
import '../../../widgets/uni_widgets.dart' show DemoTag;
import '../../../widgets/ui_kit.dart';

/// Admin dashboard ("Admin Control") hosted inside [AdminShell].
class AdminDashboardScreen extends StatefulWidget {
  /// Switches the shell to another tab (1 Users, 2 Courses, 3 Reports, 4 Settings).
  final ValueChanged<int> onOpenTab;

  AdminDashboardScreen({super.key, required this.onOpenTab});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final admin = SessionService.currentUser ?? DummyData.admin;
    final students = DummyData.users.where((u) => u.role == UserRole.student).length;
    final faculty = DummyData.users.where((u) => u.role == UserRole.faculty).length;
    final courses = DummyData.courses;
    final credits = courses.fold<int>(0, (sum, c) => sum + c.credits);
    final posts = DummyData.posts.length;
    final official = DummyData.posts.where((p) => p.official).length;
    final active = DummyData.semesters.where((s) => s.isActive).firstOrNull;
    final approvals =
        DummyData.posts.where((p) => p.reported).length +
        DummyData.enrollmentRequests.where((r) => r.status == RequestStatus.pending).length;
    final weekActivity = DummyData.auditLog.where((e) => DateTime.now().difference(e.time).inDays < 7).length;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        AdminPageHeader(
          eyebrow: DummyData.universityName,
          title: 'Admin\nControl',
          actions: [
            CircleIconButton(
              icon: Icons.notifications_none_rounded,
              showDot: approvals > 0,
              onTap: () => widget.onOpenTab(3),
            ),
            GestureDetector(
              onTap: () => widget.onOpenTab(4),
              child: AdminAvatar(initials: admin.initials, size: 52),
            ),
          ],
        ),
        SizedBox(height: 22),

        // Environment notice — no live server metrics exist in this build.
        SoftCard(
          color: AppColors.surfaceAlt,
          outlined: true,
          padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Row(
            children: [
              Icon(Icons.dns_outlined, color: AppColors.sand),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EyebrowLabel('System status', color: AppColors.textPrimary),
                    SizedBox(height: 4),
                    Text(
                      'Demo environment · local sample data, no server connected',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              DemoTag(label: 'DEMO'),
            ],
          ),
        ),
        SizedBox(height: 16),

        // Overview grid
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.person_outline_rounded,
                value: '$students',
                label: 'Students',
                note: '${active?.name ?? 'No active'} semester',
                onTap: () => widget.onOpenTab(1),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                icon: Icons.person_outline_rounded,
                gradient: AppColors.sandGradient,
                value: '$faculty',
                label: 'Faculty',
                note: 'Teaching ${courses.length} courses',
                onTap: () => widget.onOpenTab(1),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.menu_book_outlined,
                value: '${courses.length}',
                label: 'Courses',
                note: '$credits credit hours',
                noteColor: AppColors.primary,
                onTap: () => widget.onOpenTab(2),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _MetricCard(
                icon: Icons.dynamic_feed_outlined,
                gradient: AppColors.roseGradient,
                value: '$posts',
                label: 'Feed Posts',
                note: '$official official',
                onTap: () => widget.onOpenTab(3),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),

        // Approvals & activity
        Row(
          children: [
            Expanded(
              child: SoftCard(
                gradient: AppColors.wineGradient,
                onTap: () => widget.onOpenTab(3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EyebrowLabel('Approvals', color: Color(0xFFD9CFCF)),
                    SizedBox(height: 8),
                    Text(
                      '$approvals',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    SizedBox(height: 6),
                    Text('Pending actions', style: TextStyle(fontSize: 13.5, color: Color(0xFFCFC39E))),
                  ],
                ),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: SoftCard(
                onTap: () => _go(AuditLogScreen()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EyebrowLabel('Activity'),
                    SizedBox(height: 8),
                    Text(
                      '$weekActivity',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                    SizedBox(height: 6),
                    Text('Actions this week', style: TextStyle(fontSize: 13.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 26),

        // Quick actions
        Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuickAction(icon: Icons.person_add_alt_rounded, label: 'Hire\nTeacher', onTap: _hireTeacher),
            _QuickAction(
              icon: Icons.add_rounded,
              label: 'Add\nCourse',
              gradient: AppColors.sandGradient,
              onTap: _addCourse,
            ),
            _QuickAction(
              icon: Icons.assignment_ind_outlined,
              label: 'Assign\nFaculty',
              gradient: AppColors.roseGradient,
              onTap: () => _go(FacultyAssignmentScreen()),
            ),
            _QuickAction(
              icon: Icons.calendar_month_outlined,
              label: 'Semesters',
              onTap: () => _go(SemesterManagementScreen()),
            ),
          ],
        ),
        SizedBox(height: 26),

        // Recent activity
        Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        SizedBox(height: 12),
        SoftCard(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              for (var i = 0; i < DummyData.recentActivity.length; i++) ...[
                if (i > 0) Divider(height: 1),
                _ActivityRow(item: DummyData.recentActivity[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _hireTeacher() async {
    final created = await Navigator.push<AppUser>(
      context,
      MaterialPageRoute(builder: (_) => AddEditUserScreen(presetRole: UserRole.faculty)),
    );
    if (created != null && mounted) {
      setState(() {});
      DummyData.logAction('Faculty hired', '${created.name} · ${created.designation ?? 'Faculty'}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${created.name} hired as faculty')));
    }
  }

  Future<void> _addCourse() async {
    final created = await Navigator.push<Course>(context, MaterialPageRoute(builder: (_) => AddEditCourseScreen()));
    if (created != null && mounted) {
      setState(() => DummyData.courses.add(created));
      DummyData.logAction('Course created', '${created.code} ${created.title}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Course ${created.code} added')));
    }
  }

  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final String value;
  final String label;
  final String note;
  final Color? noteColor;
  final VoidCallback onTap;

  _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.note,
    required this.onTap,
    this.gradient = AppColors.wineGradient,
    this.noteColor,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientIconTile(icon: icon, gradient: gradient),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.1),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          SizedBox(height: 6),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: noteColor ?? AppColors.sand),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  _QuickAction({required this.icon, required this.label, required this.onTap, this.gradient = AppColors.wineGradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              GradientIconTile(icon: icon, gradient: gradient, size: 54),
              SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Map<String, String> item;

  _ActivityRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                SizedBox(height: 2),
                Text(item['detail']!, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
            child: Text(
              item['time']!,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
