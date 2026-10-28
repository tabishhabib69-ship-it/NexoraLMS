// ===== FILE GUIDE: lib/services/app_settings.dart
// WHAT IT DOES : App-wide user preferences (kept in memory).
// MANAGES      : Theme mode, text size, notification and privacy toggles, interests; repaints the app when the theme changes.
// USED BY      : main.dart, Settings, profile Dark Mode switch, recommendations.
// ======================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// App-wide preferences (theme, text size, notifications, privacy).
///
/// Kept in memory for this demo build — swap the fields for a persistent
/// store (e.g. shared_preferences) when the app needs to remember them.
class AppSettings {
  AppSettings._();

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  static final ValueNotifier<double> textScale = ValueNotifier(1.0);

  static bool onboardingSeen = false;
  static bool rememberMe = false;

  /// Notification categories the user wants to receive.
  static final Map<String, bool> notificationPrefs = {
    'Assignments & deadlines': true,
    'Exams & results': true,
    'Course announcements': true,
    'Messages': true,
    'Campus feed': false,
    'Lost & Found': false,
  };

  /// Privacy: what other students can see on the profile.
  static bool showStudentIdOnProfile = false;
  static bool showEmailOnProfile = false;
  static bool allowConnectionRequests = true;

  /// Student interests used by course recommendations.
  static final Set<String> interests = {'Mobile', 'Design', 'AI'};

  /// Resolves the active palette from the theme mode and platform brightness.
  static void applyTheme(Brightness platformBrightness) {
    final mode = themeMode.value;
    AppColors.isDark = mode == ThemeMode.dark || (mode == ThemeMode.system && platformBrightness == Brightness.dark);
  }

  /// Marks every element under [context] dirty so widgets that read the static
  /// [AppColors] tokens repaint with the new palette (state is preserved).
  static void rebuildAll(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }
}
