// ===== FILE GUIDE: lib/widgets/session_actions.dart
// WHAT IT DOES : Logout helper.
// MANAGES      : Asks for confirmation, signs out and returns to login.
// USED BY      : Profiles and settings screens.
// ======================================================================

import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../services/session_service.dart';
import 'uni_widgets.dart';

/// Confirms, signs out and returns to the sign-in screen.
Future<void> confirmLogout(BuildContext context) async {
  final ok = await confirmAction(
    context,
    title: 'Log out?',
    message: 'You will need to sign in again to use Uni-Sphere.',
    confirmLabel: 'Log out',
    destructive: true,
  );
  if (!ok || !context.mounted) return;
  SessionService.signOut();
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginScreen()), (_) => false);
}
