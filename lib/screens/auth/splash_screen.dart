// ===== FILE GUIDE: lib/screens/auth/splash_screen.dart
// WHAT IT DOES : First screen: animated Uni-Sphere logo.
// MANAGES      : Goes to onboarding (first time) or the login screen.
// USED BY      : main.dart.
// ======================================================================

import 'package:flutter/material.dart';

import '../../services/app_settings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uni_logo.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

/// Animated splash: logo scales in, then routes to onboarding (first launch)
/// or straight to sign-in.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1100))
    ..forward();
  late final Animation<double> _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Interval(0.3, 1));

  @override
  void initState() {
    super.initState();
    _next();
  }

  Future<void> _next() async {
    await Future.delayed(Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => AppSettings.onboardingSeen ? LoginScreen() : OnboardingScreen(),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.heroGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(scale: _scale, child: UniLogo(size: 112)),
            SizedBox(height: 28),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(
                    'Uni-Sphere',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'YOUR CAMPUS, REIMAGINED',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 13.5,
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 56),
            FadeTransition(
              opacity: _fade,
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
