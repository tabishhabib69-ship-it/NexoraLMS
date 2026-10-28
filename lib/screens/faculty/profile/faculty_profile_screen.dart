// ===== FILE GUIDE: lib/screens/faculty/profile/faculty_profile_screen.dart
// WHAT IT DOES : Faculty profile.
// MANAGES      : Profile card, teaching stats, shortcuts (courses, timetable, grading, announcements, settings), logout.
// USED BY      : faculty_shell.dart (Profile tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/session_actions.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../settings/help_screen.dart';
import '../../settings/settings_screen.dart';
import '../../student/profile/edit_profile_screen.dart';
import '../../timetable/timetable_screen.dart';
import '../announcements/faculty_announcements_screen.dart';
import '../courses/faculty_courses_screen.dart';
import '../grading/grading_queue_screen.dart';

/// Faculty profile with teaching shortcuts and settings.
class FacultyProfileScreen extends StatefulWidget {
  const FacultyProfileScreen({super.key});

  @override
  State<FacultyProfileScreen> createState() => _FacultyProfileScreenState();
}

class _FacultyProfileScreenState extends State<FacultyProfileScreen> {
  Future<void> _push(Widget w) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionService.currentUser ?? DummyData.faculty;
    final courses = DummyData.courses.where((c) => c.facultyId == user.id).toList();
    final links = <(IconData, String, Widget)>[
      (Icons.menu_book_outlined, 'My courses', FacultyCoursesScreen()),
      (Icons.calendar_month_outlined, 'Teaching timetable', TimetableScreen(faculty: true)),
      (Icons.grading_rounded, 'Grading queue', GradingQueueScreen()),
      (Icons.campaign_outlined, 'Announcements', FacultyAnnouncementsScreen()),
      (Icons.tune_rounded, 'Settings', SettingsScreen()),
      (Icons.help_outline_rounded, 'Help & feedback', HelpScreen()),
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          AdminPageHeader(eyebrow: 'Faculty · Account', title: 'Profile'),
          SizedBox(height: 18),
          SoftCard(
            gradient: AppColors.wineGradient,
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: AdminAvatar(initials: initialsOf(user.name), gradient: AppColors.sandGradient, size: 62),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '${user.designation ?? ''} · ${user.department ?? ''}',
                        style: TextStyle(fontSize: 13, color: Color(0xFFCFC39E)),
                      ),
                      SizedBox(height: 3),
                      Text(user.email, style: TextStyle(fontSize: 12.5, color: Color(0xFFD9CFCF))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          if (user.bio != null) ...[
            SoftCard(
              child: Text(user.bio!, style: TextStyle(height: 1.5, color: AppColors.textPrimary)),
            ),
            SizedBox(height: 14),
          ],
          StatStrip(
            items: [
              (value: '${courses.length}', label: 'Courses', color: AppColors.primary),
              (
                value: '${courses.fold<int>(0, (s, c) => s + c.enrolledCount)}',
                label: 'Students',
                color: AppColors.sand,
              ),
              (
                value: '${DummyData.materials.where((m) => courses.any((c) => c.id == m.courseId)).length}',
                label: 'Materials',
                color: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 16),
          PillButton(
            label: 'Edit Profile',
            icon: Icons.edit_outlined,
            filled: false,
            onPressed: () => _push(EditProfileScreen(user: user)),
          ),
          SizedBox(height: 16),
          SoftCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < links.length; i++) ...[
                  if (i > 0) Divider(height: 1),
                  AdminNavTile(
                    icon: links[i].$1,
                    title: links[i].$2,
                    subtitle: '',
                    onTap: () => _push(links[i].$3),
                    gradient: i.isEven ? AppColors.wineGradient : AppColors.sandGradient,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => confirmLogout(context),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, backgroundColor: AppColors.surface),
            icon: Icon(Icons.logout_rounded),
            label: Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
