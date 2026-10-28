// ===== FILE GUIDE: lib/screens/admin/settings/admin_settings_screen.dart
// WHAT IT DOES : Admin Settings.
// MANAGES      : Admin profile, academic setup, communication, audit history, reset demo data, dark mode, logout.
// USED BY      : admin_shell.dart (Settings tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../services/app_settings.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/session_actions.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../announcements/official_posts_screen.dart';
import '../announcements/university_updates_screen.dart';
import '../faculty_assignment/faculty_assignment_screen.dart';
import '../semesters/semester_management_screen.dart';
import 'audit_log_screen.dart';

/// Admin settings ("Admin · Account"): profile, academic setup, communication,
/// audit history, appearance and demo data.
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  Future<void> _reset() async {
    final ok = await confirmAction(
      context,
      title: 'Reset demo data?',
      message:
          'Every change made in this session (users, courses, posts, grades, logs) is discarded and the '
          'original sample data restored.',
      confirmLabel: 'Reset',
      destructive: true,
    );
    if (!ok || !mounted) return;
    DummyData.reset();
    setState(() {});
    showSnack(context, 'Demo data restored');
  }

  @override
  Widget build(BuildContext context) {
    final admin = SessionService.currentUser ?? DummyData.admin;
    final active = DummyData.semesters.where((s) => s.isActive).firstOrNull;
    Widget group(String title, List<Widget> tiles) => Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowLabel(title),
          SizedBox(height: 10),
          SoftCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[if (i > 0) Divider(height: 1), tiles[i]],
              ],
            ),
          ),
        ],
      ),
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        AdminPageHeader(eyebrow: 'Admin · Account', title: 'Settings'),
        SizedBox(height: 18),
        SoftCard(
          gradient: AppColors.wineGradient,
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                child: AdminAvatar(initials: admin.initials, gradient: AppColors.sandGradient, size: 58),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin.name,
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    SizedBox(height: 3),
                    Text(
                      admin.designation ?? 'Administrator',
                      style: TextStyle(fontSize: 13, color: Color(0xFFCFC39E)),
                    ),
                    SizedBox(height: 3),
                    Text(
                      admin.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: Color(0xFFD9CFCF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22),
        group('Academic setup', [
          AdminNavTile(
            icon: Icons.calendar_month_outlined,
            title: 'Semester Management',
            subtitle: active == null ? 'No active semester' : '${active.name} is active',
            onTap: () => _go(SemesterManagementScreen()),
          ),
          AdminNavTile(
            icon: Icons.assignment_ind_outlined,
            gradient: AppColors.sandGradient,
            title: 'Faculty Assignment',
            subtitle: 'Assign teachers to courses',
            onTap: () => _go(FacultyAssignmentScreen()),
          ),
        ]),
        group('Communication', [
          AdminNavTile(
            icon: Icons.verified_outlined,
            title: 'Official Posts',
            subtitle: 'Verified posts on the campus feed',
            onTap: () => _go(OfficialPostsScreen()),
          ),
          AdminNavTile(
            icon: Icons.campaign_outlined,
            gradient: AppColors.sandGradient,
            title: 'Announcements',
            subtitle: 'University-wide updates and notices',
            onTap: () => _go(UniversityUpdatesScreen()),
          ),
        ]),
        group('Security & data', [
          AdminNavTile(
            icon: Icons.history_rounded,
            title: 'Audit History',
            subtitle: '${DummyData.auditLog.length} recorded actions',
            onTap: () => _go(AuditLogScreen()),
          ),
          AdminNavTile(
            icon: Icons.restart_alt_rounded,
            gradient: AppColors.roseGradient,
            title: 'Reset demo data',
            subtitle: 'Restore the original sample records',
            onTap: _reset,
          ),
        ]),
        group('Appearance', [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppSettings.themeMode,
            builder: (_, mode, _) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Dark mode',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              value: mode == ThemeMode.dark,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              onChanged: (v) => AppSettings.themeMode.value = v ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
        ]),
        InfoBanner(
          icon: Icons.shield_outlined,
          text:
              'The admin panel is protected in-app only. A production deployment must enforce these permissions '
              'on the server for every request.',
        ),
        SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => confirmLogout(context),
          style: OutlinedButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.danger),
          icon: Icon(Icons.logout_rounded),
          label: Text('Log Out'),
        ),
      ],
    );
  }
}
