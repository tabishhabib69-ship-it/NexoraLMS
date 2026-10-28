// ===== FILE GUIDE: lib/screens/admin/admin_shell.dart
// WHAT IT DOES : Admin panel frame with bottom navigation: Dashboard · Users · Courses · Reports · Settings.
// MANAGES      : Switching tabs; blocks non-admins (RoleGuard).
// USED BY      : login_screen.dart after the admin credentials are entered.
// ======================================================================

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../theme/app_colors.dart';
import '../../widgets/role_guard.dart';
import 'courses/course_management_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'reports/admin_reports_screen.dart';
import 'settings/admin_settings_screen.dart';
import 'users/user_management_screen.dart';
import '../../widgets/ui_kit.dart';

/// Admin container: five tabs (Dashboard, Users, Courses, Reports, Settings)
/// behind the Uni-Sphere bottom navigation bar.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  void _open(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    // Pages are rebuilt on every switch so counts always reflect DummyData.
    final Widget page = switch (_index) {
      1 => UserManagementScreen(),
      2 => CourseManagementScreen(),
      3 => AdminReportsScreen(),
      4 => AdminSettingsScreen(),
      _ => AdminDashboardScreen(onOpenTab: _open),
    };

    return RoleGuard(
      role: UserRole.admin,
      child: PopScope(
        // Android back: go to the first tab before leaving the app.
        canPop: _index == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _index = 0);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(bottom: false, child: page),
          bottomNavigationBar: AdminBottomNav(index: _index, onTap: _open),
        ),
      ),
    );
  }
}
