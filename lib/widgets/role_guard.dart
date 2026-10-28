// ===== FILE GUIDE: lib/widgets/role_guard.dart
// WHAT IT DOES : Role protection for each app area.
// MANAGES      : Shows "Session expired" or "Permission denied" if the wrong user opens a role's screens.
// USED BY      : Student, faculty and admin shells.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/auth/login_screen.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import 'uni_widgets.dart';

/// Shows [child] only when the signed-in user has [role]; otherwise a
/// session-expired or permission-denied state.
///
/// This is in-app navigation safety only — a real backend must also enforce
/// authorization on every request.
class RoleGuard extends StatelessWidget {
  final UserRole role;
  final Widget child;

  const RoleGuard({super.key, required this.role, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = SessionService.currentUser;
    if (user == null) {
      return _Blocked(
        icon: Icons.lock_clock_outlined,
        title: 'Session expired',
        message: 'Please sign in again to continue.',
      );
    }
    if (user.role != role) {
      return _Blocked(
        icon: Icons.block_rounded,
        title: 'Permission denied',
        message: 'Your ${user.role.label.toLowerCase()} account cannot open the ${role.label.toLowerCase()} area.',
      );
    }
    return child;
  }
}

class _Blocked extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _Blocked({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                  child: Icon(icon, size: 42, color: AppColors.primary),
                ),
                SizedBox(height: 22),
                Text(
                  title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                SizedBox(height: 26),
                SizedBox(
                  width: 220,
                  child: GradientButton(
                    label: 'Go to Sign In',
                    onPressed: () {
                      SessionService.signOut();
                      Navigator.of(context)
                          .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginScreen()), (_) => false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
