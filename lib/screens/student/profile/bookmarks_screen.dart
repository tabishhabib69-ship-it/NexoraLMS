// ===== FILE GUIDE: lib/screens/student/profile/bookmarks_screen.dart
// WHAT IT DOES : Bookmarks.
// MANAGES      : Saved course materials and saved feed posts.
// USED BY      : Student profile.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../courses/course_details_screen.dart';
import '../feed/feed_screen.dart';
import '../../../services/my_data.dart';

/// Saved feed posts and bookmarked learning resources.
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final posts = DummyData.posts.where((p) => MyData.saved(p) && !p.reported).toList();
    final mats = DummyData.materials.where((m) => MyData.savedMaterials.contains(m.id)).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [CircleBackButton()]),
            SizedBox(height: 16),
            AdminPageHeader(eyebrow: 'Saved for later', title: 'Bookmarks'),
            SizedBox(height: 18),
            SegmentedTabs(
              labels: ['Resources · ${mats.length}', 'Posts · ${posts.length}'],
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            SizedBox(height: 18),
            if (_tab == 0) ...[
              if (mats.isEmpty)
                EmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'No saved resources',
                  message: 'Tap the bookmark on any course material to keep it here.',
                ),
              for (final m in mats)
                Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: MaterialTile(material: m, onPreview: () => showMaterialPreview(context, m)),
                ),
            ] else ...[
              if (posts.isEmpty)
                EmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'No saved posts',
                  message: 'Save posts from the campus feed to read later.',
                ),
              for (final p in posts)
                Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: PostCard(post: p, onChanged: () => setState(() {})),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
