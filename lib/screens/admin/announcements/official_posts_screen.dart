// ===== FILE GUIDE: lib/screens/admin/announcements/official_posts_screen.dart
// WHAT IT DOES : Official university posts.
// MANAGES      : Create, edit, delete verified posts on the feed.
// USED BY      : Admin Reports, admin settings.
// ======================================================================

import 'package:flutter/material.dart';

import '../../../data/dummy_data.dart';
import '../../../models/post.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/post_card.dart';
import '../../../widgets/section_header.dart';

/// Admin creates, edits, deletes and publishes official university posts.
class OfficialPostsScreen extends StatefulWidget {
  OfficialPostsScreen({super.key});

  @override
  State<OfficialPostsScreen> createState() => _OfficialPostsScreenState();
}

class _OfficialPostsScreenState extends State<OfficialPostsScreen> {
  late final List<Post> _official = DummyData.posts.where((p) => p.official).toList(growable: true);

  void _compose({Post? existing}) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ComposeSheet(initial: existing?.content),
    );
    if (result == null || result.trim().isEmpty) return;

    setState(() {
      if (existing != null) {
        final index = DummyData.posts.indexWhere((p) => p.id == existing.id);
        existing.content = result.trim();
        if (index != -1) DummyData.posts[index] = existing;
        final oi = _official.indexWhere((p) => p.id == existing.id);
        if (oi != -1) _official[oi] = existing;
      } else {
        final post = Post(
          id: 'p${DateTime.now().microsecondsSinceEpoch}',
          authorId: DummyData.admin.id,
          authorName: 'Campus Connect',
          authorRole: 'Admin',
          authorColor: DummyData.admin.avatarColor,
          content: result.trim(),
          date: DateTime.now(),
          official: true,
        );
        DummyData.posts.insert(0, post);
        _official.insert(0, post);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(existing == null ? 'Official post published' : 'Post updated')));
    }
  }

  void _delete(Post p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete post?'),
        content: Text('This official post will be removed everywhere.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              setState(() {
                _official.removeWhere((x) => x.id == p.id);
                DummyData.posts.removeWhere((x) => x.id == p.id);
              });
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Official Posts')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _compose(),
        icon: Icon(Icons.verified_rounded),
        label: Text('New Post'),
      ),
      body: _official.isEmpty
          ? EmptyState(
              icon: Icons.verified_outlined,
              title: 'No official posts',
              message: 'Publish university-wide updates for all students and faculty.',
              actionLabel: 'Create Post',
              onAction: () => _compose(),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 90),
              children: [
                SectionHeader(title: 'Published'),
                ..._official.map(
                  (p) => PostCard(
                    post: p,
                    manageActions: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                        onPressed: () => _compose(existing: p),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                        onPressed: () => _delete(p),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ComposeSheet extends StatefulWidget {
  final String? initial;
  _ComposeSheet({this.initial});

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Icon(Icons.verified_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Official University Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
            SizedBox(height: 16),
            AppTextField(
              label: 'Message',
              hint: 'Write an official announcement for the whole campus...',
              controller: _controller,
              maxLines: 5,
              validator: (v) => (v == null || v.trim().length < 5) ? 'Please write a message' : null,
            ),
            SizedBox(height: 20),
            AppButton(
              label: 'Publish',
              icon: Icons.send_rounded,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, _controller.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
