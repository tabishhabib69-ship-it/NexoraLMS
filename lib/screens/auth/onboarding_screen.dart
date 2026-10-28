// ===== FILE GUIDE: lib/screens/auth/onboarding_screen.dart
// WHAT IT DOES : Three intro pages with Skip / Next / Get Started.
// MANAGES      : Marks onboarding as seen and opens login.
// USED BY      : splash_screen.dart.
// ======================================================================

import 'package:flutter/material.dart';

import '../../services/app_settings.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uni_widgets.dart';
import 'login_screen.dart';

/// Three intro pages: campus learning, staying organized, AI study support.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      Icons.menu_book_rounded,
      Icons.school_rounded,
      'Your whole campus in one place',
      'Courses, materials, assignments and announcements from every class — organized for you.',
    ),
    (
      Icons.calendar_month_rounded,
      Icons.checklist_rounded,
      'Stay on top of every deadline',
      'A live timetable, exam countdowns and attendance alerts so nothing slips through.',
    ),
    (
      Icons.auto_awesome_rounded,
      Icons.smart_toy_rounded,
      'Study smarter with Uni-AI',
      'Ask questions, summarize lectures, make quizzes and build study plans — anytime.',
    ),
  ];

  void _finish() {
    AppSettings.onboardingSeen = true;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 12, 0),
                child: TextButton(onPressed: _finish, child: Text('Skip')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Illustration(main: p.$1, accent: p.$2),
                        SizedBox(height: 44),
                        Text(
                          p.$3,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          p.$4,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15.5, height: 1.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 220),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: GradientButton(
                label: last ? 'Get Started' : 'Next',
                icon: last ? Icons.arrow_forward_rounded : null,
                onPressed: last
                    ? _finish
                    : () => _controller.nextPage(duration: Duration(milliseconds: 320), curve: Curves.easeOut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final IconData main;
  final IconData accent;

  const _Illustration({required this.main, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
          ),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              gradient: AppColors.wineGradient,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: Color(0x402E2729), blurRadius: 30, offset: Offset(0, 14))],
            ),
            child: Icon(main, size: 64, color: Colors.white),
          ),
          Positioned(
            right: 10,
            top: 18,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.sandGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppColors.softShadow,
              ),
              child: Icon(accent, size: 30, color: Colors.white),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 22,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: Color(0xFF2EC4A0), shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
