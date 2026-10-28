// ===== FILE GUIDE: lib/main.dart
// WHAT IT DOES : App entry point. Starts Uni-Sphere and opens the splash screen.
// MANAGES      : Light/dark theme switching and the text-size setting for the whole app.
// USED BY      : Run by Flutter first (main()).
// ======================================================================

import 'package:flutter/material.dart';

import 'screens/auth/splash_screen.dart';
import 'services/app_settings.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UniSphereApp());
}

/// Root widget for Uni-Sphere — AI-powered university companion & LMS.
class UniSphereApp extends StatefulWidget {
  const UniSphereApp({super.key});

  @override
  State<UniSphereApp> createState() => _UniSphereAppState();
}

class _UniSphereAppState extends State<UniSphereApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppSettings.themeMode.addListener(_onAppearanceChanged);
    AppSettings.textScale.addListener(_onAppearanceChanged);
    _applyTheme();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppSettings.themeMode.removeListener(_onAppearanceChanged);
    AppSettings.textScale.removeListener(_onAppearanceChanged);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => _onAppearanceChanged();

  void _applyTheme() => AppSettings.applyTheme(WidgetsBinding.instance.platformDispatcher.platformBrightness);

  void _onAppearanceChanged() {
    _applyTheme();
    setState(() {});
    // Widgets read the static colour tokens, so repaint the whole tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppSettings.rebuildAll(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni-Sphere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.current,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(AppSettings.textScale.value)),
        child: child!,
      ),
      home: SplashScreen(),
    );
  }
}
