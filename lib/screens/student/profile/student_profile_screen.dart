// ===== FILE GUIDE: lib/screens/student/profile/student_profile_screen.dart
// WHAT IT DOES : Student profile (PDF page 10).
// MANAGES      : Profile header, stats, Portfolio / Badges / Settings tabs, dark mode switch, logout.
// USED BY      : student_shell.dart (Me tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../services/academic_service.dart';
import '../../../services/app_settings.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/session_actions.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../settings/help_screen.dart';
import '../../settings/settings_screen.dart';
import '../planner/exam_planner_screen.dart';
import '../planner/recommendations_screen.dart';
import 'bookmarks_screen.dart';
import 'edit_profile_screen.dart';
import '../../../services/my_data.dart';

/// Student profile (PDF page 10): hero header, academic stats and
/// Portfolio / Badges / Settings tabs.
class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  int _tab = 0;

  Future<void> _push(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = MyData.user;
    final top = MediaQuery.of(context).padding.top;
    return ListView(
      padding: EdgeInsets.only(bottom: 28),
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 200 + top,
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
              padding: EdgeInsets.fromLTRB(16, top + 12, 16, 0),
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  SizedBox(width: 46),
                  Expanded(
                    child: Text(
                      'My Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Material(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
                    child: IconButton(
                      tooltip: 'Settings',
                      onPressed: () => _push(SettingsScreen()),
                      icon: Icon(Icons.settings_outlined, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 130 + top,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.softShadow,
                ),
                child: InitialsCircle(
                  initials: initialsOf(user.name),
                  size: 104,
                  gradient: LinearGradient(colors: [Color(0xFF8C4A53), Color(0xFFA65E68)]),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 70),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                user.name,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              SizedBox(height: 4),
              Text(
                '${user.department ?? ''} · Semester ${user.semester ?? '-'}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.5, color: AppColors.textSecondary),
              ),
              SizedBox(height: 2),
              Text(
                [
                  if (AppSettings.showStudentIdOnProfile && user.studentId != null) 'Roll No. ${user.studentId}',
                  if (AppSettings.showEmailOnProfile) user.email,
                  DummyData.universityName,
                ].join(' · '),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: AppColors.sand, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 14),
              PillButton(
                label: 'Edit Profile',
                icon: Icons.edit_outlined,
                filled: false,
                onPressed: () => _push(EditProfileScreen(user: user)),
              ),
              SizedBox(height: 18),
              StatStrip(
                items: [
                  (value: '${AcademicService.completedCredits}', label: 'Credits', color: AppColors.textPrimary),
                  (value: AcademicService.cgpa.toStringAsFixed(2), label: 'CGPA', color: AppColors.primary),
                  (value: '${MyData.courseIds.length}', label: 'Courses', color: AppColors.primary),
                  (value: '${DummyData.badges.length}', label: 'Badges', color: AppColors.sand),
                ],
              ),
              SizedBox(height: 18),
              SegmentedTabs(
                labels: ['Portfolio', 'Badges', 'Settings'],
                index: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              SizedBox(height: 16),
              ...switch (_tab) {
                1 => _badges(),
                2 => _settings(),
                _ => _portfolio(user.bio),
              },
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _portfolio(String? bio) => [
    if (bio != null && bio.isNotEmpty)
      SoftCard(
        child: Row(
          children: [
            Icon(Icons.format_quote_rounded, color: AppColors.sand),
            SizedBox(width: 10),
            Expanded(
              child: Text(bio, style: TextStyle(height: 1.45, color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    SizedBox(height: 14),
    _badgeRow(DummyData.badges.take(3).toList()),
    SizedBox(height: 14),
    for (final p in DummyData.portfolio)
      Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SoftCard(
          child: Row(
            children: [
              GradientIconTile(icon: Icons.rocket_launch_outlined, gradient: AppColors.sandGradient),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title']!,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary),
                    ),
                    Text(p['detail']!, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    SizedBox(height: 4),
    SoftCard(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          _link(Icons.bookmark_outline_rounded, 'Bookmarks', () => _push(BookmarksScreen())),
          Divider(height: 1),
          _link(Icons.event_note_outlined, 'Exam planner', () => _push(ExamPlannerScreen())),
          Divider(height: 1),
          _link(Icons.recommend_outlined, 'Courses for you', () => _push(RecommendationsScreen())),
        ],
      ),
    ),
  ];

  Widget _badgeRow(List<dynamic> badges) => Row(
    children: [
      for (var i = 0; i < badges.length; i++) ...[
        if (i > 0) SizedBox(width: 12),
        Expanded(
          child: _BadgeCard(
            title: badges[i].title,
            subtitle: badges[i].subtitle,
            icon: badges[i].icon,
            tone: badges[i].tone,
          ),
        ),
      ],
    ],
  );

  List<Widget> _badges() => [
    for (var i = 0; i < DummyData.badges.length; i += 3) ...[
      _badgeRow(DummyData.badges.skip(i).take(3).toList()),
      SizedBox(height: 12),
    ],
  ];

  List<Widget> _settings() => [
    SoftCard(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppSettings.themeMode,
            builder: (_, mode, _) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.wb_sunny_outlined, color: AppColors.primary),
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              subtitle: Text(
                mode == ThemeMode.system ? 'Use system default' : (mode == ThemeMode.dark ? 'On' : 'Off'),
                style: TextStyle(color: AppColors.sand),
              ),
              value: AppColors.isDark,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              onChanged: (v) => AppSettings.themeMode.value = v ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
          Divider(height: 1),
          _link(
            Icons.notifications_none_rounded,
            'Notifications',
            () => _push(SettingsScreen()),
            subtitle: '${AppSettings.notificationPrefs.values.where((v) => v).length} categories on',
          ),
          Divider(height: 1),
          _link(Icons.tune_rounded, 'All settings', () => _push(SettingsScreen())),
          Divider(height: 1),
          _link(Icons.help_outline_rounded, 'Help & feedback', () => _push(HelpScreen())),
          Divider(height: 1),
          _link(Icons.logout_rounded, 'Log out', () => confirmLogout(context), danger: true),
        ],
      ),
    ),
  ];

  Widget _link(IconData icon, String label, VoidCallback onTap, {String? subtitle, bool danger = false}) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: danger ? AppColors.danger : AppColors.primary),
    title: Text(
      label,
      style: TextStyle(fontWeight: FontWeight.w700, color: danger ? AppColors.danger : AppColors.textPrimary),
    ),
    subtitle: subtitle == null ? null : Text(subtitle, style: TextStyle(color: AppColors.textSecondary)),
    trailing: danger ? null : Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
    onTap: onTap,
  );
}

class _BadgeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final String tone;

  const _BadgeCard({required this.title, required this.subtitle, required this.icon, required this.tone});

  @override
  Widget build(BuildContext context) {
    final gradient = switch (tone) {
      'amber' => LinearGradient(colors: [Color(0xFFF2A71B), Color(0xFFE08A00)]),
      'ink' => LinearGradient(colors: [Color(0xFF3A3335), Color(0xFF55494C)]),
      'sand' => AppColors.sandGradient,
      _ => AppColors.wineGradient,
    };
    final iconData = switch (icon) {
      'trophy' => Icons.emoji_events_outlined,
      'bolt' => Icons.bolt_rounded,
      'check' => Icons.check_rounded,
      'star' => Icons.star_outline_rounded,
      _ => Icons.code_rounded,
    };
    return SoftCard(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Column(
        children: [
          GradientIconTile(icon: iconData, gradient: gradient, size: 54),
          SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.sand),
          ),
        ],
      ),
    );
  }
}
