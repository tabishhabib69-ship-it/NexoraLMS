// ===== FILE GUIDE: lib/screens/student/search/global_search_screen.dart
// WHAT IT DOES : Search everything.
// MANAGES      : Finds courses, materials, announcements, people and posts at once.
// USED BY      : Dashboard search icon.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/user.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../courses/course_details_screen.dart';

/// Searches courses, materials, announcements, people and posts at once.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _Hit {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  _Hit(this.icon, this.title, this.subtitle, [this.onTap]);
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  String _q = '';

  Map<String, List<_Hit>> _search(BuildContext context) {
    final q = _q.toLowerCase().trim();
    if (q.length < 2) return {};
    bool has(String s) => s.toLowerCase().contains(q);
    void open(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    return {
      'Courses': [
        for (final c in DummyData.courses)
          if (has(c.title) || has(c.code) || has(c.facultyName))
            _Hit(
              Icons.menu_book_outlined,
              '${c.code} · ${c.title}',
              c.facultyName,
              () => open(CourseDetailsScreen(course: c, initialTab: 0)),
            ),
      ],
      'Materials': [
        for (final m in DummyData.materials)
          if (has(m.title) || has(m.description))
            _Hit(
              Icons.description_outlined,
              m.title,
              '${DummyData.courseById(m.courseId)?.code} · ${m.size}',
              () => showMaterialPreview(context, m),
            ),
      ],
      'Announcements': [
        for (final a in DummyData.announcements)
          if (has(a.title) || has(a.body)) _Hit(Icons.campaign_outlined, a.title, a.authorName),
      ],
      'People': [
        for (final u in DummyData.users)
          if (u.role != UserRole.admin && (has(u.name) || has(u.department ?? '')))
            _Hit(
              Icons.person_outline_rounded,
              u.name,
              '${u.role.label} · ${u.department ?? ''} · find them in Chat → Connect',
            ),
      ],
      'Posts': [
        for (final p in DummyData.posts)
          if (!p.reported && (has(p.content) || has(p.authorName)))
            _Hit(Icons.dynamic_feed_outlined, p.authorName, p.content),
      ],
    }..removeWhere((_, v) => v.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final results = _search(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              children: [
                CircleBackButton(),
                SizedBox(width: 12),
                Expanded(
                  child: SearchBox(
                    hint: 'Search courses, materials, people…',
                    autofocus: true,
                    onChanged: (v) => setState(() => _q = v),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_q.trim().length < 2)
              EmptyState(
                icon: Icons.manage_search_rounded,
                title: 'Search everything',
                message: 'Type at least 2 characters — try "tree", "Khan" or "SQL".',
              )
            else if (results.isEmpty)
              EmptyState(icon: Icons.search_off_rounded, title: 'No results', message: 'Nothing matches "$_q".')
            else
              for (final entry in results.entries) ...[
                SectionTitle('${entry.key} · ${entry.value.length}'),
                SoftCard(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    children: [
                      for (final h in entry.value)
                        ListTile(
                          leading: Icon(h.icon, color: AppColors.primary),
                          title: Text(
                            h.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            h.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: h.onTap == null
                              ? null
                              : Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                          onTap: h.onTap,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
              ],
          ],
        ),
      ),
    );
  }
}
