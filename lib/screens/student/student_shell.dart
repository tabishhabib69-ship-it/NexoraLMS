// ===== FILE GUIDE: lib/screens/student/student_shell.dart
// WHAT IT DOES : Student app frame with bottom navigation: Home · Feed · (+) · Chat · Me.
// MANAGES      : Switching tabs and the + quick-actions sheet; blocks non-students (RoleGuard).
// USED BY      : login_screen.dart after a student signs in.
// ======================================================================

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../theme/app_colors.dart';
import '../../widgets/role_guard.dart';
import '../../widgets/uni_widgets.dart';
import '../timetable/timetable_screen.dart';
import 'ai/uni_ai_screen.dart';
import 'assignments/assignments_screen.dart';
import 'connect/connect_screen.dart';
import 'dashboard/student_dashboard_screen.dart';
import 'feed/create_post_screen.dart';
import 'feed/feed_screen.dart';
import 'lost_found/add_lost_found_screen.dart';
import 'profile/student_profile_screen.dart';

/// Student experience: Home · Feed · (+ quick actions) · Chat · Me.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;
  final _keys = List.generate(4, (_) => GlobalKey());

  static const _items = [
    UniNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    UniNavItem(Icons.dynamic_feed_outlined, Icons.dynamic_feed_rounded, 'Feed'),
    UniNavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
    UniNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Me'),
  ];

  void _open(int i) => setState(() => _index = i);

  Future<void> _push(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {}); // refresh counts after returning
  }

  void _quickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheet) {
        Widget tile(IconData icon, String title, String sub, Gradient g, Widget screen) => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 22, vertical: 4),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(gradient: g, borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          subtitle: Text(sub, style: TextStyle(color: AppColors.textSecondary)),
          onTap: () {
            Navigator.pop(sheet);
            _push(screen);
          },
        );
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                tile(
                  Icons.auto_awesome_rounded,
                  'Ask Uni-AI',
                  'Explain, summarize, quiz yourself',
                  AppColors.wineGradient,
                  UniAiScreen(),
                ),
                tile(
                  Icons.edit_note_rounded,
                  'New post',
                  'Share with the campus feed',
                  AppColors.sandGradient,
                  CreatePostScreen(),
                ),
                tile(
                  Icons.assignment_turned_in_outlined,
                  'Submit assignment',
                  'See what is due',
                  AppColors.roseGradient,
                  AssignmentsScreen(),
                ),
                tile(
                  Icons.event_available_outlined,
                  'Add study event',
                  'Plan time in your timetable',
                  AppColors.wineGradient,
                  TimetableScreen(openAddEvent: true),
                ),
                tile(
                  Icons.travel_explore_rounded,
                  'Report lost / found item',
                  'Post to the campus board',
                  AppColors.sandGradient,
                  AddLostFoundScreen(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      StudentDashboardScreen(key: _keys[0], onOpenTab: _open),
      FeedScreen(key: _keys[1]),
      ConnectScreen(key: _keys[2]),
      StudentProfileScreen(key: _keys[3]),
    ];
    return RoleGuard(
      role: UserRole.student,
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
            onTap: _open,
            centerIcon: Icons.add_rounded,
            centerLabel: 'Quick actions',
            onCenter: _quickActions,
          ),
        ),
      ),
    );
  }
}
