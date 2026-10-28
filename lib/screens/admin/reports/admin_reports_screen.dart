// ===== FILE GUIDE: lib/screens/admin/reports/admin_reports_screen.dart
// WHAT IT DOES : Admin Reports.
// MANAGES      : Moderation queue for reported posts (restore/remove), users by role, course enrollment, content-moderation links.
// USED BY      : admin_shell.dart (Reports tab).
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/academics.dart';
import '../../../models/user.dart';
import '../../../theme/app_colors.dart';
import '../announcements/official_posts_screen.dart';
import '../announcements/university_updates_screen.dart';
import '../feed/feed_management_screen.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';

/// Admin reports ("Admin · Insights"): user / enrollment breakdowns and
/// shortcuts to content moderation.
class AdminReportsScreen extends StatefulWidget {
  AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final users = DummyData.users;
    final courses = [...DummyData.courses]..sort((a, b) => b.enrolledCount.compareTo(a.enrolledCount));
    final maxEnrolled = courses.isEmpty ? 1 : courses.first.enrolledCount.clamp(1, 1 << 30);
    final posts = DummyData.posts;
    final official = posts.where((p) => p.official).length;
    final reported = posts.where((p) => p.reported).toList();
    final pendingEnrollments = DummyData.enrollmentRequests.where((r) => r.status == RequestStatus.pending).length;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        AdminPageHeader(eyebrow: 'Admin · Insights', title: 'Reports'),
        SizedBox(height: 18),
        StatStrip(
          items: [
            (value: '${users.length}', label: 'Users', color: AppColors.primary),
            (value: '${posts.length}', label: 'Posts', color: AppColors.sand),
            (value: '${reported.length}', label: 'Reported', color: AppColors.primary),
          ],
        ),
        SizedBox(height: 22),

        _SectionTitle('Moderation Queue'),
        if (reported.isEmpty)
          SoftCard(
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.success),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No reported posts. Reports from the campus feed appear here.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        for (final p in reported)
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.authorName,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: AppColors.textPrimary),
                        ),
                      ),
                      StatusPill(label: 'REPORTED', foreground: AppColors.danger, background: AppColors.dangerSoft),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    p.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      PillButton(
                        label: 'Restore',
                        filled: false,
                        onPressed: () {
                          setState(() => p.reported = false);
                          DummyData.logAction('Post restored', 'Post by ${p.authorName}');
                        },
                      ),
                      SizedBox(width: 10),
                      PillButton(
                        label: 'Remove post',
                        onPressed: () async {
                          final ok = await confirmAction(
                            context,
                            title: 'Remove post?',
                            message: 'The post by ${p.authorName} will be deleted from the feed.',
                            confirmLabel: 'Remove',
                            destructive: true,
                          );
                          if (!ok || !mounted) return;
                          setState(() => DummyData.posts.removeWhere((x) => x.id == p.id));
                          DummyData.logAction('Post removed', 'Post by ${p.authorName} (reported)');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (pendingEnrollments > 0)
          InfoBanner(
            icon: Icons.how_to_reg_outlined,
            text:
                '$pendingEnrollments enrollment request${pendingEnrollments == 1 ? ' is' : 's are'} waiting for '
                'faculty review in their Enrollment Manager.',
          ),
        SizedBox(height: 22),

        _SectionTitle('Users by Role'),
        SoftCard(
          child: Column(
            children: [
              for (final role in UserRole.values) ...[
                if (role != UserRole.values.first) SizedBox(height: 16),
                _BarRow(
                  label: switch (role) {
                    UserRole.faculty => 'Faculty',
                    UserRole.admin => 'Staff',
                    _ => 'Students',
                  },
                  trailing: '${users.where((u) => u.role == role).length}',
                  value: users.isEmpty ? 0 : users.where((u) => u.role == role).length / users.length,
                  gradient: role == UserRole.faculty
                      ? LinearGradient(colors: [Color(0xFFCFC39E), AppColors.sand])
                      : AppColors.progressGradient,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 22),

        _SectionTitle('Course Enrollment'),
        SoftCard(
          child: Column(
            children: [
              for (var i = 0; i < courses.length; i++) ...[
                if (i > 0) SizedBox(height: 16),
                _BarRow(
                  label: '${courses[i].code} · ${courses[i].title}',
                  trailing: '${courses[i].enrolledCount}',
                  value: courses[i].enrolledCount / maxEnrolled,
                  caption: '${courses[i].facultyName} · ${courses[i].credits} credits',
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 22),

        _SectionTitle('Content Moderation'),
        SoftCard(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              AdminNavTile(
                icon: Icons.dynamic_feed_outlined,
                title: 'University Feed',
                subtitle: '${posts.length} posts to review',
                onTap: () => _go(FeedManagementScreen()),
              ),
              Divider(height: 1),
              AdminNavTile(
                icon: Icons.verified_outlined,
                gradient: AppColors.sandGradient,
                title: 'Official Posts',
                subtitle: '$official published',
                onTap: () => _go(OfficialPostsScreen()),
              ),
              Divider(height: 1),
              AdminNavTile(
                icon: Icons.campaign_outlined,
                gradient: AppColors.roseGradient,
                title: 'University Updates',
                subtitle: 'Announcements & notices',
                onTap: () => _go(UniversityUpdatesScreen()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final String trailing;
  final double value;
  final String? caption;
  final Gradient gradient;

  _BarRow({
    required this.label,
    required this.trailing,
    required this.value,
    this.caption,
    this.gradient = AppColors.progressGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            SizedBox(width: 8),
            Text(
              trailing,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
          ],
        ),
        SizedBox(height: 8),
        GradientProgress(value: value, gradient: gradient),
        if (caption != null) ...[
          SizedBox(height: 6),
          Text(caption!, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}
