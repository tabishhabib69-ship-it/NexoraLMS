// ===== FILE GUIDE: lib/screens/admin/feed/feed_management_screen.dart
// WHAT IT DOES : Moderate the campus feed.
// MANAGES      : Review and remove feed posts.
// USED BY      : Admin Reports.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/post.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/post_card.dart';

/// Admin moderation of the university social feed.
class FeedManagementScreen extends StatefulWidget {
  FeedManagementScreen({super.key});

  @override
  State<FeedManagementScreen> createState() => _FeedManagementScreenState();
}

class _FeedManagementScreenState extends State<FeedManagementScreen> {
  late final List<Post> _posts = List.of(DummyData.posts);

  void _remove(Post p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove post?'),
        content: Text('This post will be removed from the university feed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              setState(() => _posts.removeWhere((x) => x.id == p.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post removed')));
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('University Feed'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(36),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              '${_posts.length} posts · moderate inappropriate content',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
      body: _posts.isEmpty
          ? EmptyState(
              icon: Icons.dynamic_feed_rounded,
              title: 'Feed is empty',
              message: 'No posts to moderate right now.',
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _posts.length,
              itemBuilder: (_, i) {
                final p = _posts[i];
                return PostCard(
                  post: p,
                  manageActions: [
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                      onSelected: (v) {
                        if (v == 'remove') _remove(p);
                        if (v == 'flag') {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Post flagged for review')));
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(value: 'flag', child: Text('Flag post')),
                        PopupMenuItem(value: 'remove', child: Text('Remove post')),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
