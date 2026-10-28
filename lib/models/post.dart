// ===== FILE GUIDE: lib/models/post.dart
// WHAT IT DOES : Data classes for the campus feed.
// MANAGES      : Post (category, likes, saved, reported, highlight card, image) and Comment.
// USED BY      : Feed, create post, bookmarks, admin moderation.
// ======================================================================

import 'dart:typed_data';

/// A comment on a social feed post.
class Comment {
  final String id;
  final String authorName;
  final String authorColor;
  final String body;
  final DateTime date;

  const Comment({
    required this.id,
    required this.authorName,
    required this.authorColor,
    required this.body,
    required this.date,
  });
}

enum PostCategory { general, achievement, certificate, event, club, academic }

extension PostCategoryX on PostCategory {
  String get label {
    switch (this) {
      case PostCategory.general:
        return 'General';
      case PostCategory.achievement:
        return 'Achievements';
      case PostCategory.certificate:
        return 'Certificates';
      case PostCategory.event:
        return 'Events';
      case PostCategory.club:
        return 'Clubs';
      case PostCategory.academic:
        return 'Academic';
    }
  }
}

/// A post on the university social feed.
class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String authorColor;
  String content;
  final DateTime date;
  int likes;
  int shares;

  /// Ids of users who liked / saved this post (each user sees only their own state).
  final Set<String> likedBy = {};
  final bool official; // official university post (admin)
  final List<Comment> comments;
  final Uint8List? image;
  final PostCategory category;

  /// Optional highlight card (e.g. award or certificate name + issuer).
  final String? highlightTitle;
  final String? highlightSubtitle;
  final Set<String> savedBy = {};
  bool reported;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.authorColor,
    required this.content,
    required this.date,
    this.likes = 0,
    this.shares = 0,
    this.official = false,
    this.image,
    this.category = PostCategory.general,
    this.highlightTitle,
    this.highlightSubtitle,
    this.reported = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];
}
