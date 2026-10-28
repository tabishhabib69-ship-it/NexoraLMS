// ===== FILE GUIDE: lib/screens/student/feed/feed_screen.dart
// WHAT IT DOES : Campus Feed (PDF page 6).
// MANAGES      : Category filters, search, official notice, likes, comments, congrats, save, share, report, delete own post. Also holds the shared PostCard.
// USED BY      : student_shell.dart (Feed tab), bookmarks.
// ======================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/dummy_data.dart';
import '../../../models/announcement.dart';
import '../../../models/post.dart';
import '../../../services/session_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/time_util.dart';
import '../../../widgets/ui_kit.dart';
import '../../../widgets/uni_widgets.dart';
import '../notifications/notifications_screen.dart';
import 'create_post_screen.dart';
import '../../../services/my_data.dart';

/// Campus feed (PDF page 6). Interactions are local to this demo session.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _filter = 0;
  bool _searching = false;
  bool _loading = false;
  String _query = '';

  static final _filters = [
    'All',
    ...PostCategory.values.where((c) => c != PostCategory.general).map((c) => c.label),
    'Saved',
  ];

  List<Post> get _posts {
    final q = _query.toLowerCase();
    return DummyData.posts.where((p) {
      if (p.reported) return false;
      final label = _filters[_filter];
      final matchesFilter = switch (label) {
        'All' => true,
        'Saved' => MyData.saved(p),
        _ => p.category.label == label,
      };
      final matchesQuery =
          q.isEmpty ||
          p.content.toLowerCase().contains(q) ||
          p.authorName.toLowerCase().contains(q) ||
          (p.highlightTitle ?? '').toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(Duration(milliseconds: 600));
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _create() async {
    final post = await Navigator.push<Post>(context, MaterialPageRoute(builder: (_) => CreatePostScreen()));
    if (post != null && mounted) setState(() => _filter = 0);
  }

  @override
  Widget build(BuildContext context) {
    final posts = _posts;
    final weekly = DummyData.posts.where((p) => DateTime.now().difference(p.date).inDays < 7).length;
    final official = DummyData.announcements.where((a) => a.courseId == null).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'feed-fab',
        tooltip: 'New post',
        onPressed: _create,
        child: Icon(Icons.add_rounded, size: 30),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 96),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AdminPageHeader(
                  eyebrow: '$weekly new post${weekly == 1 ? '' : 's'} this week',
                  title: 'Campus Feed',
                  actions: [
                    CircleIconButton(
                      icon: _searching ? Icons.close_rounded : Icons.search_rounded,
                      onTap: () => setState(() {
                        _searching = !_searching;
                        if (!_searching) _query = '';
                      }),
                    ),
                    CircleIconButton(
                      icon: Icons.notifications_none_rounded,
                      showDot: MyData.notifications.any((n) => !n.read),
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen()));
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              if (_searching)
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SearchBox(
                    hint: 'Search posts or people…',
                    autofocus: true,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              SizedBox(height: 16),
              FilterPills(labels: _filters, index: _filter, onChanged: (i) => setState(() => _filter = i)),
              SizedBox(height: 18),
              if (_filter == 0 && _query.isEmpty)
                for (final a in official.take(1))
                  Padding(padding: EdgeInsets.fromLTRB(20, 0, 20, 16), child: _OfficialNotice(a)),
              if (_loading)
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (posts.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: EmptyState(
                    icon: _filters[_filter] == 'Saved' ? Icons.bookmark_border_rounded : Icons.forum_outlined,
                    title: _filters[_filter] == 'Saved' ? 'No saved posts' : 'No posts here yet',
                    message: _filters[_filter] == 'Saved'
                        ? 'Tap the bookmark on any post to save it.'
                        : 'Be the first to share something!',
                    actionLabel: 'Create post',
                    onAction: _create,
                  ),
                )
              else
                for (final p in posts)
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: PostCard(post: p, onChanged: () => setState(() {})),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficialNotice extends StatelessWidget {
  final Announcement a;

  const _OfficialNotice(this.a);

  @override
  Widget build(BuildContext context) {
    final urgent = a.priority == AnnouncementPriority.urgent;
    return SoftCard(
      gradient: AppColors.wineGradient,
      padding: EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign_rounded, color: Color(0xFFCFC39E), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'OFFICIAL',
                      style: TextStyle(
                        color: Color(0xFFCFC39E),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    if (urgent)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Color(0xFFE57C85), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          'URGENT',
                          style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  a.title,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(a.body, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13.5, height: 1.4)),
                SizedBox(height: 6),
                Text(
                  '${a.authorName} · ${timeAgo(a.date)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A feed post with like, comment, congrats, save, share and report.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onChanged;

  const PostCard({super.key, required this.post, required this.onChanged});

  String get _verb => switch (post.category) {
    PostCategory.achievement => 'shared an achievement',
    PostCategory.certificate => 'earned a certificate',
    PostCategory.event => 'posted an event',
    PostCategory.club => 'posted a club update',
    PostCategory.academic => 'posted an academic update',
    PostCategory.general => 'posted',
  };

  bool get _mine => post.authorId == MyData.id;

  Future<void> _menu(BuildContext context, String action) async {
    switch (action) {
      case 'save':
        MyData.toggleSave(post);
        onChanged();
        showSnack(context, MyData.saved(post) ? 'Saved to bookmarks' : 'Removed from bookmarks');
      case 'share':
        await Clipboard.setData(ClipboardData(text: '${post.authorName}: ${post.content}'));
        post.shares++;
        onChanged();
        if (context.mounted) showSnack(context, 'Post text copied — paste it anywhere to share');
      case 'report':
        final ok = await confirmAction(
          context,
          title: 'Report this post?',
          message: 'It will be hidden from your feed and sent to moderators for review.',
          confirmLabel: 'Report',
          destructive: true,
        );
        if (ok) {
          post.reported = true;
          onChanged();
          if (context.mounted) showSnack(context, 'Thanks — moderators will review this post.');
        }
      case 'delete':
        final ok = await confirmAction(
          context,
          title: 'Delete post?',
          message: 'This cannot be undone.',
          confirmLabel: 'Delete',
          destructive: true,
        );
        if (ok) {
          DummyData.posts.removeWhere((p) => p.id == post.id);
          onChanged();
        }
    }
  }

  void _comments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _CommentsSheet(post: post, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verified = post.official || post.authorRole == 'Faculty' || post.authorRole == 'Admin';
    final isAward = post.category == PostCategory.achievement || post.category == PostCategory.certificate;
    return SoftCard(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsCircle(
                initials: initialsOf(post.authorName),
                size: 50,
                gradient: post.authorRole == 'Faculty' ? AppColors.sandGradient : AppColors.wineGradient,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        if (verified) ...[
                          SizedBox(width: 6),
                          Icon(Icons.verified_rounded, size: 17, color: AppColors.sand, semanticLabel: 'Verified'),
                        ],
                      ],
                    ),
                    Text(
                      '$_verb · ${timeAgo(post.date)}',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Post options',
                icon: Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                onSelected: (v) => _menu(context, v),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'save', child: Text(MyData.saved(post) ? 'Remove bookmark' : 'Save post')),
                  PopupMenuItem(value: 'share', child: Text('Share')),
                  if (_mine)
                    PopupMenuItem(value: 'delete', child: Text('Delete post'))
                  else
                    PopupMenuItem(value: 'report', child: Text('Report post')),
                ],
              ),
            ],
          ),
          if (post.highlightTitle != null) ...[
            SizedBox(height: 14),
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: post.category == PostCategory.achievement
                          ? LinearGradient(colors: [Color(0xFFF2A71B), Color(0xFFE08A00)])
                          : AppColors.wineGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      post.category == PostCategory.achievement
                          ? Icons.emoji_events_outlined
                          : Icons.workspace_premium_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.highlightTitle!,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        if (post.highlightSubtitle != null)
                          Text(post.highlightSubtitle!, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          Text(post.content, style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary)),
          if (post.image != null) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(post.image!, fit: BoxFit.cover),
            ),
          ],
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 10),
          Row(
            children: [
              _ActionPill(
                icon: MyData.likes(post) ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                label: '${post.likes}',
                active: MyData.likes(post),
                semantic: MyData.likes(post) ? 'Unlike' : 'Like',
                onTap: () {
                  MyData.toggleLike(post);
                  onChanged();
                },
              ),
              SizedBox(width: 10),
              _ActionPill(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${post.comments.length}',
                semantic: 'Comments',
                onTap: () => _comments(context),
              ),
              SizedBox(width: 10),
              if (isAward)
                _ActionPill(
                  icon: Icons.favorite_border_rounded,
                  label: 'Congrats',
                  semantic: 'Send congratulations',
                  onTap: () {
                    post.comments.add(
                      Comment(
                        id: 'c${DateTime.now().millisecondsSinceEpoch}',
                        authorName: (SessionService.currentUser ?? DummyData.student).name,
                        authorColor: '#8A4A52',
                        body: 'Congratulations! 🎉',
                        date: DateTime.now(),
                      ),
                    );
                    onChanged();
                    showSnack(context, 'Congrats sent to ${post.authorName.split(' ').first}');
                  },
                )
              else
                _ActionPill(
                  icon: Icons.ios_share_rounded,
                  label: 'Share',
                  semantic: 'Share',
                  onTap: () => _menu(context, 'share'),
                ),
              Spacer(),
              IconButton(
                tooltip: MyData.saved(post) ? 'Remove bookmark' : 'Save post',
                onPressed: () => _menu(context, 'save'),
                icon: Icon(
                  MyData.saved(post) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String semantic;
  final VoidCallback onTap;
  final bool active;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.semantic,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantic,
      child: Material(
        color: active ? AppColors.primarySoft : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final Post post;
  final VoidCallback onChanged;

  const _CommentsSheet({required this.post, required this.onChanged});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _add() {
    final body = _text.text.trim();
    if (body.isEmpty) return;
    setState(() {
      widget.post.comments.add(
        Comment(
          id: 'c${DateTime.now().millisecondsSinceEpoch}',
          authorName: (SessionService.currentUser ?? DummyData.student).name,
          authorColor: '#8A4A52',
          body: body,
          date: DateTime.now(),
        ),
      );
      _text.clear();
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.post.comments;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Flexible(
              child: comments.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No comments yet — start the conversation.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        for (final c in comments)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InitialsCircle(initials: initialsOf(c.authorName), size: 36),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${c.authorName} · ${timeAgo(c.date)}',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(c.body, style: TextStyle(color: AppColors.textPrimary)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _text,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _add(),
                        decoration: InputDecoration(hintText: 'Write a comment…'),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Send comment',
                      onPressed: _add,
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
