// ===== FILE GUIDE: lib/screens/student/connect/study_group_screen.dart
// WHAT IT DOES : Study group details.
// MANAGES      : Meeting time, description and member list.
// USED BY      : chat_screen.dart (group info button).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../models/user.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../../../services/my_data.dart';

/// Study group details: course, meeting time and members.
class StudyGroupScreen extends StatelessWidget {
  final StudyGroup group;

  const StudyGroupScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final course = DummyData.courseById(group.courseId);
    final members = group.memberIds.map(DummyData.userById).whereType<AppUser>().toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            AdminPageHeader(
              eyebrow: course == null ? 'Study group' : '${course.code} · ${course.title}',
              title: group.name,
            ),
            SizedBox(height: 18),
            SoftCard(
              gradient: AppColors.wineGradient,
              child: Row(
                children: [
                  Icon(Icons.event_repeat_rounded, color: Color(0xFFCFC39E), size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EyebrowLabel('Meets', color: Color(0xFFD9CFCF)),
                        SizedBox(height: 4),
                        Text(
                          group.meeting,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14),
            SoftCard(
              child: Text(group.description, style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary)),
            ),
            SizedBox(height: 22),
            SectionTitle('Members · ${members.length}'),
            SoftCard(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < members.length; i++) ...[
                    if (i > 0) Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          InitialsCircle(initials: initialsOf(members[i].name), size: 44),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  members[i].id == MyData.id ? '${members[i].name} (you)' : members[i].name,
                                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'Semester ${members[i].semester ?? '-'}',
                                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (i == 0)
                            StatusPill(
                              label: 'Organizer',
                              foreground: AppColors.sandDeep,
                              background: AppColors.mintSoft,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
