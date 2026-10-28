// ===== FILE GUIDE: lib/screens/faculty/faculty_shell.dart
// WHAT IT DOES : Faculty app frame with bottom navigation: Home · Students · (Upload) · Messages · Profile.
// MANAGES      : Switching tabs; centre button opens Content Studio; blocks non-faculty (RoleGuard).
// USED BY      : login_screen.dart after a faculty member signs in.
// ======================================================================

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../theme/app_colors.dart';
import '../../widgets/role_guard.dart';
import '../../widgets/uni_widgets.dart';
import 'dashboard/faculty_dashboard_screen.dart';
import 'materials/content_studio_screen.dart';
import 'messages/faculty_messages_screen.dart';
import 'profile/faculty_profile_screen.dart';
import 'students/enrollment_manager_screen.dart';

/// Faculty experience: Home · Students · (Upload) · Messages · Profile.
class FacultyShell extends StatefulWidget {
  const FacultyShell({super.key});

  @override
  State<FacultyShell> createState() => _FacultyShellState();
}

class _FacultyShellState extends State<FacultyShell> {
  int _index = 0;

  static const _items = [
    UniNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    UniNavItem(Icons.people_outline_rounded, Icons.people_rounded, 'Students'),
    UniNavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Messages'),
    UniNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  Future<void> _upload() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ContentStudioScreen()));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      FacultyDashboardScreen(onOpenTab: (i) => setState(() => _index = i)),
      EnrollmentManagerScreen(),
      FacultyMessagesScreen(),
      FacultyProfileScreen(),
    ];
    return RoleGuard(
      role: UserRole.faculty,
      child: PopScope(
        // Android back: go to the first tab before leaving the app.
        canPop: _index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _index = 0);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: UniBottomNav(
            items: _items,
            index: _index,
            onTap: (i) => setState(() => _index = i),
            centerIcon: Icons.cloud_upload_outlined,
            centerLabel: 'Upload material',
            onCenter: _upload,
          ),
        ),
      ),
    );
  }
}
