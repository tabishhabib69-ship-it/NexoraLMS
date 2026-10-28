// ===== FILE GUIDE: lib/widgets/post_card.dart
// WHAT IT DOES : Older feed post card.
// MANAGES      : Post with like/comment/share and admin manage actions.
// USED BY      : Admin official posts and feed management.
// ======================================================================

import 'package:flutter/material.dart';

import '../models/post.dart';
import '../theme/app_colors.dart';
import 'time_util.dart';
import 'user_avatar.dart';
import '../services/my_data.dart';

/// A social feed post card with like / comment / share actions.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onTap;
  final List<Widget>? manageActions;

  PostCard({super.key, required this.post, this.onLike, this.onComment, this.onShare, this.onTap, this.manageActions});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                UserAvatar(name: post.authorName, colorHex: post.authorColor, size: 44),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                          if (post.official) ...[
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 12, color: AppColors.primary),
                                  SizedBox(width: 2),
                                  Text(
                                    'Official',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${post.authorRole} · ${timeAgo(post.date)}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ...?manageActions,
              ],
            ),
          ),
          if (post.content.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Text(post.content, style: TextStyle(fontSize: 14.5, color: AppColors.textPrimary, height: 1.45)),
            ),
          if (post.image != null)
            Padding(
              padding: EdgeInsets.fromLTRB(0, post.content.trim().isEmpty ? 12 : 0, 0, 0),
              child: Image.memory(
                post.image!,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          SizedBox(height: 8),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _action(
                  icon: MyData.likes(post) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: '${post.likes}',
                  color: MyData.likes(post) ? AppColors.danger : AppColors.textSecondary,
                  onTap: onLike,
                ),
                _action(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.comments.length}',
                  color: AppColors.textSecondary,
                  onTap: onComment ?? onTap,
                ),
                _action(
                  icon: Icons.share_rounded,
                  label: '${post.shares}',
                  color: AppColors.textSecondary,
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _action({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: color),
              SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders a comment row (used on the post detail / comments sheet).
class CommentTile extends StatelessWidget {
  final Comment comment;
  CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(name: comment.authorName, colorHex: comment.authorColor, size: 36, fontSize: 13),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.authorName,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      SizedBox(width: 8),
                      Text(timeAgo(comment.date), style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(comment.body, style: TextStyle(fontSize: 13.5, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
